class ManagedCondominio {
  const ManagedCondominio({
    required this.id,
    required this.label,
    required this.anno,
    required this.saldoIniziale,
    required this.residuo,
  });

  final String id;
  final String label;
  final int anno;
  final double saldoIniziale;
  final double residuo;

  factory ManagedCondominio.fromJson(Map<String, dynamic> json) {
    return ManagedCondominio(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      anno: (json['anno'] as num?)?.toInt() ?? DateTime.now().year,
      saldoIniziale: (json['saldoIniziale'] as num?)?.toDouble() ?? 0,
      residuo: (json['residuo'] as num?)?.toDouble() ?? 0,
    );
  }
}
