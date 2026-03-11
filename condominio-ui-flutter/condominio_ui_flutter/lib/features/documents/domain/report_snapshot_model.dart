import 'morosita_item_model.dart';
import 'preventivo_snapshot_model.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

/// Snapshot report professionale aggregato dell'esercizio.
class ReportSnapshotModel {
  const ReportSnapshotModel({
    required this.idCondominio,
    required this.label,
    required this.anno,
    required this.gestioneCodice,
    required this.gestioneLabel,
    required this.statoEsercizio,
    required this.generatedAtIso,
    required this.situazioneContabile,
    required this.consuntivoRows,
    required this.ripartoPerTabella,
    required this.morositaItems,
    required this.estrattiConto,
    required this.quotaCondominoTabelle,
  });

  const ReportSnapshotModel.empty()
    : idCondominio = '',
      label = '',
      anno = 0,
      gestioneCodice = '',
      gestioneLabel = '',
      statoEsercizio = '',
      generatedAtIso = '',
      situazioneContabile = const ReportSituazioneContabileModel.empty(),
      consuntivoRows = const [],
      ripartoPerTabella = const [],
      morositaItems = const [],
      estrattiConto = const [],
      quotaCondominoTabelle = const [];

  final String idCondominio;
  final String label;
  final int anno;
  final String gestioneCodice;
  final String gestioneLabel;
  final String statoEsercizio;
  final String generatedAtIso;
  final ReportSituazioneContabileModel situazioneContabile;
  final List<PreventivoRowModel> consuntivoRows;
  final List<ReportRipartoTabellaRowModel> ripartoPerTabella;
  final List<MorositaItemModel> morositaItems;
  final List<ReportEstrattoContoRowModel> estrattiConto;
  final List<ReportQuotaCondominoTabellaRowModel> quotaCondominoTabelle;

  bool get isEmpty =>
      idCondominio.isEmpty &&
      consuntivoRows.isEmpty &&
      ripartoPerTabella.isEmpty &&
      morositaItems.isEmpty &&
      estrattiConto.isEmpty &&
      quotaCondominoTabelle.isEmpty;

  factory ReportSnapshotModel.fromJson(Map<String, dynamic> json) {
    return ReportSnapshotModel(
      idCondominio: json['idCondominio'] as String? ?? '',
      label: json['label'] as String? ?? '',
      anno: _toInt(json['anno']),
      gestioneCodice: json['gestioneCodice'] as String? ?? '',
      gestioneLabel: json['gestioneLabel'] as String? ?? '',
      statoEsercizio: json['statoEsercizio'] as String? ?? '',
      generatedAtIso: json['generatedAt'] as String? ?? '',
      situazioneContabile: ReportSituazioneContabileModel.fromJson(
        (json['situazioneContabile'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
      consuntivoRows: (json['consuntivoRows'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PreventivoRowModel.fromJson)
          .toList(growable: false),
      ripartoPerTabella: (json['ripartoPerTabella'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ReportRipartoTabellaRowModel.fromJson)
          .toList(growable: false),
      morositaItems: (json['morositaItems'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MorositaItemModel.fromJson)
          .toList(growable: false),
      estrattiConto: (json['estrattiConto'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ReportEstrattoContoRowModel.fromJson)
          .toList(growable: false),
      quotaCondominoTabelle:
          (json['quotaCondominoTabelle'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(ReportQuotaCondominoTabellaRowModel.fromJson)
              .toList(growable: false),
    );
  }
}

class ReportSituazioneContabileModel {
  const ReportSituazioneContabileModel({
    required this.saldoInizialeCondominio,
    required this.residuoCondominio,
    required this.totaleSpeseRegistrate,
    required this.totaleVersamenti,
    required this.totaleRateEmesse,
    required this.totaleRateIncassate,
    required this.totaleScopertoRate,
    required this.posizioniAttive,
    required this.posizioniCessate,
  });

  const ReportSituazioneContabileModel.empty()
    : saldoInizialeCondominio = 0,
      residuoCondominio = 0,
      totaleSpeseRegistrate = 0,
      totaleVersamenti = 0,
      totaleRateEmesse = 0,
      totaleRateIncassate = 0,
      totaleScopertoRate = 0,
      posizioniAttive = 0,
      posizioniCessate = 0;

  final double saldoInizialeCondominio;
  final double residuoCondominio;
  final double totaleSpeseRegistrate;
  final double totaleVersamenti;
  final double totaleRateEmesse;
  final double totaleRateIncassate;
  final double totaleScopertoRate;
  final int posizioniAttive;
  final int posizioniCessate;

  factory ReportSituazioneContabileModel.fromJson(Map<String, dynamic> json) {
    return ReportSituazioneContabileModel(
      saldoInizialeCondominio: _toDouble(json['saldoInizialeCondominio']),
      residuoCondominio: _toDouble(json['residuoCondominio']),
      totaleSpeseRegistrate: _toDouble(json['totaleSpeseRegistrate']),
      totaleVersamenti: _toDouble(json['totaleVersamenti']),
      totaleRateEmesse: _toDouble(json['totaleRateEmesse']),
      totaleRateIncassate: _toDouble(json['totaleRateIncassate']),
      totaleScopertoRate: _toDouble(json['totaleScopertoRate']),
      posizioniAttive: _toInt(json['posizioniAttive']),
      posizioniCessate: _toInt(json['posizioniCessate']),
    );
  }
}

class ReportRipartoTabellaRowModel {
  const ReportRipartoTabellaRowModel({
    required this.codiceSpesa,
    required this.codiceTabella,
    required this.descrizioneTabella,
    required this.importoTotale,
  });

  final String codiceSpesa;
  final String codiceTabella;
  final String descrizioneTabella;
  final double importoTotale;

  factory ReportRipartoTabellaRowModel.fromJson(Map<String, dynamic> json) {
    return ReportRipartoTabellaRowModel(
      codiceSpesa: json['codiceSpesa'] as String? ?? '',
      codiceTabella: json['codiceTabella'] as String? ?? '',
      descrizioneTabella: json['descrizioneTabella'] as String? ?? '',
      importoTotale: _toDouble(json['importoTotale']),
    );
  }
}

class ReportEstrattoContoRowModel {
  const ReportEstrattoContoRowModel({
    required this.condominoId,
    required this.nominativo,
    required this.statoPosizione,
    required this.saldoIniziale,
    required this.residuo,
    required this.totaleRate,
    required this.totaleIncassatoRate,
    required this.scopertoRate,
    required this.totaleVersamenti,
  });

  final String condominoId;
  final String nominativo;
  final String statoPosizione;
  final double saldoIniziale;
  final double residuo;
  final double totaleRate;
  final double totaleIncassatoRate;
  final double scopertoRate;
  final double totaleVersamenti;

  factory ReportEstrattoContoRowModel.fromJson(Map<String, dynamic> json) {
    return ReportEstrattoContoRowModel(
      condominoId: json['condominoId'] as String? ?? '',
      nominativo: json['nominativo'] as String? ?? '',
      statoPosizione: json['statoPosizione'] as String? ?? '',
      saldoIniziale: _toDouble(json['saldoIniziale']),
      residuo: _toDouble(json['residuo']),
      totaleRate: _toDouble(json['totaleRate']),
      totaleIncassatoRate: _toDouble(json['totaleIncassatoRate']),
      scopertoRate: _toDouble(json['scopertoRate']),
      totaleVersamenti: _toDouble(json['totaleVersamenti']),
    );
  }
}

class ReportQuotaCondominoTabellaRowModel {
  const ReportQuotaCondominoTabellaRowModel({
    required this.movimentoId,
    required this.dataMovimento,
    required this.codiceSpesa,
    required this.descrizioneMovimento,
    required this.codiceTabella,
    required this.descrizioneTabella,
    required this.importoTabella,
    required this.numeratore,
    required this.denominatore,
    required this.quotaCondominoTabella,
    required this.quotaCondominoMovimento,
  });

  final String movimentoId;
  final DateTime? dataMovimento;
  final String codiceSpesa;
  final String descrizioneMovimento;
  final String codiceTabella;
  final String descrizioneTabella;
  final double importoTabella;
  final double numeratore;
  final double denominatore;
  final double quotaCondominoTabella;
  final double quotaCondominoMovimento;

  factory ReportQuotaCondominoTabellaRowModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportQuotaCondominoTabellaRowModel(
      movimentoId: json['movimentoId'] as String? ?? '',
      dataMovimento: DateTime.tryParse(json['dataMovimento'] as String? ?? ''),
      codiceSpesa: json['codiceSpesa'] as String? ?? '',
      descrizioneMovimento: json['descrizioneMovimento'] as String? ?? '',
      codiceTabella: json['codiceTabella'] as String? ?? '',
      descrizioneTabella: json['descrizioneTabella'] as String? ?? '',
      importoTabella: _toDouble(json['importoTabella']),
      numeratore: _toDouble(json['numeratore']),
      denominatore: _toDouble(json['denominatore']),
      quotaCondominoTabella: _toDouble(json['quotaCondominoTabella']),
      quotaCondominoMovimento: _toDouble(json['quotaCondominoMovimento']),
    );
  }
}

enum ReportExportFormat { pdf, xlsx }

extension ReportExportFormatX on ReportExportFormat {
  String get backendValue {
    switch (this) {
      case ReportExportFormat.pdf:
        return 'pdf';
      case ReportExportFormat.xlsx:
        return 'xlsx';
    }
  }

  String get fileExtension {
    switch (this) {
      case ReportExportFormat.pdf:
        return 'pdf';
      case ReportExportFormat.xlsx:
        return 'xlsx';
    }
  }
}
