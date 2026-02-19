import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:keycloak_wrapper/keycloak_wrapper.dart'
    show JWT, KeycloakConfig, KeycloakWrapper;

import '../config/keycloak_config.dart';
import '../platform/desktop_auth.dart';
import '../platform/web_platform.dart';

class KeycloakService {
  static final KeycloakService _instance = KeycloakService._internal();

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

  Future<void> init() async {
    if (_initialized) return;

    if (_usesManualFlow) {
      if (kIsWeb) {
        _manualAccessToken = webPlatform.localStorageGetItem(_accessTokenStorageKey);
        _manualIdToken = webPlatform.localStorageGetItem(_idTokenStorageKey);
        _manualRefreshToken = webPlatform.localStorageGetItem(_refreshTokenStorageKey);
        _parseAndSetManualTokens();
      }
    } else {
      await _ensureMobileInitialized();
    }

    _initialized = true;
  }

  bool hasValidSession() {
    if (_usesManualFlow) return _hasValidManualSession();
    return _mobileKeycloak?.accessToken != null && _mobileKeycloak?.idToken != null;
  }

  void restoreSessionFromStorage() {
    if (!kIsWeb) return;
    _manualAccessToken = webPlatform.localStorageGetItem(_accessTokenStorageKey);
    _manualIdToken = webPlatform.localStorageGetItem(_idTokenStorageKey);
    _manualRefreshToken = webPlatform.localStorageGetItem(_refreshTokenStorageKey);
    _parseAndSetManualTokens();
  }

  bool get isAuthenticated {
    if (_usesManualFlow) return _hasValidManualSession();
    return _mobileKeycloak?.accessToken != null && _mobileKeycloak?.idToken != null;
  }

  String? get accessToken => _usesManualFlow ? _manualAccessToken : _mobileKeycloak?.accessToken;

  String? get idToken => _usesManualFlow ? _manualIdToken : _mobileKeycloak?.idToken;

  Map<String, dynamic>? get tokenParsed {
    if (_usesManualFlow) return _manualTokenParsed;
    if (_mobileKeycloak?.accessToken == null) return null;
    try {
      return JWT.decode(_mobileKeycloak!.accessToken!).payload;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? get idTokenParsed {
    if (_usesManualFlow) return _manualIdTokenParsed;
    if (_mobileKeycloak?.idToken == null) return null;
    try {
      return JWT.decode(_mobileKeycloak!.idToken!).payload;
    } catch (_) {
      return null;
    }
  }

  Future<void> login() async {
    if (!_initialized) await init();

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

  Future<void> logout() async {
    if (!_initialized) await init();

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

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      if (_usesManualFlow) return _manualTokenParsed;
      await _ensureMobileInitialized();
      return await _mobileKeycloak!.getUserInfo();
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureMobileInitialized() async {
    if (_mobileKeycloak == null) {
      final config = KeycloakConfig(
        bundleIdentifier: KeycloakAppConfig.bundleIdentifier,
        clientId: KeycloakAppConfig.clientId,
        frontendUrl: KeycloakAppConfig.keycloakServerUrl,
        realm: KeycloakAppConfig.realm,
      );
      _mobileKeycloak = KeycloakWrapper(config: config);
      _mobileKeycloak!.onError = (message, error, stackTrace) {
        print('[KeycloakService.mobile] $message: $error');
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

  Future<void> storeTokensFromCallback(String code) async {
    if (!kIsWeb) return;

    final verifier = webPlatform.localStorageGetItem(_codeVerifierStorageKey);
    final expectedState = webPlatform.localStorageGetItem(_oauthStateStorageKey);
    final callbackState = Uri.base.queryParameters['state'];

    if (verifier == null) {
      throw Exception('Code verifier not found in localStorage');
    }
    if (expectedState == null || callbackState == null || expectedState != callbackState) {
      throw Exception('Invalid OAuth state in web callback');
    }

    await _exchangeCodeForTokens(
      code: code,
      codeVerifier: verifier,
      redirectUri: KeycloakAppConfig.appRedirectUri,
      persistWebTokens: true,
    );

    webPlatform.localStorageRemoveItem(_codeVerifierStorageKey);
    webPlatform.localStorageRemoveItem(_oauthStateStorageKey);
    try {
      webPlatform.historyReplaceState('/');
    } catch (_) {}
  }

  Future<void> _webLogin() async {
    final verifier = _generateCodeVerifier();
    final challenge = _generateCodeChallenge(verifier);
    final oauthState = _generateState();

    webPlatform.localStorageSetItem(_codeVerifierStorageKey, verifier);
    webPlatform.localStorageSetItem(_oauthStateStorageKey, oauthState);

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
    await _logoutOnServer(_manualRefreshToken ?? webPlatform.localStorageGetItem(_refreshTokenStorageKey));

    webPlatform.localStorageRemoveItem(_accessTokenStorageKey);
    webPlatform.localStorageRemoveItem(_idTokenStorageKey);
    webPlatform.localStorageRemoveItem(_refreshTokenStorageKey);
    webPlatform.localStorageRemoveItem(_codeVerifierStorageKey);
    webPlatform.localStorageRemoveItem(_oauthStateStorageKey);

    _clearManualTokens();
    webPlatform.setLocationHref(KeycloakAppConfig.appHomeUri);
  }

  Future<void> _desktopLogin() async {
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
    await _logoutOnServer(_manualRefreshToken);
    _clearManualTokens();
  }

  Future<void> _exchangeCodeForTokens({
    required String code,
    required String codeVerifier,
    required String redirectUri,
    required bool persistWebTokens,
  }) async {
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
      throw Exception('Token exchange failed: ${response.statusCode} - ${response.body}');
    }

    final tokenData = jsonDecode(response.body) as Map<String, dynamic>;
    _applyManualTokens(tokenData);
    if (persistWebTokens) _persistWebTokens();
  }

  Future<bool> _refreshManualTokens() async {
    final refreshToken = _manualRefreshToken ??
        (kIsWeb ? webPlatform.localStorageGetItem(_refreshTokenStorageKey) : null);
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
    if (kIsWeb) _persistWebTokens();
    return true;
  }

  Future<void> _logoutOnServer(String? refreshToken) async {
    if (refreshToken == null || refreshToken.isEmpty) return;
    try {
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
    _manualAccessToken = tokenData['access_token'] as String?;
    _manualIdToken = tokenData['id_token'] as String?;
    _manualRefreshToken = tokenData['refresh_token'] as String?;
    _parseAndSetManualTokens();
  }

  void _persistWebTokens() {
    if (_manualAccessToken != null) {
      webPlatform.localStorageSetItem(_accessTokenStorageKey, _manualAccessToken!);
    }
    if (_manualIdToken != null) {
      webPlatform.localStorageSetItem(_idTokenStorageKey, _manualIdToken!);
    }
    if (_manualRefreshToken != null && _manualRefreshToken!.isNotEmpty) {
      webPlatform.localStorageSetItem(_refreshTokenStorageKey, _manualRefreshToken!);
    }
  }

  void _parseAndSetManualTokens() {
    _manualTokenParsed = _manualAccessToken != null ? _parseJwt(_manualAccessToken!) : null;
    _manualIdTokenParsed = _manualIdToken != null ? _parseJwt(_manualIdToken!) : null;
  }

  void _clearManualTokens() {
    _manualAccessToken = null;
    _manualIdToken = null;
    _manualRefreshToken = null;
    _manualTokenParsed = null;
    _manualIdTokenParsed = null;
  }

  bool _hasValidManualSession() {
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
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(
      KeycloakAppConfig.codeVerifierLength,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  String _generateState() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Map<String, dynamic>? _parseJwt(String token) {
    try {
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
