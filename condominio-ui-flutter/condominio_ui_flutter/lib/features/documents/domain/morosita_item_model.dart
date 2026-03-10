double _numAsDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

int _numAsInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

DateTime? _parseInstant(dynamic value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}

enum MorositaStatoUi { inBonis, sollecitato, legale }

MorositaStatoUi morositaStatoFromBackend(String raw) {
  switch (raw.trim().toUpperCase()) {
    case 'SOLLECITATO':
      return MorositaStatoUi.sollecitato;
    case 'LEGALE':
      return MorositaStatoUi.legale;
    default:
      return MorositaStatoUi.inBonis;
  }
}

String morositaStatoToBackend(MorositaStatoUi value) {
  switch (value) {
    case MorositaStatoUi.sollecitato:
      return 'SOLLECITATO';
    case MorositaStatoUi.legale:
      return 'LEGALE';
    case MorositaStatoUi.inBonis:
      return 'IN_BONIS';
  }
}

extension MorositaStatoUiLabel on MorositaStatoUi {
  String get label {
    switch (this) {
      case MorositaStatoUi.sollecitato:
        return 'Sollecitato';
      case MorositaStatoUi.legale:
        return 'Legale';
      case MorositaStatoUi.inBonis:
        return 'In bonis';
    }
  }
}

/// Riga vista morosita' per esercizio.
class MorositaItemModel {
  const MorositaItemModel({
    required this.condominoId,
    required this.idCondominio,
    required this.nominativo,
    required this.praticaStato,
    required this.debitoTotale,
    required this.debitoScaduto,
    required this.debitoNonScaduto,
    required this.scaduto0_30,
    required this.scaduto31_60,
    required this.scaduto61_90,
    required this.scadutoOver90,
    required this.massimoRitardoGiorni,
    required this.numeroSolleciti,
    required this.ultimoSollecitoAt,
  });

  final String condominoId;
  final String idCondominio;
  final String nominativo;
  final MorositaStatoUi praticaStato;
  final double debitoTotale;
  final double debitoScaduto;
  final double debitoNonScaduto;
  final double scaduto0_30;
  final double scaduto31_60;
  final double scaduto61_90;
  final double scadutoOver90;
  final int massimoRitardoGiorni;
  final int numeroSolleciti;
  final DateTime? ultimoSollecitoAt;

  bool get hasDebitoScaduto => debitoScaduto > 0;

  factory MorositaItemModel.fromJson(Map<String, dynamic> json) {
    return MorositaItemModel(
      condominoId: json['condominoId'] as String? ?? '',
      idCondominio: json['idCondominio'] as String? ?? '',
      nominativo: json['nominativo'] as String? ?? '',
      praticaStato: morositaStatoFromBackend(
        json['praticaStato'] as String? ?? 'IN_BONIS',
      ),
      debitoTotale: _numAsDouble(json['debitoTotale']),
      debitoScaduto: _numAsDouble(json['debitoScaduto']),
      debitoNonScaduto: _numAsDouble(json['debitoNonScaduto']),
      scaduto0_30: _numAsDouble(json['scaduto0_30']),
      scaduto31_60: _numAsDouble(json['scaduto31_60']),
      scaduto61_90: _numAsDouble(json['scaduto61_90']),
      scadutoOver90: _numAsDouble(json['scadutoOver90']),
      massimoRitardoGiorni: _numAsInt(json['massimoRitardoGiorni']),
      numeroSolleciti: _numAsInt(json['numeroSolleciti']),
      ultimoSollecitoAt: _parseInstant(json['ultimoSollecitoAt']),
    );
  }
}
