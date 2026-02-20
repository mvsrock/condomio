import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/auth_state.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

/// Router dichiarativo app-level basato su [AuthState].
///
/// Questo modulo e' separato dalla bootstrap logic:
/// - qui decidiamo "quale schermata mostrare"
/// - non facciamo inizializzazione servizi.
Widget buildHomeFromAuthState(AuthState authState, WidgetRef ref) {
  return switch (authState) {
    AuthState.authenticated => const HomeScreen(),
    AuthState.unauthenticated => const LoginScreen(),
    AuthState.loading => const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Autenticazione con Keycloak in corso...'),
          ],
        ),
      ),
    ),
    AuthState.error => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Errore autenticazione. Riprova.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(authStateProvider.notifier).resetAuthState();
              },
              child: const Text('Riprova'),
            ),
          ],
        ),
      ),
    ),
  };
}
