class WebPlatform {
  String? localStorageGetItem(String key) => null;

  void localStorageSetItem(String key, String value) {}

  void localStorageRemoveItem(String key) {}

  String get locationHref => '';

  String get locationPathname => '';

  String get locationSearch => '';

  void setLocationHref(String href) {}

  void historyReplaceState(String url) {}
}

final webPlatform = WebPlatform();

