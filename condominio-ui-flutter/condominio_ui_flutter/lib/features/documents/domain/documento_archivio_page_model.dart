import 'documento_archivio_model.dart';

/// Pagina archivio documentale con metadati di navigazione server-side.
class DocumentoArchivioPageModel {
  const DocumentoArchivioPageModel({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  final List<DocumentoArchivioModel> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
}
