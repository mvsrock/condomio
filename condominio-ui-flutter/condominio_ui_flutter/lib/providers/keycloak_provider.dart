import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/keycloak_service.dart';

/// Provider singleton del servizio Keycloak.
///
/// Tutti i notifier/widget che devono fare operazioni auth leggono da qui,
/// evitando istanze duplicate del servizio.
final keycloakServiceProvider = Provider<KeycloakService>((ref) {
  return KeycloakService();
});
