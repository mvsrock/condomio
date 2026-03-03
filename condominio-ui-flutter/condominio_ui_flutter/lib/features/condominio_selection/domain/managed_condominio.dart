class ManagedCondominio {
  const ManagedCondominio({
    required this.id,
    required this.label,
    required this.anno,
    required this.residuo,
  });

  final String id;
  final String label;
  final int anno;
  final double residuo;

  factory ManagedCondominio.fromJson(Map<String, dynamic> json) {
    return ManagedCondominio(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      anno: (json['anno'] as num?)?.toInt() ?? DateTime.now().year,
      residuo: (json['residuo'] as num?)?.toDouble() ?? 0,
    );
  }
}
