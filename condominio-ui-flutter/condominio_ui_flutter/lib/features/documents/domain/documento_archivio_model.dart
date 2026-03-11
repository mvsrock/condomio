enum DocumentoCategoria {
  fattura,
  contratto,
  verbale,
  movimento,
  altro;

  String get backendValue => switch (this) {
    DocumentoCategoria.fattura => 'FATTURA',
    DocumentoCategoria.contratto => 'CONTRATTO',
    DocumentoCategoria.verbale => 'VERBALE',
    DocumentoCategoria.movimento => 'MOVIMENTO',
    DocumentoCategoria.altro => 'ALTRO',
  };

  String get label => switch (this) {
    DocumentoCategoria.fattura => 'Fattura',
    DocumentoCategoria.contratto => 'Contratto',
    DocumentoCategoria.verbale => 'Verbale',
    DocumentoCategoria.movimento => 'Movimento',
    DocumentoCategoria.altro => 'Altro',
  };
}

DocumentoCategoria documentoCategoriaFromBackend(String raw) {
  switch (raw.trim().toUpperCase()) {
    case 'FATTURA':
      return DocumentoCategoria.fattura;
    case 'CONTRATTO':
      return DocumentoCategoria.contratto;
    case 'VERBALE':
      return DocumentoCategoria.verbale;
    case 'MOVIMENTO':
      return DocumentoCategoria.movimento;
    default:
      return DocumentoCategoria.altro;
  }
}

class DocumentoArchivioModel {
  const DocumentoArchivioModel({
    required this.id,
    required this.idCondominio,
    required this.movimentoId,
    required this.categoria,
    required this.titolo,
    required this.descrizione,
    required this.originalFileName,
    required this.contentType,
    required this.sizeBytes,
    required this.documentGroupId,
    required this.versionNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByKeycloakUserId,
  });

  final String id;
  final String idCondominio;
  final String? movimentoId;
  final DocumentoCategoria categoria;
  final String titolo;
  final String? descrizione;
  final String originalFileName;
  final String contentType;
  final int sizeBytes;
  final String? documentGroupId;
  final int versionNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdByKeycloakUserId;

  bool get isLinkedToMovimento => (movimentoId ?? '').trim().isNotEmpty;

  factory DocumentoArchivioModel.fromJson(Map<String, dynamic> json) {
    return DocumentoArchivioModel(
      id: (json['id'] ?? '').toString(),
      idCondominio: (json['idCondominio'] ?? '').toString(),
      movimentoId: _normalizeNullableString(json['movimentoId']),
      categoria: documentoCategoriaFromBackend(
        (json['categoria'] ?? '').toString(),
      ),
      titolo: (json['titolo'] ?? '').toString(),
      descrizione: _normalizeNullableString(json['descrizione']),
      originalFileName: (json['originalFileName'] ?? '').toString(),
      contentType: (json['contentType'] ?? 'application/octet-stream').toString(),
      sizeBytes: _toInt(json['sizeBytes']),
      documentGroupId: _normalizeNullableString(json['documentGroupId']),
      versionNumber: _toInt(json['versionNumber'], fallback: 1),
      createdAt: _toDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
      updatedAt: _toDateTime(json['updatedAt']),
      createdByKeycloakUserId: _normalizeNullableString(
        json['createdByKeycloakUserId'],
      ),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static String? _normalizeNullableString(dynamic value) {
    final raw = value?.toString();
    if (raw == null) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
