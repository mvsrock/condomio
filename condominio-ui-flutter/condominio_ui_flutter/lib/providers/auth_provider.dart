import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_state.dart';
import '../services/keycloak_service.dart';
import '../utils/app_logger.dart';
import 'keycloak_provider.dart';

/// StateNotifier che governa la macchina a stati di autenticazione della UI.
///
/// Responsabilita':
/// - espone lo stato corrente (`AuthState`)
/// - gestisce transizioni login/logout/error
/// - coordina le operazioni con [KeycloakService]
class AuthNotifier extends StateNotifier<AuthState> {
  final KeycloakService _keycloakService;
  Timer? _refreshTimer;
  bool _refreshInProgress = false;

  /// Frequenza di controllo refresh sessione.
  ///
  /// Nota:
  /// - non refreshiamo ogni frame;
  /// - un polling leggero evita chiamate inutili e mantiene sessione viva.
  static const Duration _refreshInterval = Duration(seconds: 30);

  AuthNotifier(this._keycloakService) : super(AuthState.unauthenticated) {
    // Al bootstrap sincronizza subito lo stato con eventuale sessione gia' valida.
    _checkExistingSession();
  }

  /// Se esiste una sessione valida, evita passaggi inutili e porta subito a authenticated.
  Future<void> _checkExistingSession() async {
    try {
      final hasTokens = _keycloakService.hasValidSession();
      if (hasTokens) {
        appLog(
          '[AuthNotifier._checkExistingSession] Found valid session, setting to authenticated',
        );
        state = AuthState.authenticated;
        _startAutoRefresh();
      }
    } catch (e) {
      appLog('[AuthNotifier._checkExistingSession] Error checking session: $e');
      _stopAutoRefresh();
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
      appLog('[AuthNotifier.login] Starting login flow...');
      await _keycloakService.login();

      if (kIsWeb) {
        // Flusso web redirect-based: la transizione finale avviene nel callback.
        appLog(
          '[AuthNotifier.login] Login redirect done, waiting for web callback',
        );
      } else if (_keycloakService.hasValidSession()) {
        // Mobile/Desktop: in questo punto il token puo' gia' essere disponibile.
        state = AuthState.authenticated;
        _startAutoRefresh();
        appLog(
          '[AuthNotifier.login] Login complete on non-web, state = authenticated',
        );
      } else {
        _stopAutoRefresh();
        state = AuthState.error;
        appLog('[AuthNotifier.login] Login completed without a valid session');
      }
    } catch (e) {
      appLog('[AuthNotifier.login] Login error: $e');
      _stopAutoRefresh();
      state = AuthState.error;
    }
  }

  /// Completa login web: scambia authorization code con token e autentica sessione.
  ///
  /// Chiamato da `MainApp._initializeKeycloak()` quando il browser torna con `?code=...`.
  Future<void> processToken(String code) async {
    try {
      state = AuthState.loading;
      appLog('[AuthNotifier.processToken] Processing authorization code...');
      await _keycloakService.storeTokensFromCallback(code);
      appLog('[AuthNotifier.processToken] Token stored successfully');
      state = AuthState.authenticated;
      _startAutoRefresh();
    } catch (e) {
      appLog('[AuthNotifier.processToken] Token processing error: $e');
      _stopAutoRefresh();
      state = AuthState.error;
    }
  }

  /// Esegue logout (locale/remoto tramite service) e riporta stato a unauthenticated.
  Future<void> logout() async {
    try {
      appLog('[AuthNotifier.logout] Logging out...');
      _stopAutoRefresh();
      await _keycloakService.logout();
      appLog('[AuthNotifier.logout] Logout complete');
      state = AuthState.unauthenticated;
    } catch (e) {
      appLog('[AuthNotifier.logout] Logout error: $e');
      _stopAutoRefresh();
      state = AuthState.error;
    }
  }

  /// Permette retry dopo errore auth senza riavviare l'app.
  void resetAuthState() {
    appLog('[AuthNotifier.resetAuthState] Resetting to unauthenticated');
    _stopAutoRefresh();
    state = AuthState.unauthenticated;
  }

  /// Imposta stato autenticato dopo verifica positiva durante bootstrap.
  void restoreSession() {
    appLog('[AuthNotifier.restoreSession] Restoring authenticated session');
    state = AuthState.authenticated;
    _startAutoRefresh();
  }

  /// Avvia timer di refresh periodico della sessione.
  ///
  /// Trigger:
  /// - login completato
  /// - callback token processata
  /// - sessione ripristinata
  ///
  /// Effetto:
  /// - tenta `refreshSession()` a intervalli regolari
  /// - in caso di perdita sessione porta stato a unauthenticated
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => _refreshTick());
  }

  /// Ferma timer refresh.
  ///
  /// Trigger:
  /// - logout
  /// - reset auth
  /// - transizione a errore
  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _refreshInProgress = false;
  }

  /// Tick periodico refresh sessione.
  ///
  /// Comportamento:
  /// - evita re-entrancy se un refresh e' gia' in corso
  /// - se refresh fallisce e non c'e' sessione valida => logout tecnico
  Future<void> _refreshTick() async {
    if (_refreshInProgress) return;
    if (state != AuthState.authenticated) return;

    _refreshInProgress = true;
    try {
      final refreshed = await _keycloakService.refreshSession();
      if (refreshed) return;

      if (!_keycloakService.hasValidSession()) {
        appLog(
          '[AuthNotifier._refreshTick] Session expired and refresh failed -> unauthenticated',
        );
        _stopAutoRefresh();
        state = AuthState.unauthenticated;
      } else {
        appLog(
          '[AuthNotifier._refreshTick] Refresh failed but current session still valid',
        );
      }
    } catch (e) {
      appLog('[AuthNotifier._refreshTick] Refresh error: $e');
      if (!_keycloakService.hasValidSession()) {
        _stopAutoRefresh();
        state = AuthState.unauthenticated;
      }
    } finally {
      _refreshInProgress = false;
    }
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }
}

/// Provider Riverpod che espone:
/// - valore stato corrente `AuthState` via `ref.watch(authStateProvider)`
/// - azioni `login/logout/processToken/...` via `ref.read(authStateProvider.notifier)`
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final keycloakService = ref.watch(keycloakServiceProvider);
  return AuthNotifier(keycloakService);
});
