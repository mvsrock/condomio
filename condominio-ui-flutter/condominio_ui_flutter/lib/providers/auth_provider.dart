import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../services/keycloak_service.dart';
import 'keycloak_provider.dart';

/// StateNotifier che governa la macchina a stati di autenticazione della UI.
///
/// Responsabilita':
/// - espone lo stato corrente (`AuthState`)
/// - gestisce transizioni login/logout/error
/// - coordina le operazioni con [KeycloakService]
class AuthNotifier extends StateNotifier<AuthState> {
  final KeycloakService _keycloakService;

  AuthNotifier(this._keycloakService) : super(AuthState.unauthenticated) {
    // Al bootstrap sincronizza subito lo stato con eventuale sessione gia' valida.
    _checkExistingSession();
  }

  /// Se esiste una sessione valida, evita passaggi inutili e porta subito a authenticated.
  Future<void> _checkExistingSession() async {
    try {
      final hasTokens = _keycloakService.hasValidSession();
      if (hasTokens) {
        print(
          '[AuthNotifier._checkExistingSession] Found valid session, setting to authenticated',
        );
        state = AuthState.authenticated;
      }
    } catch (e) {
      print('[AuthNotifier._checkExistingSession] Error checking session: $e');
      state = AuthState.error;
    }
  }

  /// Avvia il login e aggiorna lo stato in base all'esito del flusso.
  ///
  /// Nota:
  /// - Web: `login()` innesca redirect; il completamento avviene nel callback.
  /// - Mobile/Desktop: al ritorno dal browser possiamo gia' validare sessione.
  Future<void> login() async {
    try {
      state = AuthState.loading;
      print('[AuthNotifier.login] Starting login flow...');
      await _keycloakService.login();

      if (kIsWeb) {
        // Flusso web redirect-based: la transizione finale avviene nel callback.
        print(
          '[AuthNotifier.login] Login redirect done, waiting for web callback',
        );
      } else if (_keycloakService.hasValidSession()) {
        // Mobile/Desktop: in questo punto il token puo' gia' essere disponibile.
        state = AuthState.authenticated;
        print(
          '[AuthNotifier.login] Login complete on non-web, state = authenticated',
        );
      } else {
        state = AuthState.error;
        print('[AuthNotifier.login] Login completed without a valid session');
      }
    } catch (e) {
      print('[AuthNotifier.login] Login error: $e');
      state = AuthState.error;
    }
  }

  /// Completa login web: scambia authorization code con token e autentica sessione.
  ///
  /// Chiamato da `MainApp._initializeKeycloak()` quando il browser torna con `?code=...`.
  Future<void> processToken(String code) async {
    try {
      state = AuthState.loading;
      print('[AuthNotifier.processToken] Processing authorization code...');
      await _keycloakService.storeTokensFromCallback(code);
      print('[AuthNotifier.processToken] Token stored successfully');
      state = AuthState.authenticated;
    } catch (e) {
      print('[AuthNotifier.processToken] Token processing error: $e');
      state = AuthState.error;
    }
  }

  /// Esegue logout (locale/remoto tramite service) e riporta stato a unauthenticated.
  Future<void> logout() async {
    try {
      print('[AuthNotifier.logout] Logging out...');
      await _keycloakService.logout();
      print('[AuthNotifier.logout] Logout complete');
      state = AuthState.unauthenticated;
    } catch (e) {
      print('[AuthNotifier.logout] Logout error: $e');
      state = AuthState.error;
    }
  }

  /// Permette retry dopo errore auth senza riavviare l'app.
  void resetAuthState() {
    print('[AuthNotifier.resetAuthState] Resetting to unauthenticated');
    state = AuthState.unauthenticated;
  }

  /// Imposta stato autenticato dopo verifica positiva durante bootstrap.
  void restoreSession() {
    print('[AuthNotifier.restoreSession] Restoring authenticated session');
    state = AuthState.authenticated;
  }
}

/// Provider Riverpod che espone:
/// - valore stato corrente `AuthState` via `ref.watch(authStateProvider)`
/// - azioni `login/logout/processToken/...` via `ref.read(authStateProvider.notifier)`
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final keycloakService = ref.watch(keycloakServiceProvider);
  return AuthNotifier(keycloakService);
});
