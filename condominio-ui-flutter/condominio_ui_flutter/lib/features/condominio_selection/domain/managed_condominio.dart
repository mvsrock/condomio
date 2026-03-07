class ManagedCondominio {
  const ManagedCondominio({
    required this.id,
    required this.condominioRootId,
    required this.label,
    required this.gestioneCode,
    required this.gestioneLabel,
    required this.anno,
    required this.saldoIniziale,
    required this.residuo,
    required this.stato,
  });

  final String id;
  final String condominioRootId;
  final String label;
  final String gestioneCode;
  final String gestioneLabel;
  final int anno;
  final double saldoIniziale;
  final double residuo;
  final String stato;

  bool get isClosed => stato.trim().toUpperCase() == 'CLOSED';

  String get statoLabel => isClosed ? 'Chiuso' : 'Aperto';

  String get displayLabel => '$label - $gestioneLabel - Esercizio $anno';

  factory ManagedCondominio.fromJson(Map<String, dynamic> json) {
    return ManagedCondominio(
      id: (json['id'] ?? '').toString(),
      condominioRootId: (json['condominioRootId'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      gestioneCode: (json['gestioneCodice'] ?? 'ordinaria').toString(),
      gestioneLabel: (json['gestioneLabel'] ?? 'Ordinaria').toString(),
      anno: (json['anno'] as num?)?.toInt() ?? DateTime.now().year,
      saldoIniziale: (json['saldoIniziale'] as num?)?.toDouble() ?? 0,
      residuo: (json['residuo'] as num?)?.toDouble() ?? 0,
      stato: (json['stato'] ?? 'OPEN').toString(),
    );
  }
}
