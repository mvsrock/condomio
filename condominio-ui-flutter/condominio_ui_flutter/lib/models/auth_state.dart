/// Modello dello stato di autenticazione
/// 
/// Rappresenta gli stati possibili dell'autenticazione:
/// - AuthState.unauthenticated: Utente non loggato (stato iniziale)
/// - AuthState.loading: Login in corso, aspetta Keycloak
/// - AuthState.authenticated: Utente loggato, token disponibili
/// - AuthState.error: Errore durante il login
enum AuthState {
  /// Utente non autenticato, mostra LoginScreen
  unauthenticated,
  
  /// Login in corso (redirect a Keycloak), mostra loading spinner
  loading,
  
  /// Utente autenticato, mostra HomeScreen con token
  authenticated,
  
  /// Errore durante l'autenticazione, mostra messaggio di errore
  error;

  /// Ritorna true se lo stato è authenticated
  bool get isAuthenticated => this == authenticated;
  
  /// Ritorna true se lo stato è loading
  bool get isLoading => this == loading;
  
  /// Ritorna true se lo stato è error
  bool get isError => this == error;
}

/// Classe che rappresenta un errore di autenticazione
class AuthError {
  final String message;
  final String? details;

  AuthError({
    required this.message,
    this.details,
  });

  @override
  String toString() => details != null ? '$message\n$details' : message;
}
