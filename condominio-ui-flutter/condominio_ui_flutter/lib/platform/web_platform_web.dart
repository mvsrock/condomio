import 'package:web/web.dart' as web;

class WebPlatform {
  String? localStorageGetItem(String key) {
    return web.window.localStorage.getItem(key);
  }

  void localStorageSetItem(String key, String value) {
    web.window.localStorage.setItem(key, value);
  }

  void localStorageRemoveItem(String key) {
    web.window.localStorage.removeItem(key);
  }

  String get locationHref => web.window.location.href;

  String get locationPathname => web.window.location.pathname;

  String get locationSearch => web.window.location.search;

  void setLocationHref(String href) {
    web.window.location.href = href;
  }

  void historyReplaceState(String url) {
    web.window.history.replaceState(null, '', url);
  }
}

final webPlatform = WebPlatform();

