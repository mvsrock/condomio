import 'dart:convert';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Download browser basato su data URL.
///
/// Evita dipendenze extra e funziona in web desktop/mobile.
Future<bool> saveBytesToFile({
  required Uint8List bytes,
  required String fileName,
  required String contentType,
}) async {
  final base64 = base64Encode(bytes);
  final href = 'data:$contentType;base64,$base64';
  final anchor = web.HTMLAnchorElement()
    ..href = href
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  return true;
}

