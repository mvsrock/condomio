import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../services/keycloak_service.dart';
import 'keycloak_provider.dart';

/// StateNotifier per gestire lo stato di autenticazione
/// 
/// Responsabilità:
/// - Traccia lo stato corrente (authenticated, loading, error, unauthenticated)
/// - Fornisce metodi per login() e logout()
/// - Comunica con KeycloakService per le operazioni OAuth2
/// - Emette i cambiamenti di stato a Riverpod
class AuthNotifier extends StateNotifier<AuthState> {
  final KeycloakService _keycloakService;

  AuthNotifier(this._keycloakService) : super(AuthState.unauthenticated) {
    // Quando il notifier si inizializza, controlla se l'utente è già loggato
    _checkExistingSession();
  }

  /// Controlla se esiste già una sessione valida dal localStorage
  /// Se sì, passa a authenticated (SENZA reload di init, perché usato solo qui)
  Future<void> _checkExistingSession() async {
    try {
      // Carica i token da localStorage
      final hasTokens = _keycloakService.hasValidSession();
      if (hasTokens) {
        print('[AuthNotifier._checkExistingSession] Found valid session, setting to authenticated');
        state = AuthState.authenticated;
      }
    } catch (e) {
      print('[AuthNotifier._checkExistingSession] Error checking session: $e');
      state = AuthState.error;
    }
  }

  /// Avvia il flusso di login OAuth2
  /// 
  /// FLUSSO:
  /// 1. Setta stato a loading
  /// 2. Chiama _webLogin() che reindirizza a Keycloak
  /// 3. Quando l'utente torna dal callback, processToken() riporterà a authenticated
  Future<void> login() async {
    try {
      state = AuthState.loading;
      print('[AuthNotifier.login] Starting login flow...');
      await _keycloakService.login();
      if (kIsWeb) {
        print('[AuthNotifier.login] Login redirect done, waiting for web callback');
      } else if (_keycloakService.hasValidSession()) {
        state = AuthState.authenticated;
        print('[AuthNotifier.login] Login complete on non-web, state = authenticated');
      } else {
        state = AuthState.error;
        print('[AuthNotifier.login] Login completed without a valid session');
      }
    } catch (e) {
      print('[AuthNotifier.login] Login error: $e');
      state = AuthState.error;
    }
  }

  /// Processa il token ricevuto dal callback di Keycloak
  /// Chiamato da main.dart dopo che il code è stato estratto
  /// 
  /// FLUSSO:
  /// 1. Scambia il code per token
  /// 2. Salva i token in localStorage
  /// 3. Setta stato a authenticated (così le screenshows la HomeScreen)
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

  /// Logout e pulizia della sessione
  /// 
  /// FLUSSO:
  /// 1. Cancella i token da localStorage
  /// 2. Reindirizza a Keycloak logout endpoint (opzionale)
  /// 3. Setta stato a unauthenticated
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

  /// Resetta lo stato di autenticazione a 'unauthenticated'
  /// Usato quando l'utente vuole riprovare dopo un errore
  void resetAuthState() {
    print('[AuthNotifier.resetAuthState] Resetting to unauthenticated');
    state = AuthState.unauthenticated;
  }

  /// Ripristina lo stato a authenticated quando il token è trovato in localStorage
  /// Chiamato da main.dart quando init() trova token validi
  void restoreSession() {
    print('[AuthNotifier.restoreSession] Restoring authenticated session');
    state = AuthState.authenticated;
  }

}

/// Provider per lo stato di autenticazione
/// 
/// Questo provider usa StateNotifierProvider che:
/// 1. Crea un'istanza di AuthNotifier (che controlla la sessione esistente)
/// 2. Espone lo stato corrente (AuthState)
/// 3. Fornisce accesso ai metodi login(), logout(), processToken()
/// 
/// USO in una Widget:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// if (authState.isAuthenticated) {
///   return HomeScreen();
/// } else {
///   return LoginScreen();
/// }
/// ```
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final keycloakService = ref.watch(keycloakServiceProvider);
  return AuthNotifier(keycloakService);
});
