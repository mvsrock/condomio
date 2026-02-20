import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:keycloak_wrapper/keycloak_wrapper.dart'
    show JWT, KeycloakConfig, KeycloakWrapper;

import '../config/keycloak_config.dart';
import '../platform/desktop_auth.dart';
import '../platform/web_platform.dart';
import '../utils/app_logger.dart';

/// Servizio centrale di autenticazione usato da provider e UI.
///
/// Architettura:
/// - Web + Desktop: flusso OAuth2 Authorization Code + PKCE gestito manualmente.
///   Qui costruiamo URL di authorize, validiamo callback, facciamo token exchange.
/// - Mobile: flusso delegato a `keycloak_wrapper` (basato su AppAuth nativo).
///
/// Perche' due flussi:
/// - Su web/desktop serve controllo esplicito di redirect URI e callback.
/// - Su mobile e' preferibile il canale nativo gia' gestito dal wrapper.
class KeycloakService {
  static final KeycloakService _instance = KeycloakService._internal();
  static const FlutterSecureStorage _desktopStorage = FlutterSecureStorage();

  KeycloakWrapper? _mobileKeycloak;

  String? _manualAccessToken;
  String? _manualIdToken;
  String? _manualRefreshToken;
  Map<String, dynamic>? _manualTokenParsed;
  Map<String, dynamic>? _manualIdTokenParsed;

  bool _initialized = false;

  static const String _accessTokenStorageKey = 'access_token';
  static const String _idTokenStorageKey = 'id_token';
  static const String _refreshTokenStorageKey = 'refresh_token';
  static const String _codeVerifierStorageKey = 'code_verifier';
  static const String _oauthStateStorageKey = 'oauth_state';

  KeycloakService._internal();

  factory KeycloakService() => _instance;

  bool get _isDesktop {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }

  bool get _usesManualFlow => kIsWeb || _isDesktop;

  /// Inizializza il servizio una sola volta per ciclo di vita app.
  ///
  /// - Web: ripristina token da sessionStorage.
  /// - Desktop: nessun persist locale (token in memoria).
  /// - Mobile: inizializza wrapper nativo.
  Future<void> init() async {
    if (_initialized) return;

    // Nel flusso manuale i token vengono persistiti su:
    // - web: sessionStorage browser
    // - desktop: secure storage locale
    if (_usesManualFlow) {
      _manualAccessToken = await _readStoredManualToken(_accessTokenStorageKey);
      _manualIdToken = await _readStoredManualToken(_idTokenStorageKey);
      _manualRefreshToken = await _readStoredManualToken(
        _refreshTokenStorageKey,
      );
      _parseAndSetManualTokens();
    } else {
      await _ensureMobileInitialized();
    }

    _initialized = true;
  }

  /// Verifica rapida dello stato sessione corrente.
  ///
  /// Nota: sul flusso manuale controlla anche la scadenza (`exp`) del token.
  bool hasValidSession() {
    if (_usesManualFlow) return _hasValidManualSession();
    return _mobileKeycloak?.accessToken != null &&
        _mobileKeycloak?.idToken != null;
  }

  /// Ripristina token da sessionStorage web.
  /// Usato quando vuoi forzare un re-hydration senza reinizializzare tutto.
  Future<void> restoreSessionFromStorage() async {
    if (!_usesManualFlow) return;
    _manualAccessToken = await _readStoredManualToken(_accessTokenStorageKey);
    _manualIdToken = await _readStoredManualToken(_idTokenStorageKey);
    _manualRefreshToken = await _readStoredManualToken(_refreshTokenStorageKey);
    _parseAndSetManualTokens();
  }

  /// Alias semantico per la UI: vero se l'utente e' autenticato.
  bool get isAuthenticated {
    if (_usesManualFlow) return _hasValidManualSession();
    return _mobileKeycloak?.accessToken != null &&
        _mobileKeycloak?.idToken != null;
  }

  String? get accessToken =>
      _usesManualFlow ? _manualAccessToken : _mobileKeycloak?.accessToken;

  String? get idToken =>
      _usesManualFlow ? _manualIdToken : _mobileKeycloak?.idToken;

  /// Payload JWT dell'access token, utile per claims/ruoli in UI.
  Map<String, dynamic>? get tokenParsed {
    if (_usesManualFlow) return _manualTokenParsed;
    if (_mobileKeycloak?.accessToken == null) return null;
    try {
      return JWT.decode(_mobileKeycloak!.accessToken!).payload;
    } catch (_) {
      return null;
    }
  }

  /// Payload JWT dell'id token, utile per dati utente/identita'.
  Map<String, dynamic>? get idTokenParsed {
    if (_usesManualFlow) return _manualIdTokenParsed;
    if (_mobileKeycloak?.idToken == null) return null;
    try {
      return JWT.decode(_mobileKeycloak!.idToken!).payload;
    } catch (_) {
      return null;
    }
  }

  /// Avvia login delegando al flusso specifico della piattaforma.
  Future<void> login() async {
    if (!_initialized) await init();

    // Un solo punto di ingresso pubblico, implementazioni diverse per piattaforma.
    if (kIsWeb) {
      await _webLogin();
      return;
    }
    if (_isDesktop) {
      await _desktopLogin();
      return;
    }
    await _ensureMobileInitialized();
    await _mobileKeycloak!.login();
  }

  /// Esegue logout locale + server secondo piattaforma.
  Future<void> logout() async {
    if (!_initialized) await init();

    // Un solo punto di ingresso pubblico, implementazioni diverse per piattaforma.
    if (kIsWeb) {
      await _webLogout();
      return;
    }
    if (_isDesktop) {
      await _desktopLogout();
      return;
    }
    await _ensureMobileInitialized();
    await _mobileKeycloak!.logout();
  }

  /// Tenta refresh token senza richiedere nuovo login interattivo.
  Future<bool> refreshToken() async {
    try {
      if (_usesManualFlow) {
        return await _refreshManualTokens();
      }
      await _ensureMobileInitialized();
      await _mobileKeycloak!.exchangeTokens(const Duration(seconds: 60));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Restituisce informazioni utente:
  /// - manual flow: claims del token locale
  /// - mobile: chiamata getUserInfo del wrapper
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      if (_usesManualFlow) return _manualTokenParsed;
      await _ensureMobileInitialized();
      return await _mobileKeycloak!.getUserInfo();
    } catch (_) {
      return null;
    }
  }

  /// Inizializza (o riusa) il client Keycloak mobile.
  ///
  /// Se init fallisce lancia eccezione per impedire login in stato incoerente.
  Future<void> _ensureMobileInitialized() async {
    if (_mobileKeycloak == null) {
      // Config del wrapper nativo (client/realm/server/bundle id).
      final config = KeycloakConfig(
        bundleIdentifier: KeycloakAppConfig.bundleIdentifier,
        clientId: KeycloakAppConfig.clientId,
        frontendUrl: KeycloakAppConfig.keycloakServerUrl,
        realm: KeycloakAppConfig.realm,
      );
      _mobileKeycloak = KeycloakWrapper(config: config);
      _mobileKeycloak!.onError = (message, error, stackTrace) {
        appLog('[KeycloakService.mobile] $message: $error');
      };
    }
    await _mobileKeycloak!.initialize();
    if (!_mobileKeycloak!.isInitialized) {
      throw Exception(
        'Keycloak mobile initialization failed. '
        'Clear app data (or uninstall/reinstall app) and retry login.',
      );
    }
  }

  /// Callback web: riceve `code`, valida stato PKCE/state e salva i token.
  Future<void> storeTokensFromCallback(String code) async {
    if (!kIsWeb) return;

    // Verifiche integrita' callback:
    // - code_verifier PKCE deve esistere e combaciare con authorize iniziale.
    // - state deve coincidere per mitigare CSRF/replay.
    // Su web usiamo sessionStorage per i dati temporanei PKCE:
    // sopravvivono al redirect OAuth ma non restano persistenti tra sessioni.
    final verifier = webPlatform.sessionStorageGetItem(_codeVerifierStorageKey);
    final expectedState = webPlatform.sessionStorageGetItem(
      _oauthStateStorageKey,
    );
    final callbackState = Uri.base.queryParameters['state'];

    if (verifier == null) {
      throw Exception('Code verifier not found in sessionStorage');
    }
    if (expectedState == null ||
        callbackState == null ||
        expectedState != callbackState) {
      throw Exception('Invalid OAuth state in web callback');
    }

    await _exchangeCodeForTokens(
      code: code,
      codeVerifier: verifier,
      redirectUri: KeycloakAppConfig.appRedirectUri,
      persistWebTokens: true,
    );

    webPlatform.sessionStorageRemoveItem(_codeVerifierStorageKey);
    webPlatform.sessionStorageRemoveItem(_oauthStateStorageKey);
    try {
      webPlatform.historyReplaceState('/');
    } catch (_) {}
  }

  Future<void> _webLogin() async {
    // Costruisce richiesta OAuth2 + PKCE e reindirizza il browser.
    final verifier = _generateCodeVerifier();
    final challenge = _generateCodeChallenge(verifier);
    final oauthState = _generateState();

    webPlatform.sessionStorageSetItem(_codeVerifierStorageKey, verifier);
    webPlatform.sessionStorageSetItem(_oauthStateStorageKey, oauthState);

    final authUrl = Uri.parse(KeycloakAppConfig.authEndpoint).replace(
      queryParameters: {
        'client_id': KeycloakAppConfig.clientId,
        'redirect_uri': KeycloakAppConfig.appRedirectUri,
        'response_type': KeycloakAppConfig.responseType,
        'scope': KeycloakAppConfig.scopes.join(' '),
        'state': oauthState,
        'code_challenge': challenge,
        'code_challenge_method': KeycloakAppConfig.codeChallengeMethod,
      },
    );

    webPlatform.setLocationHref(authUrl.toString());
  }

  Future<void> _webLogout() async {
    final idTokenHint = _manualIdToken;

    // Logout server best-effort per revoca refresh token.
    await _logoutOnServer(
      _manualRefreshToken ??
          webPlatform.sessionStorageGetItem(_refreshTokenStorageKey),
    );

    await _clearStoredManualTokens();
    webPlatform.sessionStorageRemoveItem(_codeVerifierStorageKey);
    webPlatform.sessionStorageRemoveItem(_oauthStateStorageKey);

    _clearManualTokens();

    // Logout browser-side della sessione SSO Keycloak.
    //
    // Compatibilita' Keycloak:
    // - provider recenti: `post_logout_redirect_uri`
    // - provider legacy: `redirect_uri`
    //
    // Se `post_logout_redirect_uri` non e' abilitato via config, inviamo
    // `redirect_uri` come fallback per evitare di restare sulla pagina
    // "You are logged out" a fine logout.
    final params = <String, String>{
      'client_id': KeycloakAppConfig.clientId,
    };
    if (idTokenHint != null && idTokenHint.isNotEmpty) {
      params['id_token_hint'] = idTokenHint;
    }
    if (KeycloakAppConfig.enablePostLogoutRedirect) {
      params['post_logout_redirect_uri'] = KeycloakAppConfig.appLogoutRedirectUri;
    } else {
      params['redirect_uri'] = KeycloakAppConfig.appHomeUri;
    }
    final endSessionUri = Uri.parse(
      KeycloakAppConfig.logoutEndpoint,
    ).replace(queryParameters: params);

    // Evita di portare l'utente sulla pagina Keycloak "You are logged out":
    // invia il logout SSO in background e lascia la navigazione alla UI Flutter.
    final backgroundSent = webPlatform.backgroundGet(endSessionUri.toString());
    if (!backgroundSent) {
      // Fallback difensivo: se il browser non consente iframe dinamico,
      // manteniamo il comportamento standard di redirect esplicito.
      webPlatform.setLocationHref(endSessionUri.toString());
    }
  }

  Future<void> _desktopLogin() async {
    // Desktop usa PKCE come il web, ma la callback e' catturata da listener locale
    // implementato in `runDesktopAuthorizationCodeFlow`.
    final verifier = _generateCodeVerifier();
    final challenge = _generateCodeChallenge(verifier);
    final oauthState = _generateState();
    final redirectUri = KeycloakAppConfig.appRedirectUri;

    final authUrl = Uri.parse(KeycloakAppConfig.authEndpoint).replace(
      queryParameters: {
        'client_id': KeycloakAppConfig.clientId,
        'redirect_uri': redirectUri,
        'response_type': KeycloakAppConfig.responseType,
        'scope': KeycloakAppConfig.scopes.join(' '),
        'state': oauthState,
        'code_challenge': challenge,
        'code_challenge_method': KeycloakAppConfig.codeChallengeMethod,
      },
    );

    final callbackUri = await runDesktopAuthorizationCodeFlow(
      authorizationUri: authUrl,
      redirectUri: Uri.parse(redirectUri),
    );

    final callbackState = callbackUri.queryParameters['state'];
    if (callbackState == null || callbackState != oauthState) {
      throw Exception('Invalid OAuth state in desktop callback');
    }

    final code = callbackUri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw Exception('Authorization code missing in desktop callback');
    }

    await _exchangeCodeForTokens(
      code: code,
      codeVerifier: verifier,
      redirectUri: redirectUri,
      persistWebTokens: false,
    );
  }

  Future<void> _desktopLogout() async {
    // Su desktop i token sono in memoria: dopo logout server puliamo stato locale.
    await _logoutOnServer(_manualRefreshToken);
    await _clearStoredManualTokens();
    _clearManualTokens();
  }

  Future<void> _exchangeCodeForTokens({
    required String code,
    required String codeVerifier,
    required String redirectUri,
    required bool persistWebTokens,
  }) async {
    // Scambio OAuth: authorization_code -> access/id/refresh tokens.
    final response = await http.post(
      Uri.parse(KeycloakAppConfig.tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': KeycloakAppConfig.grantType,
        'code': code,
        'client_id': KeycloakAppConfig.clientId,
        'redirect_uri': redirectUri,
        'code_verifier': codeVerifier,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Token exchange failed: ${response.statusCode} - ${response.body}',
      );
    }

    final tokenData = jsonDecode(response.body) as Map<String, dynamic>;
    _applyManualTokens(tokenData);
    if (persistWebTokens || _isDesktop) {
      await _persistManualTokens();
    }
  }

  Future<bool> _refreshManualTokens() async {
    // Se c'e' refresh token valido, rinnova sessione senza login interattivo.
    final refreshToken =
        _manualRefreshToken ??
        (kIsWeb
            ? webPlatform.sessionStorageGetItem(_refreshTokenStorageKey)
            : null);
    if (refreshToken == null || refreshToken.isEmpty) return false;

    final response = await http.post(
      Uri.parse(KeycloakAppConfig.tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'client_id': KeycloakAppConfig.clientId,
        'refresh_token': refreshToken,
      },
    );
    if (response.statusCode != 200) return false;

    final tokenData = jsonDecode(response.body) as Map<String, dynamic>;
    _applyManualTokens(tokenData);
    if (kIsWeb || _isDesktop) {
      await _persistManualTokens();
    }
    return true;
  }

  Future<void> _logoutOnServer(String? refreshToken) async {
    if (refreshToken == null || refreshToken.isEmpty) return;
    try {
      // Non bloccare UX in caso di errore rete/server durante logout remoto.
      await http
          .post(
            Uri.parse(KeycloakAppConfig.logoutEndpoint),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'client_id': KeycloakAppConfig.clientId,
              'refresh_token': refreshToken,
            },
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => http.Response('Timeout', 408),
          );
    } catch (_) {}
  }

  void _applyManualTokens(Map<String, dynamic> tokenData) {
    // Applica token raw e aggiorna anche i payload decodificati.
    _manualAccessToken = tokenData['access_token'] as String?;
    _manualIdToken = tokenData['id_token'] as String?;
    _manualRefreshToken = tokenData['refresh_token'] as String?;
    _parseAndSetManualTokens();
  }

  Future<void> _persistManualTokens() async {
    // Persistenza uniforme per manual flow (web + desktop).
    if (_manualAccessToken != null) {
      await _writeStoredManualToken(
        _accessTokenStorageKey,
        _manualAccessToken!,
      );
    }
    if (_manualIdToken != null) {
      await _writeStoredManualToken(_idTokenStorageKey, _manualIdToken!);
    }
    if (_manualRefreshToken != null && _manualRefreshToken!.isNotEmpty) {
      await _writeStoredManualToken(
        _refreshTokenStorageKey,
        _manualRefreshToken!,
      );
    }
  }

  void _parseAndSetManualTokens() {
    // Manteniamo payload JWT pre-parsato per controlli rapidi (es. exp/claims).
    _manualTokenParsed = _manualAccessToken != null
        ? _parseJwt(_manualAccessToken!)
        : null;
    _manualIdTokenParsed = _manualIdToken != null
        ? _parseJwt(_manualIdToken!)
        : null;
  }

  void _clearManualTokens() {
    // Reset completo dello stato auth locale.
    _manualAccessToken = null;
    _manualIdToken = null;
    _manualRefreshToken = null;
    _manualTokenParsed = null;
    _manualIdTokenParsed = null;
  }

  Future<String?> _readStoredManualToken(String key) async {
    if (kIsWeb) {
      // Su web evitiamo persistenza lunga in localStorage.
      // Nota: il refresh token non viene reidratato da storage per ridurre rischio.
      if (key == _refreshTokenStorageKey) return null;
      return webPlatform.sessionStorageGetItem(key);
    }
    if (_isDesktop) return _desktopStorage.read(key: key);
    return null;
  }

  Future<void> _writeStoredManualToken(String key, String value) async {
    if (kIsWeb) {
      // Access/ID token in sessionStorage (lifetime limitato alla scheda/sessione).
      // Refresh token non persistito su web per ridurre superficie d'attacco.
      if (key == _refreshTokenStorageKey) return;
      webPlatform.sessionStorageSetItem(key, value);
      return;
    }
    if (_isDesktop) {
      await _desktopStorage.write(key: key, value: value);
    }
  }

  Future<void> _clearStoredManualTokens() async {
    await _deleteStoredManualToken(_accessTokenStorageKey);
    await _deleteStoredManualToken(_idTokenStorageKey);
    await _deleteStoredManualToken(_refreshTokenStorageKey);
  }

  Future<void> _deleteStoredManualToken(String key) async {
    if (kIsWeb) {
      webPlatform.sessionStorageRemoveItem(key);
      return;
    }
    if (_isDesktop) {
      await _desktopStorage.delete(key: key);
    }
  }

  bool _hasValidManualSession() {
    // Sessione valida se access/id token presenti e access token non vicino a scadenza.
    // `tokenExpirationBuffer` evita race durante chiamate API imminenti.
    if (_manualAccessToken == null || _manualIdToken == null) return false;
    final exp = _manualTokenParsed?['exp'];
    if (exp is int) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final buffer = KeycloakAppConfig.tokenExpirationBuffer.inSeconds;
      return exp > (now + buffer);
    }
    return false;
  }

  String _generateCodeVerifier() {
    // PKCE code_verifier RFC 7636: stringa ad alta entropia.
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(
      KeycloakAppConfig.codeVerifierLength,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String _generateCodeChallenge(String verifier) {
    // PKCE code_challenge = BASE64URL(SHA256(code_verifier)).
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  String _generateState() {
    // Parametro `state` anti-CSRF per correlare authorize e callback.
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Map<String, dynamic>? _parseJwt(String token) {
    try {
      // Parsing JWT client-side: usato solo per leggere claims, NON per trust crittografico.
      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
