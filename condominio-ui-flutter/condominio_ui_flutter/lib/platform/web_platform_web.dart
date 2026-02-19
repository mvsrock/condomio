import 'package:web/web.dart' as web;

/// Adapter web reale per API browser utilizzate dal flusso OAuth.
class WebPlatform {
  /// Legge una chiave da localStorage browser.
  String? localStorageGetItem(String key) {
    return web.window.localStorage.getItem(key);
  }

  /// Scrive una chiave in localStorage browser.
  void localStorageSetItem(String key, String value) {
    web.window.localStorage.setItem(key, value);
  }

  /// Rimuove una chiave da localStorage browser.
  void localStorageRemoveItem(String key) {
    web.window.localStorage.removeItem(key);
  }

  /// URL completo corrente.
  String get locationHref => web.window.location.href;

  /// Path corrente.
  String get locationPathname => web.window.location.pathname;

  /// Query string corrente.
  String get locationSearch => web.window.location.search;

  /// Redirect browser.
  void setLocationHref(String href) {
    web.window.location.href = href;
  }

  /// Sostituisce la URL in history senza reload.
  void historyReplaceState(String url) {
    web.window.history.replaceState(null, '', url);
  }
}

/// Singleton helper usato dal resto dell'app.
final webPlatform = WebPlatform();
