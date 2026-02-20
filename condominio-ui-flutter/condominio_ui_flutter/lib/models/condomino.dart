/// Modello dominio per rappresentare un condomino in anagrafica.
///
/// Questo oggetto e' volutamente semplice e serializzabile:
/// viene usato dalla UI per mostrare elenco e dettagli base.
class Condomino {
  const Condomino({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.scala,
    required this.interno,
    required this.email,
    required this.telefono,
    required this.millesimi,
    required this.residente,
  });

  final String id;
  final String nome;
  final String cognome;
  final String scala;
  final String interno;
  final String email;
  final String telefono;
  final double millesimi;
  final bool residente;

  /// Nome completo pronto per uso UI.
  String get nominativo => '$nome $cognome';

  /// Etichetta sintetica unita' abitativa.
  String get unita => 'Scala $scala - Int. $interno';

  Condomino copyWith({
    String? id,
    String? nome,
    String? cognome,
    String? scala,
    String? interno,
    String? email,
    String? telefono,
    double? millesimi,
    bool? residente,
  }) {
    return Condomino(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      scala: scala ?? this.scala,
      interno: interno ?? this.interno,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      millesimi: millesimi ?? this.millesimi,
      residente: residente ?? this.residente,
    );
  }
}
