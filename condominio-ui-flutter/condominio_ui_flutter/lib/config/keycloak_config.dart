import 'package:flutter/foundation.dart';

/// Configurazione centralizzata Keycloak/OAuth.
///
/// Obiettivi:
/// - evitare valori hardcoded sparsi
/// - supportare profili multipiattaforma con `--dart-define`
/// - calcolare endpoint e redirect in un solo punto
class KeycloakAppConfig {
  /// Profilo applicativo attivo.
  ///
  /// Valori supportati:
  /// - auto (default): decide in base alla piattaforma
  /// - web
  /// - android-emulator
  /// - android-device
  /// - ios
  /// - desktop
  static const String _profile = String.fromEnvironment(
    'APP_PROFILE',
    defaultValue: 'auto',
  );

  /// Override opzionali via `--dart-define`.
  ///
  /// Permettono di cambiare configurazione senza modificare il codice.
  static const String _serverUrlOverride = String.fromEnvironment(
    'KEYCLOAK_SERVER_URL',
    defaultValue: '',
  );
  static const String _redirectUriOverride = String.fromEnvironment(
    'APP_REDIRECT_URI',
    defaultValue: '',
  );
  static const String _logoutRedirectUriOverride = String.fromEnvironment(
    'APP_LOGOUT_REDIRECT_URI',
    defaultValue: '',
  );
  static const String _homeUriOverride = String.fromEnvironment(
    'APP_HOME_URI',
    defaultValue: '',
  );
  static const String _desktopRedirectUriOverride = String.fromEnvironment(
    'APP_DESKTOP_REDIRECT_URI',
    defaultValue: '',
  );
  static const String _bundleOverride = String.fromEnvironment(
    'APP_BUNDLE_ID',
    defaultValue: '',
  );
  static const String _clientIdOverride = String.fromEnvironment(
    'KEYCLOAK_CLIENT_ID',
    defaultValue: '',
  );
  static const String _realmOverride = String.fromEnvironment(
    'KEYCLOAK_REALM',
    defaultValue: '',
  );

  /// Nome realm Keycloak.
  static String get realm =>
      _realmOverride.isNotEmpty ? _realmOverride : 'condominio';

  /// Client ID Keycloak.
  static String get clientId =>
      _clientIdOverride.isNotEmpty ? _clientIdOverride : 'condominio';

  /// Identificatore app mobile (used for custom URI scheme).
  static String get bundleIdentifier => _bundleOverride.isNotEmpty
      ? _bundleOverride
      : 'it.mvs.condominiouiflutter';

  /// Profilo risolto finale.
  ///
  /// Se `APP_PROFILE` e' `auto`, deduce il profilo dalla piattaforma runtime.
  static String get activeProfile {
    if (_profile != 'auto') return _profile;
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android-emulator',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.windows => 'desktop',
      TargetPlatform.linux => 'desktop',
      TargetPlatform.macOS => 'desktop',
      _ => 'desktop',
    };
  }

  /// URL base server Keycloak.
  ///
  /// Nota: per `android-device` richiede override esplicito LAN IP.
  static String get keycloakServerUrl {
    if (_serverUrlOverride.isNotEmpty) return _serverUrlOverride;
    if (activeProfile == 'android-device') {
      throw StateError(
        'APP_PROFILE=android-device richiede --dart-define=KEYCLOAK_SERVER_URL=http://<LAN_IP>:<PORT>',
      );
    }
    return switch (activeProfile) {
      'web' => 'http://localhost:8082',
      'android-emulator' => 'http://10.0.2.2:8082',
      'desktop' => 'http://localhost:8082',
      'ios' => 'http://localhost:8082',
      _ => 'http://localhost:8082',
    };
  }

  /// Redirect URI applicativo usato nel flusso OAuth login.
  static String get appRedirectUri {
    if (_redirectUriOverride.isNotEmpty) return _redirectUriOverride;
    if (activeProfile == 'desktop' && _desktopRedirectUriOverride.isNotEmpty) {
      return _desktopRedirectUriOverride;
    }
    return switch (activeProfile) {
      'web' => 'http://localhost:8089/callback',
      'desktop' => 'http://127.0.0.1:47899/callback',
      _ => '$bundleIdentifier:/oauthredirect',
    };
  }

  /// Redirect URI di ritorno dopo logout.
  static String get appLogoutRedirectUri {
    if (_logoutRedirectUriOverride.isNotEmpty) {
      return _logoutRedirectUriOverride;
    }
    return switch (activeProfile) {
      'web' => 'http://localhost:8089/',
      _ => '$bundleIdentifier:/logout',
    };
  }

  /// Home URI locale applicazione (usata dopo logout web).
  static String get appHomeUri {
    if (_homeUriOverride.isNotEmpty) return _homeUriOverride;
    return switch (activeProfile) {
      'web' => 'http://localhost:8089',
      _ => appRedirectUri,
    };
  }

  /// Endpoint OAuth/OpenID costruiti da `keycloakServerUrl` + `realm`.
  static String get authEndpoint =>
      '$keycloakServerUrl/realms/$realm/protocol/openid-connect/auth';

  static String get tokenEndpoint =>
      '$keycloakServerUrl/realms/$realm/protocol/openid-connect/token';

  static String get logoutEndpoint =>
      '$keycloakServerUrl/realms/$realm/protocol/openid-connect/logout';

  static String get userInfoEndpoint =>
      '$keycloakServerUrl/realms/$realm/protocol/openid-connect/userinfo';

  /// Parametri OAuth.
  static const String responseType = 'code';
  static const String grantType = 'authorization_code';
  static const List<String> scopes = ['openid', 'profile', 'email'];
  static const String codeChallengeMethod = 'S256';

  /// Lunghezza code verifier PKCE (RFC 7636: tra 43 e 128).
  static const int codeVerifierLength = 64;

  /// Margine sicurezza sul controllo scadenza token.
  static const Duration tokenExpirationBuffer = Duration(seconds: 60);
}
