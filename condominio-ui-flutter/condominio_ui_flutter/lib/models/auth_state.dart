/// Stati possibili della macchina di autenticazione UI.
///
/// Usato da Riverpod (`AuthNotifier`) per decidere quale schermata mostrare.
enum AuthState {
  /// Utente non autenticato: mostra LoginScreen.
  unauthenticated,

  /// Flusso di login in corso: mostra loading.
  loading,

  /// Utente autenticato: mostra HomeScreen.
  authenticated,

  /// Errore in fase auth: mostra schermata errore/retry.
  error;

  /// Helper per UI: true solo quando utente autenticato.
  bool get isAuthenticated => this == authenticated;

  /// Helper per UI: true solo quando e' in corso operazione auth.
  bool get isLoading => this == loading;

  /// Helper per UI: true solo in stato errore.
  bool get isError => this == error;
}

/// Modello semplice errore auth, utile per log/debug o messaggi estesi.
class AuthError {
  AuthError({required this.message, this.details});

  final String message;
  final String? details;

  @override
  String toString() => details != null ? '$message\n$details' : message;
}
