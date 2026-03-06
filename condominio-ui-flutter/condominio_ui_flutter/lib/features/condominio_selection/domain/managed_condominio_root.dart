class ManagedCondominioRoot {
  const ManagedCondominioRoot({required this.id, required this.label});

  final String id;
  final String label;

  factory ManagedCondominioRoot.fromJson(Map<String, dynamic> json) {
    return ManagedCondominioRoot(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
    );
  }
}
