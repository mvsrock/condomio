import 'dart:typed_data';

/// Stub fallback: su target non supportati il download non e' disponibile.
Future<bool> saveBytesToFile({
  required Uint8List bytes,
  required String fileName,
  required String contentType,
}) async {
  return false;
}

