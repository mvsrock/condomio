import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

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
      print('[LoginScreen] Starting OAuth2 flow with Keycloak...');
      await ref.read(authStateProvider.notifier).login();
      print('[LoginScreen] Login redirect done, waiting for callback...');
    } catch (e) {
      print('[LoginScreen] Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stato auth osservato per disabilitare bottone durante loading.
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        // Sfondo hero della pagina login.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A3342), Color(0xFF155E75), Color(0xFF0F4C5C)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            // Limita larghezza card per mantenere layout pulito anche su desktop/web.
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icona brand.
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F0F4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Color(0xFF155E75),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Titolo prodotto.
                    const Text(
                      'Condominio',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Sottotitolo contesto auth.
                    const Text(
                      'Accesso sicuro con Keycloak',
                      style: TextStyle(fontSize: 15, color: Color(0xFF52606D)),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        // Click abilitato solo quando non stiamo gia' autenticando.
                        onPressed: isLoading ? null : () => _handleLogin(ref),
                        icon: const Icon(Icons.login),
                        label: Text(isLoading ? 'Autenticazione...' : 'Accedi'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF155E75),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
