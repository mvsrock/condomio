import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../utils/app_logger.dart';
import '../../application/auth_notifier.dart';
import '../widgets/login_hero_card.dart';

/// Schermata di accesso.
///
/// Ruolo nel flusso:
/// - mostra il pulsante Login
/// - invoca `AuthNotifier.login()` tramite Riverpod
/// - lascia al bootstrap in `main.dart` la gestione del callback web
///
/// FLUSSO STEP-BY-STEP (click su Login):
/// 1. Utente preme il pulsante -> `_handleLogin()`.
/// 2. `_handleLogin()` chiama `authStateProvider.notifier.login()`.
/// 3. Il notifier porta lo stato a `loading`.
/// 4. `KeycloakService.login()` avvia redirect/browser flow (o flusso mobile nativo).
/// 5. Al ritorno callback, `main.dart` completa il flusso con `processToken(...)`.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  /// Handler unico del pulsante login.
  ///
  /// Tutta la logica auth resta nel notifier; qui orchestration UI soltanto.
  void _handleLogin(WidgetRef ref) async {
    try {
      appLog('[LoginScreen] Starting OAuth2 flow with Keycloak...');
      await ref.read(authStateProvider.notifier).login();
      appLog('[LoginScreen] Login redirect done, waiting for callback...');
    } catch (e) {
      appLog('[LoginScreen] Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stato auth osservato per disabilitare bottone durante loading.
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A3342), Color(0xFF155E75), Color(0xFF0F4C5C)],
          ),
        ),
        child: Center(
          child: LoginHeroCard(
            isLoading: isLoading,
            onLoginPressed: () => _handleLogin(ref),
          ),
        ),
      ),
    );
  }
}
