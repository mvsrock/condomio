/// Documento condominio (collection `condominio` backend).
class CondominioDocumentModel {
  const CondominioDocumentModel({
    required this.id,
    required this.version,
    required this.label,
    required this.anno,
    required this.configurazioniSpesa,
    required this.residuo,
  });

  final String id;
  final int version;
  final String label;
  final int anno;
  final List<ConfigurazioneSpesaModel> configurazioniSpesa;
  final double residuo;

  factory CondominioDocumentModel.fromJson(Map<String, dynamic> json) {
    return CondominioDocumentModel(
      id: json['id'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      anno: (json['anno'] as num?)?.toInt() ?? 0,
      configurazioniSpesa:
          (json['configurazioniSpesa'] as List<dynamic>? ?? const [])
              .map((e) => ConfigurazioneSpesaModel.fromJson(e as Map<String, dynamic>))
              .toList(growable: false),
      residuo: (json['residuo'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'label': label,
      'anno': anno,
      'configurazioniSpesa': configurazioniSpesa.map((e) => e.toJson()).toList(),
      'residuo': residuo,
    };
  }
}

class ConfigurazioneSpesaModel {
  const ConfigurazioneSpesaModel({
    required this.codice,
    required this.tabelle,
  });

  final String codice;
  final List<TabellaPercentualeModel> tabelle;

  factory ConfigurazioneSpesaModel.fromJson(Map<String, dynamic> json) {
    return ConfigurazioneSpesaModel(
      codice: json['codice'] as String? ?? '',
      tabelle: (json['tabelle'] as List<dynamic>? ?? const [])
          .map((e) => TabellaPercentualeModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codice': codice,
      'tabelle': tabelle.map((e) => e.toJson()).toList(),
    };
  }
}

class TabellaPercentualeModel {
  const TabellaPercentualeModel({
    required this.codice,
    required this.descrizione,
    required this.percentuale,
  });

  final String codice;
  final String descrizione;
  final int percentuale;

  factory TabellaPercentualeModel.fromJson(Map<String, dynamic> json) {
    return TabellaPercentualeModel(
      codice: json['codice'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      percentuale: (json['percentuale'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codice': codice,
      'descrizione': descrizione,
      'percentuale': percentuale,
    };
  }
}
