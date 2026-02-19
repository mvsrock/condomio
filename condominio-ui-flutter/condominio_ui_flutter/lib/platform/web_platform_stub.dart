/// Stub non-web per API browser.
///
/// Mantiene la stessa interfaccia di `web_platform_web.dart` ma con no-op,
/// cosi' il codice chiamante resta cross-platform senza `if` sparsi.
class WebPlatform {
  /// Simula read localStorage: su non-web non esiste storage browser.
  String? localStorageGetItem(String key) => null;

  /// Simula write localStorage.
  void localStorageSetItem(String key, String value) {}

  /// Simula remove localStorage.
  void localStorageRemoveItem(String key) {}

  /// URL corrente non disponibile su non-web.
  String get locationHref => '';

  /// Pathname corrente non disponibile su non-web.
  String get locationPathname => '';

  /// Query string corrente non disponibile su non-web.
  String get locationSearch => '';

  /// Simula redirect browser.
  void setLocationHref(String href) {}

  /// Simula replaceState.
  void historyReplaceState(String url) {}
}

/// Singleton helper usato dal resto dell'app.
final webPlatform = WebPlatform();
