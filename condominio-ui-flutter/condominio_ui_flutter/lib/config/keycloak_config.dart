import 'package:flutter/foundation.dart';

/// CONFIGURAZIONE KEYCLOAK - Valori centralizzati
/// 
/// Tutte le configurazioni sono qui:
/// - Non valori hardcoded nel codice
/// - Facile da modificare in un posto solo
/// - Facile da gestire per env diversi (dev, staging, prod)
class KeycloakAppConfig {
  /// Profili supportati:
  /// - auto (default): web -> web, non-web -> android-emulator
  /// - web
  /// - android-emulator
  /// - android-device
  static const String _profile =
      String.fromEnvironment('APP_PROFILE', defaultValue: 'auto');

  /// Override opzionali via --dart-define (utile per CI o ambienti custom)
  static const String _serverUrlOverride =
      String.fromEnvironment('KEYCLOAK_SERVER_URL', defaultValue: '');
  static const String _redirectUriOverride =
      String.fromEnvironment('APP_REDIRECT_URI', defaultValue: '');
  static const String _logoutRedirectUriOverride =
      String.fromEnvironment('APP_LOGOUT_REDIRECT_URI', defaultValue: '');
  static const String _homeUriOverride =
      String.fromEnvironment('APP_HOME_URI', defaultValue: '');
  static const String _desktopRedirectUriOverride =
      String.fromEnvironment('APP_DESKTOP_REDIRECT_URI', defaultValue: '');
  static const String _bundleOverride =
      String.fromEnvironment('APP_BUNDLE_ID', defaultValue: '');
  static const String _clientIdOverride =
      String.fromEnvironment('KEYCLOAK_CLIENT_ID', defaultValue: '');
  static const String _realmOverride =
      String.fromEnvironment('KEYCLOAK_REALM', defaultValue: '');

  /// Keycloak realm e client
  static String get realm => _realmOverride.isNotEmpty ? _realmOverride : 'condominio';
  static String get clientId =>
      _clientIdOverride.isNotEmpty ? _clientIdOverride : 'condominio';

  /// Mobile app config (iOS/Android)
  static String get bundleIdentifier =>
      _bundleOverride.isNotEmpty ? _bundleOverride : 'it.mvs.condominiouiflutter';

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

  static String get keycloakServerUrl {
    if (_serverUrlOverride.isNotEmpty) return _serverUrlOverride;
    if (activeProfile == 'android-device') {
      throw StateError(
        'APP_PROFILE=android-device requires --dart-define=KEYCLOAK_SERVER_URL=http://<LAN_IP>:<PORT>',
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

  static String get appLogoutRedirectUri {
    if (_logoutRedirectUriOverride.isNotEmpty) return _logoutRedirectUriOverride;
    return switch (activeProfile) {
      'web' => 'http://localhost:8089/',
      _ => '$bundleIdentifier:/logout',
    };
  }

  static String get appHomeUri {
    if (_homeUriOverride.isNotEmpty) return _homeUriOverride;
    return switch (activeProfile) {
      'web' => 'http://localhost:8089',
      _ => appRedirectUri,
    };
  }

  /// OAuth2 endpoints (generati da keycloakServerUrl/realm)
  static String get authEndpoint =>
      '$keycloakServerUrl/realms/$realm/protocol/openid-connect/auth';

  static String get tokenEndpoint =>
      '$keycloakServerUrl/realms/$realm/protocol/openid-connect/token';

  static String get logoutEndpoint =>
      '$keycloakServerUrl/realms/$realm/protocol/openid-connect/logout';

  static String get userInfoEndpoint =>
      '$keycloakServerUrl/realms/$realm/protocol/openid-connect/userinfo';

  /// OAuth2 config
  static const String responseType = 'code';
  static const String grantType = 'authorization_code';
  static const List<String> scopes = ['openid', 'profile', 'email'];
  static const String codeChallengeMethod = 'S256';

  /// PKCE code verifier length (43-128 chars, RFC 7636)
  /// 64 = massima security senza essere troppo lungo
  static const int codeVerifierLength = 64;

  /// Token expiration check: refresh se expira in meno di 60 secondi
  static const Duration tokenExpirationBuffer = Duration(seconds: 60);
}
