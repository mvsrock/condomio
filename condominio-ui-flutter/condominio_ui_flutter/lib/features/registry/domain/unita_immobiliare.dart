class UnitaImmobiliare {
  const UnitaImmobiliare({
    required this.id,
    required this.codice,
    required this.scala,
    required this.interno,
    required this.subalterno,
    required this.destinazioneUso,
    required this.metriQuadri,
  });

  final String id;
  final String codice;
  final String scala;
  final String interno;
  final String subalterno;
  final String destinazioneUso;
  final double? metriQuadri;

  UnitaImmobiliare copyWith({
    String? id,
    String? codice,
    String? scala,
    String? interno,
    String? subalterno,
    String? destinazioneUso,
    double? metriQuadri,
  }) {
    return UnitaImmobiliare(
      id: id ?? this.id,
      codice: codice ?? this.codice,
      scala: scala ?? this.scala,
      interno: interno ?? this.interno,
      subalterno: subalterno ?? this.subalterno,
      destinazioneUso: destinazioneUso ?? this.destinazioneUso,
      metriQuadri: metriQuadri ?? this.metriQuadri,
    );
  }

  factory UnitaImmobiliare.fromJson(Map<String, dynamic> json) {
    return UnitaImmobiliare(
      id: (json['id'] ?? '').toString(),
      codice: (json['codice'] ?? '').toString(),
      scala: (json['scala'] ?? '').toString(),
      interno: (json['interno'] ?? '').toString(),
      subalterno: (json['subalterno'] ?? '').toString(),
      destinazioneUso: (json['destinazioneUso'] ?? '').toString(),
      metriQuadri: (json['metriQuadri'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codice': codice,
      'scala': scala,
      'interno': interno,
      'subalterno': subalterno,
      'destinazioneUso': destinazioneUso,
      'metriQuadri': metriQuadri,
    };
  }

  String get label {
    final normalizedCodice = codice.trim();
    if (normalizedCodice.isNotEmpty) {
      return '$normalizedCodice (Scala $scala - Int. $interno)';
    }
    return 'Scala $scala - Int. $interno';
  }
}
