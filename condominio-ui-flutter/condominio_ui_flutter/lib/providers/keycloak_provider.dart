import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/keycloak_service.dart';

/// Provider per il servizio Keycloak
/// 
/// Ritorna un'istanza singleton di KeycloakService
/// Questo provider è usato dagli altri provider per accedere al servizio
final keycloakServiceProvider = Provider<KeycloakService>((ref) {
  return KeycloakService();
});
