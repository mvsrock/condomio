/// Modello tabella millesimale (collection `tabelle` backend).
class TabellaModel {
  const TabellaModel({
    required this.id,
    required this.version,
    required this.codice,
    required this.descrizione,
    required this.idCondominio,
  });

  final String id;
  final int version;
  final String codice;
  final String descrizione;
  final String idCondominio;

  factory TabellaModel.fromJson(Map<String, dynamic> json) {
    return TabellaModel(
      id: json['id'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      codice: json['codice'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      idCondominio: json['idCondominio'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'codice': codice,
      'descrizione': descrizione,
      'idCondominio': idCondominio,
    };
  }
}
