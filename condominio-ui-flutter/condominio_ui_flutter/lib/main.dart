import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_startup.dart';
import 'config/keycloak_config.dart';
import 'main_app.dart';
import 'utils/app_logger.dart';

/// Entry-point minimale:
/// - log configurazione
/// - diagnostica web startup
/// - avvio app con `ProviderScope`
void main() {
  _logBootstrapConfig();
  AppStartupCoordinator.setupUrlMonitoring();
  runApp(const ProviderScope(child: MainApp()));
}

void _logBootstrapConfig() {
  appLog(
    '[CONFIG] profile=${KeycloakAppConfig.activeProfile} '
    'server=${KeycloakAppConfig.keycloakServerUrl} '
    'redirect=${KeycloakAppConfig.appRedirectUri}',
  );
}
