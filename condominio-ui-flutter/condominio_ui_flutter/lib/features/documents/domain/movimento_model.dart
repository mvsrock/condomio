/// Documento movimento (collection `movimenti` backend).
class MovimentoModel {
  const MovimentoModel({
    required this.id,
    required this.version,
    required this.idCondominio,
    required this.codiceSpesa,
    required this.descrizione,
    required this.importo,
    required this.date,
    required this.insertedAt,
    required this.ripartizioneTabelle,
  });

  final String id;
  final int version;
  final String idCondominio;
  final String codiceSpesa;
  final String descrizione;
  final double importo;
  final DateTime date;
  final DateTime insertedAt;
  final List<RipartizioneTabellaModel> ripartizioneTabelle;

  factory MovimentoModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String key) {
      final raw = json[key];
      if (raw is String && raw.isNotEmpty) {
        return DateTime.tryParse(raw)?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      }
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return MovimentoModel(
      id: json['id'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      idCondominio: json['idCondominio'] as String? ?? '',
      codiceSpesa: json['codiceSpesa'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      importo: (json['importo'] as num?)?.toDouble() ?? 0,
      date: parseDate('date'),
      insertedAt: parseDate('insertedAt'),
      ripartizioneTabelle:
          (json['ripartizioneTabelle'] as List<dynamic>? ?? const [])
              .map((e) => RipartizioneTabellaModel.fromJson(e as Map<String, dynamic>))
              .toList(growable: false),
    );
  }
}

class RipartizioneTabellaModel {
  const RipartizioneTabellaModel({
    required this.codice,
    required this.descrizione,
    required this.importo,
  });

  final String codice;
  final String descrizione;
  final double importo;

  factory RipartizioneTabellaModel.fromJson(Map<String, dynamic> json) {
    return RipartizioneTabellaModel(
      codice: json['codice'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      importo: (json['importo'] as num?)?.toDouble() ?? 0,
    );
  }
}
