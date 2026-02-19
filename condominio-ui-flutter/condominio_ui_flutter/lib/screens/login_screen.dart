import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// SCHERMATA DI LOGIN
/// Mostra un bottone che avvia il flusso OAuth2 con Keycloak
/// 
/// ARCHITETTURA (con Riverpod):
/// - ConsumerWidget per accedere ai provider Riverpod
/// - Usa ref.read(authStateProvider.notifier).login() per avviare il login
/// - Il bottone rimane disabilitato durante il loading
///
/// FLUSSO quando clicca "Login":
/// 1. onClick → _handleLogin()
/// 2. _handleLogin() → ref.read(authStateProvider.notifier).login()
/// 3. AuthNotifier.login() → keycloak.login()
/// 4. login() genera un code_verifier casuale (per PKCE security)
/// 5. login() crea un URL verso Keycloak auth endpoint con code_challenge
/// 6. login() naviga a quell'URL (web.window.location.href = authUrl)
/// 7. Keycloak mostra il login form all'utente
/// 8. Dopo login su Keycloak, reindirizza a: http://localhost:8089/callback?code=xxx&session_state=yyy
/// 9. main.dart vede il code nei query params e chiama AuthNotifier.processToken(code)
/// 10. AuthNotifier.processToken() scambia il code per token
/// 11. AuthNotifier emette lo stato 'authenticated'
/// 12. Riverpod aggiorna la UI → MainApp mostra HomeScreen
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  /// Gestisce il click sul bottone Login
  /// Usa Riverpod per accedere ai provider di autenticazione
  void _handleLogin(WidgetRef ref) async {
    try {
      print('[LoginScreen] Starting OAuth2 flow with Keycloak...');
      
      // Accedi al notifier del provider authStateProvider
      // Questo ti dà accesso ai metodi login(), logout(), processToken()
      // ref.read() prende il valore una volta (non ascolta i cambiamenti)
      // ref.read(...notifier) accede agli ultimi metodi dello StateNotifier
      await ref.read(authStateProvider.notifier).login();
      
      print('[LoginScreen] Login redirect done, waiting for callback...');
    } catch (e) {
      print('[LoginScreen] Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ascolta lo stato di autenticazione per disabilitare il bottone durante il loading
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Condominio - Login')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Accedi con Keycloak',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              // Disabilita il bottone mentre il login è in corso (stato = loading)
              onPressed: isLoading ? null : () => _handleLogin(ref),
              child: Text(isLoading ? 'Authenticating...' : 'Login'),
            ),
          ],
        ),
      ),
    );
  }
}
