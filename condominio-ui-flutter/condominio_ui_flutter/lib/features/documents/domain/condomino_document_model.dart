/// Documento condomino (collection `condomino` backend).
class CondominoDocumentModel {
  const CondominoDocumentModel({
    required this.id,
    required this.version,
    required this.nome,
    required this.cognome,
    required this.idCondominio,
    required this.email,
    required this.cellulare,
    required this.scala,
    required this.interno,
    required this.anno,
    required this.config,
    required this.versamenti,
    required this.residuo,
  });

  final String id;
  final int version;
  final String nome;
  final String cognome;
  final String idCondominio;
  final String email;
  final String cellulare;
  final String scala;
  final int interno;
  final int anno;
  final CondominoConfigModel config;
  final List<VersamentoModel> versamenti;
  final double residuo;

  String get nominativo => '$cognome $nome';

  factory CondominoDocumentModel.fromJson(Map<String, dynamic> json) {
    return CondominoDocumentModel(
      id: json['id'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      nome: json['nome'] as String? ?? '',
      cognome: json['cognome'] as String? ?? '',
      idCondominio: json['idCondominio'] as String? ?? '',
      email: json['email'] as String? ?? '',
      cellulare: json['cellulare'] as String? ?? '',
      scala: json['scala'] as String? ?? '',
      interno: (json['interno'] as num?)?.toInt() ?? 0,
      anno: (json['anno'] as num?)?.toInt() ?? 0,
      config: CondominoConfigModel.fromJson(
        json['config'] as Map<String, dynamic>? ?? const {},
      ),
      versamenti: (json['versamenti'] as List<dynamic>? ?? const [])
          .map((e) => VersamentoModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      residuo: (json['residuo'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CondominoConfigModel {
  const CondominoConfigModel({
    required this.tabelle,
    required this.rate,
  });

  final List<TabellaConfigModel> tabelle;
  final List<RataModel> rate;

  factory CondominoConfigModel.fromJson(Map<String, dynamic> json) {
    return CondominoConfigModel(
      tabelle: (json['tabelle'] as List<dynamic>? ?? const [])
          .map((e) => TabellaConfigModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      rate: (json['rate'] as List<dynamic>? ?? const [])
          .map((e) => RataModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class TabellaConfigModel {
  const TabellaConfigModel({
    required this.codiceTabella,
    required this.numeratore,
    required this.denominatore,
  });

  final String codiceTabella;
  final double numeratore;
  final double denominatore;

  factory TabellaConfigModel.fromJson(Map<String, dynamic> json) {
    final tabella = json['tabella'] as Map<String, dynamic>? ?? const {};
    return TabellaConfigModel(
      codiceTabella: tabella['codice'] as String? ?? '',
      numeratore: (json['numeratore'] as num?)?.toDouble() ?? 0,
      denominatore: (json['denominatore'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RataModel {
  const RataModel({
    required this.codice,
    required this.descrizione,
    required this.importi,
  });

  final String codice;
  final String descrizione;
  final List<ImportoRataModel> importi;

  factory RataModel.fromJson(Map<String, dynamic> json) {
    return RataModel(
      codice: json['codice'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      importi: (json['importi'] as List<dynamic>? ?? const [])
          .map((e) => ImportoRataModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class ImportoRataModel {
  const ImportoRataModel({
    required this.codice,
    required this.importo,
  });

  final String codice;
  final double importo;

  factory ImportoRataModel.fromJson(Map<String, dynamic> json) {
    return ImportoRataModel(
      codice: json['codice'] as String? ?? '',
      importo: (json['importo'] as num?)?.toDouble() ?? 0,
    );
  }
}

class VersamentoModel {
  const VersamentoModel({
    required this.descrizione,
    required this.importo,
    required this.date,
    required this.insertedAt,
    required this.ripartizioneTabelle,
  });

  final String descrizione;
  final double importo;
  final DateTime date;
  final DateTime insertedAt;
  final List<RipartizioneModel> ripartizioneTabelle;

  factory VersamentoModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String key) {
      final raw = json[key];
      if (raw is String && raw.isNotEmpty) {
        return DateTime.tryParse(raw)?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      }
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return VersamentoModel(
      descrizione: json['descrizione'] as String? ?? '',
      importo: (json['importo'] as num?)?.toDouble() ?? 0,
      date: parseDate('date'),
      insertedAt: parseDate('insertedAt'),
      ripartizioneTabelle: (json['ripartizioneTabelle'] as List<dynamic>? ?? const [])
          .map((e) => RipartizioneModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class RipartizioneModel {
  const RipartizioneModel({
    required this.codice,
    required this.descrizione,
    required this.importo,
  });

  final String codice;
  final String descrizione;
  final double importo;

  factory RipartizioneModel.fromJson(Map<String, dynamic> json) {
    return RipartizioneModel(
      codice: json['codice'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      importo: (json['importo'] as num?)?.toDouble() ?? 0,
    );
  }
}
