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
    this.ruolo = CondominoRuolo.standard,
    this.hasAppAccess = false,
    this.keycloakUsername,
    this.keycloakUserId,
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
  final CondominoRuolo ruolo;
  final bool hasAppAccess;
  final String? keycloakUsername;
  final String? keycloakUserId;

  factory Condomino.fromCoreJson(Map<String, dynamic> json) {
    // I campi "app*" e "keycloak*" arrivano dal backend core quando
    // il condomino e' gia' collegato a un utente applicativo.
    final roleRaw = (json['appRole'] ?? '').toString();
    final keycloakUsername = (json['keycloakUsername'] ?? '').toString();
    final keycloakUserId = (json['keycloakUserId'] ?? '').toString();
    final appEnabledRaw = json['appEnabled'];
    final hasAccess = appEnabledRaw is bool
        ? appEnabledRaw
        : keycloakUsername.isNotEmpty || keycloakUserId.isNotEmpty;

    return Condomino(
      id: (json['id'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      cognome: (json['cognome'] ?? '').toString(),
      scala: (json['scala'] ?? '').toString(),
      interno: (json['interno'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      telefono: (json['cellulare'] ?? '').toString(),
      millesimi: 0,
      residente: true,
      ruolo: _roleFromString(roleRaw),
      hasAppAccess: hasAccess,
      keycloakUsername: keycloakUsername.isEmpty ? null : keycloakUsername,
      keycloakUserId: keycloakUserId.isEmpty ? null : keycloakUserId,
    );
  }

  Map<String, dynamic> toCoreJson({required String condominioId}) {
    // Payload unificato verso core:
    // - dati anagrafici
    // - appartenenza tenant (idCondominio)
    // - metadati accesso applicativo/Keycloak
    final payload = <String, dynamic>{
      'nome': nome,
      'cognome': cognome,
      'idCondominio': condominioId,
      'email': email,
      'cellulare': telefono,
      'scala': scala,
      'interno': int.tryParse(interno) ?? 0,
      'anno': DateTime.now().year,
      'residuo': 0,
      'versamenti': const [],
      'appRole': ruolo.keycloakRoleName,
      'appEnabled': hasAppAccess,
      'keycloakUsername': keycloakUsername,
      'keycloakUserId': keycloakUserId,
    };
    if (id.trim().isNotEmpty) {
      payload['id'] = id;
    }
    return payload;
  }

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
    CondominoRuolo? ruolo,
    bool? hasAppAccess,
    String? keycloakUsername,
    String? keycloakUserId,
    bool clearKeycloakUsername = false,
    bool clearKeycloakUserId = false,
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
      ruolo: ruolo ?? this.ruolo,
      hasAppAccess: hasAppAccess ?? this.hasAppAccess,
      keycloakUsername: clearKeycloakUsername
          ? null
          : (keycloakUsername ?? this.keycloakUsername),
      keycloakUserId: clearKeycloakUserId
          ? null
          : (keycloakUserId ?? this.keycloakUserId),
    );
  }
}

CondominoRuolo _roleFromString(String roleRaw) {
  // Il backend salva stringhe ruolo applicativo; mappiamo in enum UI.
  final normalized = roleRaw.trim().toLowerCase();
  switch (normalized) {
    case 'consigliere':
      return CondominoRuolo.consigliere;
    case 'default-roles-condominio':
      return CondominoRuolo.standard;
    default:
      return CondominoRuolo.standard;
  }
}

enum CondominoRuolo { consigliere, standard }

extension CondominoRuoloLabel on CondominoRuolo {
  String get keycloakRoleName {
    return switch (this) {
      CondominoRuolo.consigliere => 'consigliere',
      CondominoRuolo.standard => 'default-roles-condominio',
    };
  }

  String get label {
    return switch (this) {
      CondominoRuolo.consigliere => 'consigliere',
      CondominoRuolo.standard => 'standard',
    };
  }
}
