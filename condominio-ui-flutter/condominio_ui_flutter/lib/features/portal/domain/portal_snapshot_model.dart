double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

class PortalSnapshotModel {
  const PortalSnapshotModel({
    required this.idCondominio,
    required this.labelCondominio,
    required this.anno,
    required this.gestioneCodice,
    required this.gestioneLabel,
    required this.statoEsercizio,
    required this.residuoCondominio,
    required this.generatedAtIso,
    required this.condominoId,
    required this.nominativo,
    required this.appRole,
    required this.statoPosizione,
    required this.scala,
    required this.interno,
    required this.saldoInizialeCondomino,
    required this.residuoCondomino,
    required this.totaleRate,
    required this.totaleIncassatoRate,
    required this.scopertoRate,
    required this.totaleVersamenti,
    required this.rate,
    required this.versamenti,
    required this.movimenti,
    required this.documentiRecenti,
  });

  const PortalSnapshotModel.empty()
    : idCondominio = '',
      labelCondominio = '',
      anno = 0,
      gestioneCodice = '',
      gestioneLabel = '',
      statoEsercizio = '',
      residuoCondominio = 0,
      generatedAtIso = '',
      condominoId = '',
      nominativo = '',
      appRole = '',
      statoPosizione = '',
      scala = '',
      interno = '',
      saldoInizialeCondomino = 0,
      residuoCondomino = 0,
      totaleRate = 0,
      totaleIncassatoRate = 0,
      scopertoRate = 0,
      totaleVersamenti = 0,
      rate = const [],
      versamenti = const [],
      movimenti = const [],
      documentiRecenti = const [];

  final String idCondominio;
  final String labelCondominio;
  final int anno;
  final String gestioneCodice;
  final String gestioneLabel;
  final String statoEsercizio;
  final double residuoCondominio;
  final String generatedAtIso;

  final String condominoId;
  final String nominativo;
  final String appRole;
  final String statoPosizione;
  final String scala;
  final String interno;
  final double saldoInizialeCondomino;
  final double residuoCondomino;

  final double totaleRate;
  final double totaleIncassatoRate;
  final double scopertoRate;
  final double totaleVersamenti;
  final List<PortalRateModel> rate;
  final List<PortalVersamentoModel> versamenti;
  final List<PortalMovimentoQuotaModel> movimenti;
  final List<PortalDocumentoModel> documentiRecenti;

  bool get isEmpty => idCondominio.isEmpty || condominoId.isEmpty;

  factory PortalSnapshotModel.fromJson(Map<String, dynamic> json) {
    return PortalSnapshotModel(
      idCondominio: json['idCondominio'] as String? ?? '',
      labelCondominio: json['labelCondominio'] as String? ?? '',
      anno: (json['anno'] as num?)?.toInt() ?? 0,
      gestioneCodice: json['gestioneCodice'] as String? ?? '',
      gestioneLabel: json['gestioneLabel'] as String? ?? '',
      statoEsercizio: json['statoEsercizio'] as String? ?? '',
      residuoCondominio: _toDouble(json['residuoCondominio']),
      generatedAtIso: json['generatedAt'] as String? ?? '',
      condominoId: json['condominoId'] as String? ?? '',
      nominativo: json['nominativo'] as String? ?? '',
      appRole: json['appRole'] as String? ?? '',
      statoPosizione: json['statoPosizione'] as String? ?? '',
      scala: json['scala'] as String? ?? '',
      interno: json['interno'] as String? ?? '',
      saldoInizialeCondomino: _toDouble(json['saldoInizialeCondomino']),
      residuoCondomino: _toDouble(json['residuoCondomino']),
      totaleRate: _toDouble(json['totaleRate']),
      totaleIncassatoRate: _toDouble(json['totaleIncassatoRate']),
      scopertoRate: _toDouble(json['scopertoRate']),
      totaleVersamenti: _toDouble(json['totaleVersamenti']),
      rate: (json['rate'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PortalRateModel.fromJson)
          .toList(growable: false),
      versamenti: (json['versamenti'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PortalVersamentoModel.fromJson)
          .toList(growable: false),
      movimenti: (json['movimenti'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PortalMovimentoQuotaModel.fromJson)
          .toList(growable: false),
      documentiRecenti:
          (json['documentiRecenti'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(PortalDocumentoModel.fromJson)
              .toList(growable: false),
    );
  }
}

class PortalRateModel {
  const PortalRateModel({
    required this.id,
    required this.codice,
    required this.descrizione,
    required this.tipo,
    required this.stato,
    required this.scadenzaIso,
    required this.importo,
    required this.incassato,
    required this.scoperto,
  });

  final String id;
  final String codice;
  final String descrizione;
  final String tipo;
  final String stato;
  final String scadenzaIso;
  final double importo;
  final double incassato;
  final double scoperto;

  factory PortalRateModel.fromJson(Map<String, dynamic> json) {
    return PortalRateModel(
      id: json['id'] as String? ?? '',
      codice: json['codice'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
      stato: json['stato'] as String? ?? '',
      scadenzaIso: json['scadenza'] as String? ?? '',
      importo: _toDouble(json['importo']),
      incassato: _toDouble(json['incassato']),
      scoperto: _toDouble(json['scoperto']),
    );
  }
}

class PortalVersamentoModel {
  const PortalVersamentoModel({
    required this.id,
    required this.descrizione,
    required this.rataId,
    required this.importo,
    required this.date,
    required this.insertedAt,
  });

  final String id;
  final String descrizione;
  final String? rataId;
  final double importo;
  final DateTime? date;
  final DateTime? insertedAt;

  factory PortalVersamentoModel.fromJson(Map<String, dynamic> json) {
    return PortalVersamentoModel(
      id: json['id'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      rataId: json['rataId'] as String?,
      importo: _toDouble(json['importo']),
      date: DateTime.tryParse(json['date'] as String? ?? ''),
      insertedAt: DateTime.tryParse(json['insertedAt'] as String? ?? ''),
    );
  }
}

class PortalMovimentoQuotaModel {
  const PortalMovimentoQuotaModel({
    required this.movimentoId,
    required this.date,
    required this.codiceSpesa,
    required this.descrizione,
    required this.importoTotale,
    required this.quotaCondomino,
  });

  final String movimentoId;
  final DateTime? date;
  final String codiceSpesa;
  final String descrizione;
  final double importoTotale;
  final double quotaCondomino;

  factory PortalMovimentoQuotaModel.fromJson(Map<String, dynamic> json) {
    return PortalMovimentoQuotaModel(
      movimentoId: json['movimentoId'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? ''),
      codiceSpesa: json['codiceSpesa'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      importoTotale: _toDouble(json['importoTotale']),
      quotaCondomino: _toDouble(json['quotaCondomino']),
    );
  }
}

class PortalDocumentoModel {
  const PortalDocumentoModel({
    required this.documentoId,
    required this.titolo,
    required this.categoria,
    required this.movimentoId,
    required this.versionNumber,
    required this.createdAt,
  });

  final String documentoId;
  final String titolo;
  final String categoria;
  final String? movimentoId;
  final int versionNumber;
  final DateTime? createdAt;

  factory PortalDocumentoModel.fromJson(Map<String, dynamic> json) {
    return PortalDocumentoModel(
      documentoId: json['documentoId'] as String? ?? '',
      titolo: json['titolo'] as String? ?? '',
      categoria: json['categoria'] as String? ?? '',
      movimentoId: json['movimentoId'] as String?,
      versionNumber: (json['versionNumber'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

