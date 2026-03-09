/// Documento movimento (collection `movimenti` backend).
class MovimentoModel {
  const MovimentoModel({
    required this.id,
    required this.version,
    required this.idCondominio,
    required this.codiceSpesa,
    required this.tipoRiparto,
    required this.descrizione,
    required this.importo,
    required this.date,
    required this.insertedAt,
    required this.ripartizioneTabelle,
    required this.ripartizioneCondomini,
  });

  final String id;
  final int version;
  final String idCondominio;
  final String codiceSpesa;
  final MovimentoRipartoTipo tipoRiparto;
  final String descrizione;
  final double importo;
  final DateTime date;
  final DateTime insertedAt;
  final List<RipartizioneTabellaModel> ripartizioneTabelle;
  final List<RipartizioneCondominoModel> ripartizioneCondomini;

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
      tipoRiparto: MovimentoRipartoTipoX.fromBackend(
        json['tipoRiparto'] as String?,
      ),
      descrizione: json['descrizione'] as String? ?? '',
      importo: (json['importo'] as num?)?.toDouble() ?? 0,
      date: parseDate('date'),
      insertedAt: parseDate('insertedAt'),
      ripartizioneTabelle:
          (json['ripartizioneTabelle'] as List<dynamic>? ?? const [])
              .map((e) => RipartizioneTabellaModel.fromJson(e as Map<String, dynamic>))
              .toList(growable: false),
      ripartizioneCondomini:
          (json['ripartizioneCondomini'] as List<dynamic>? ?? const [])
              .map(
                (e) =>
                    RipartizioneCondominoModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(growable: false),
    );
  }
}

/// Tipo riparto movimento usato in FE.
enum MovimentoRipartoTipo { condominiale, individuale }

extension MovimentoRipartoTipoX on MovimentoRipartoTipo {
  static MovimentoRipartoTipo fromBackend(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'INDIVIDUALE':
        return MovimentoRipartoTipo.individuale;
      case 'CONDOMINIALE':
      default:
        return MovimentoRipartoTipo.condominiale;
    }
  }

  String get backendValue {
    switch (this) {
      case MovimentoRipartoTipo.individuale:
        return 'INDIVIDUALE';
      case MovimentoRipartoTipo.condominiale:
        return 'CONDOMINIALE';
    }
  }

  String get label {
    switch (this) {
      case MovimentoRipartoTipo.individuale:
        return 'Individuale';
      case MovimentoRipartoTipo.condominiale:
        return 'Condominiale';
    }
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

class RipartizioneCondominoModel {
  const RipartizioneCondominoModel({
    required this.idCondomino,
    required this.nominativo,
    required this.importo,
  });

  final String idCondomino;
  final String nominativo;
  final double importo;

  factory RipartizioneCondominoModel.fromJson(Map<String, dynamic> json) {
    return RipartizioneCondominoModel(
      idCondomino: json['idCondomino'] as String? ?? '',
      nominativo: json['nominativo'] as String? ?? '',
      importo: (json['importo'] as num?)?.toDouble() ?? 0,
    );
  }
}
