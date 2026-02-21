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

  /// Attesa minima in caso di errore refresh ma sessione ancora valida.
  ///
  /// Evita loop serrati di retry in scenari rete instabile.
  static const Duration _retryDelayOnRefreshError = Duration(seconds: 20);

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
  /// Effetto (modalita' near-expiry):
  /// - NON interroga Keycloak a cadenza fissa;
  /// - pianifica un timer one-shot al momento `exp - buffer`;
  /// - allo scatto, prova refresh solo se necessario.
  void _startAutoRefresh() {
    _scheduleRefreshNearExpiry();
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

  /// Pianifica il prossimo check refresh vicino a scadenza access token.
  ///
  /// Strategia:
  /// - se manca molto tempo: un solo timer fino alla refresh window;
  /// - se siamo gia' nella refresh window: esegue refresh subito.
  void _scheduleRefreshNearExpiry() {
    _refreshTimer?.cancel();
    if (state != AuthState.authenticated) return;

    final wait = _keycloakService.timeUntilRefreshWindow();
    if (wait == Duration.zero) {
      Future<void>.microtask(_refreshTick);
      return;
    }
    _refreshTimer = Timer(wait, _refreshTick);
  }

  /// Pianifica un retry controllato dopo errore refresh.
  void _scheduleRetryAfterRefreshError() {
    _refreshTimer?.cancel();
    if (state != AuthState.authenticated) return;
    _refreshTimer = Timer(_retryDelayOnRefreshError, _refreshTick);
  }

  /// Tick periodico refresh sessione.
  ///
  /// Comportamento:
  /// - evita re-entrancy se un refresh e' gia' in corso
  /// - se refresh fallisce e non c'e' sessione valida => logout tecnico
  Future<void> _refreshTick([Timer? _]) async {
    if (_refreshInProgress) return;
    if (state != AuthState.authenticated) return;

    _refreshInProgress = true;
    try {
      // Nessuna chiamata rete finche' non siamo vicini a `exp`.
      //
      // Importante:
      // - NON usiamo qui `hasValidSession()` come guardia "hard";
      // - nella refresh-window l'access token puo' risultare gia' "quasi scaduto"
      //   (per via del buffer) ma il refresh e' ancora perfettamente possibile.
      final shouldRefresh = _keycloakService.shouldRefreshSession();
      if (!shouldRefresh) {
        _scheduleRefreshNearExpiry();
        return;
      }

      // Siamo nella refresh-window: tentiamo refresh prima di dichiarare logout.
      final refreshed = await _keycloakService.refreshSession();
      if (refreshed) {
        // Dopo refresh ricalcoliamo la prossima finestra usando il nuovo exp.
        _scheduleRefreshNearExpiry();
        return;
      }

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
        _scheduleRetryAfterRefreshError();
      }
    } catch (e) {
      appLog('[AuthNotifier._refreshTick] Refresh error: $e');
      if (!_keycloakService.hasValidSession()) {
        _stopAutoRefresh();
        state = AuthState.unauthenticated;
      } else {
        _scheduleRetryAfterRefreshError();
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
