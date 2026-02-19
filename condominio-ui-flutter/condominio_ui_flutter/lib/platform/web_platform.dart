// Export condizionale helper browser:
// - web reale: accesso a localStorage/location/history
// - stub: no-op per target non web
export 'web_platform_stub.dart'
    if (dart.library.js_interop) 'web_platform_web.dart';
