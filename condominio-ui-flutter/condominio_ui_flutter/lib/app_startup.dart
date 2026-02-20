import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'platform/web_platform.dart';
import 'providers/auth_provider.dart';
import 'providers/keycloak_provider.dart';
import 'utils/app_logger.dart';

/// Coordinatore bootstrap applicativo.
///
/// Responsabilita':
/// - diagnostica URL startup lato web
/// - inizializzazione Keycloak
/// - completamento callback OAuth2 (`code`) o ripristino sessione
class AppStartupCoordinator {
  AppStartupCoordinator(this.ref);

  final WidgetRef ref;

  /// Diagnostica startup solo web per debug callback/redirect.
  static void setupUrlMonitoring() {
    if (!kIsWeb) return;

    appLog('[APP_STARTUP] Setup monitor URL startup...');
    appLog('[APP_STARTUP] URL corrente: ${webPlatform.locationHref}');
    appLog('[APP_STARTUP] Pathname corrente: ${webPlatform.locationPathname}');
    appLog('[APP_STARTUP] Search corrente: ${webPlatform.locationSearch}');
  }

  /// Bootstrap stato auth all'avvio app.
  Future<void> initializeAuth() async {
    try {
      final keycloakService = ref.read(keycloakServiceProvider);
      final authNotifier = ref.read(authStateProvider.notifier);

      appLog('[APP_STARTUP] Step 1: inizializzazione Keycloak...');
      await keycloakService.init();
      appLog('[APP_STARTUP] Step 1: Keycloak inizializzato');

      final uri = Uri.base;
      final code = kIsWeb ? uri.queryParameters['code'] : null;
      final sessionState = kIsWeb ? uri.queryParameters['session_state'] : null;

      appLog('[APP_STARTUP] URL corrente: $uri');
      final codePreview = code == null
          ? null
          : (code.length > 10 ? '${code.substring(0, 10)}...' : code);
      appLog(
        '[APP_STARTUP] Query param code: '
        '${codePreview != null ? "PRESENTE ($codePreview)" : "ASSENTE"}',
      );
      appLog(
        '[APP_STARTUP] Query param session_state: '
        '${sessionState != null ? "PRESENTE" : "ASSENTE"}',
      );

      if (code != null && code.isNotEmpty) {
        appLog('[APP_STARTUP] Step 2a: trovato authorization code in URL');
        try {
          appLog('[APP_STARTUP] Step 3: exchange code -> token...');
          await authNotifier.processToken(code);
          appLog('[APP_STARTUP] Exchange token completato');
        } catch (e) {
          appLog('[APP_STARTUP] Exchange token fallito: $e');
        }
        return;
      }

      if (keycloakService.hasValidSession()) {
        appLog('[APP_STARTUP] Step 2b: sessione valida trovata');
        authNotifier.restoreSession();
        appLog('[APP_STARTUP] Sessione ripristinata');
        return;
      }

      appLog('[APP_STARTUP] Step 2c: nessun code callback e nessuna sessione');
    } catch (e) {
      appLog('[APP_STARTUP] Errore inizializzazione: $e');
    }
  }
}
