import 'dart:typed_data';

/// Export condizionale download file:
/// - web: trigger download browser
/// - io: save dialog locale
/// - stub: no-op (target non supportati)
export 'file_download_stub.dart'
    if (dart.library.js_interop) 'file_download_web.dart'
    if (dart.library.io) 'file_download_io.dart';

/// Contratto comune usato dai dialog FE.
typedef SaveBytesToFile = Future<bool> Function({
  required Uint8List bytes,
  required String fileName,
  required String contentType,
});

