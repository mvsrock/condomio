double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

/// Snapshot preventivo/consuntivo di un esercizio.
class PreventivoSnapshotModel {
  const PreventivoSnapshotModel({
    required this.idCondominio,
    required this.anno,
    required this.gestioneCodice,
    required this.gestioneLabel,
    required this.statoEsercizio,
    required this.totalePreventivo,
    required this.totaleConsuntivo,
    required this.totaleDelta,
    required this.rows,
  });

  const PreventivoSnapshotModel.empty()
    : idCondominio = '',
      anno = 0,
      gestioneCodice = '',
      gestioneLabel = '',
      statoEsercizio = 'OPEN',
      totalePreventivo = 0,
      totaleConsuntivo = 0,
      totaleDelta = 0,
      rows = const [];

  final String idCondominio;
  final int anno;
  final String gestioneCodice;
  final String gestioneLabel;
  final String statoEsercizio;
  final double totalePreventivo;
  final double totaleConsuntivo;
  final double totaleDelta;
  final List<PreventivoRowModel> rows;

  bool get isEmpty => idCondominio.isEmpty && rows.isEmpty;

  factory PreventivoSnapshotModel.fromJson(Map<String, dynamic> json) {
    return PreventivoSnapshotModel(
      idCondominio: json['idCondominio'] as String? ?? '',
      anno: _toInt(json['anno']),
      gestioneCodice: json['gestioneCodice'] as String? ?? '',
      gestioneLabel: json['gestioneLabel'] as String? ?? '',
      statoEsercizio: json['statoEsercizio'] as String? ?? 'OPEN',
      totalePreventivo: _toDouble(json['totalePreventivo']),
      totaleConsuntivo: _toDouble(json['totaleConsuntivo']),
      totaleDelta: _toDouble(json['totaleDelta']),
      rows: (json['rows'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PreventivoRowModel.fromJson)
          .toList(growable: false),
    );
  }
}

/// Riga di confronto per coppia codice spesa + tabella.
class PreventivoRowModel {
  const PreventivoRowModel({
    required this.codiceSpesa,
    required this.codiceTabella,
    required this.descrizioneTabella,
    required this.preventivo,
    required this.consuntivo,
    required this.delta,
  });

  final String codiceSpesa;
  final String codiceTabella;
  final String descrizioneTabella;
  final double preventivo;
  final double consuntivo;
  final double delta;

  factory PreventivoRowModel.fromJson(Map<String, dynamic> json) {
    return PreventivoRowModel(
      codiceSpesa: json['codiceSpesa'] as String? ?? '',
      codiceTabella: json['codiceTabella'] as String? ?? '',
      descrizioneTabella: json['descrizioneTabella'] as String? ?? '',
      preventivo: _toDouble(json['preventivo']),
      consuntivo: _toDouble(json['consuntivo']),
      delta: _toDouble(json['delta']),
    );
  }
}
