import 'dart:typed_data';

/// Payload binario documento scaricato dal backend.
///
/// Viene usato per la preview in-app senza passare da URL pubblici.
class DocumentoDownloadModel {
  const DocumentoDownloadModel({
    required this.fileName,
    required this.contentType,
    required this.bytes,
  });

  final String fileName;
  final String contentType;
  final Uint8List bytes;
}
