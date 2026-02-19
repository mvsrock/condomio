// Export condizionale per il flusso OAuth desktop:
// - su piattaforme IO usa implementazione reale (`desktop_auth_io.dart`)
// - su altre piattaforme usa stub che lancia UnsupportedError
export 'desktop_auth_stub.dart' if (dart.library.io) 'desktop_auth_io.dart';
