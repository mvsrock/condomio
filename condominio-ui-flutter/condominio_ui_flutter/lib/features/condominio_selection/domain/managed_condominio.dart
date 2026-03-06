class ManagedCondominio {
  const ManagedCondominio({
    required this.id,
    required this.condominioRootId,
    required this.label,
    required this.anno,
    required this.saldoIniziale,
    required this.residuo,
    required this.stato,
  });

  final String id;
  final String condominioRootId;
  final String label;
  final int anno;
  final double saldoIniziale;
  final double residuo;
  final String stato;

  bool get isClosed => stato.trim().toUpperCase() == 'CLOSED';

  String get statoLabel => isClosed ? 'Chiuso' : 'Aperto';

  String get displayLabel => '$label - Esercizio $anno';

  factory ManagedCondominio.fromJson(Map<String, dynamic> json) {
    return ManagedCondominio(
      id: (json['id'] ?? '').toString(),
      condominioRootId: (json['condominioRootId'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      anno: (json['anno'] as num?)?.toInt() ?? DateTime.now().year,
      saldoIniziale: (json['saldoIniziale'] as num?)?.toDouble() ?? 0,
      residuo: (json['residuo'] as num?)?.toDouble() ?? 0,
      stato: (json['stato'] ?? 'OPEN').toString(),
    );
  }
}
