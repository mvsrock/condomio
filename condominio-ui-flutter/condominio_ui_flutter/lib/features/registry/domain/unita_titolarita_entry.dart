class UnitaTitolaritaEntry {
  const UnitaTitolaritaEntry({
    required this.condominoId,
    required this.condominoRootId,
    required this.idCondominio,
    required this.nominativo,
    required this.titolaritaTipo,
    required this.statoPosizione,
    required this.dataIngresso,
    required this.dataUscita,
    required this.motivoUscita,
    required this.annoEsercizio,
    required this.gestioneCodice,
  });

  final String condominoId;
  final String? condominoRootId;
  final String idCondominio;
  final String nominativo;
  final String titolaritaTipo;
  final String statoPosizione;
  final DateTime? dataIngresso;
  final DateTime? dataUscita;
  final String? motivoUscita;
  final int? annoEsercizio;
  final String? gestioneCodice;

  factory UnitaTitolaritaEntry.fromJson(Map<String, dynamic> json) {
    return UnitaTitolaritaEntry(
      condominoId: (json['condominoId'] ?? '').toString(),
      condominoRootId: _normalizeOptional(json['condominoRootId']),
      idCondominio: (json['idCondominio'] ?? '').toString(),
      nominativo: (json['nominativo'] ?? '').toString(),
      titolaritaTipo: _normalizeEnumText(json['titolaritaTipo']),
      statoPosizione: _normalizeEnumText(json['statoPosizione']),
      dataIngresso: _parseDate(json['dataIngresso']),
      dataUscita: _parseDate(json['dataUscita']),
      motivoUscita: _normalizeOptional(json['motivoUscita']),
      annoEsercizio: (json['annoEsercizio'] as num?)?.toInt(),
      gestioneCodice: _normalizeOptional(json['gestioneCodice']),
    );
  }

  String get esercizioLabel {
    final year = annoEsercizio?.toString() ?? '-';
    final gestione = (gestioneCodice == null || gestioneCodice!.isEmpty)
        ? '-'
        : gestioneCodice!;
    return '$year / $gestione';
  }
}

String? _normalizeOptional(Object? value) {
  final normalized = (value ?? '').toString().trim();
  return normalized.isEmpty ? null : normalized;
}

String _normalizeEnumText(Object? value) {
  final raw = (value ?? '').toString().trim().toLowerCase();
  if (raw.isEmpty) return '';
  return raw.replaceAll('_', ' ');
}

DateTime? _parseDate(Object? raw) {
  if (raw == null) return null;
  final parsed = DateTime.tryParse(raw.toString());
  return parsed?.toLocal();
}

