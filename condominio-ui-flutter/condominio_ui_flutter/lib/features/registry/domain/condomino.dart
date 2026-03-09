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
    required this.saldoIniziale,
    required this.millesimi,
    required this.residente,
    this.ruolo = CondominoRuolo.standard,
    this.hasAppAccess = false,
    this.condominoRootId,
    this.keycloakUsername,
    this.keycloakUserId,
    this.posizioneStato = CondominoPosizioneStato.attivo,
    this.dataIngresso,
    this.dataUscita,
    this.motivoUscita,
    this.precedenteCondominoId,
    this.successivoCondominoId,
    this.unitaImmobiliareId,
    this.titolaritaTipo = CondominoTitolaritaTipo.proprietario,
  });

  final String id;
  final String nome;
  final String cognome;
  final String scala;
  final String interno;
  final String email;
  final String telefono;
  final double saldoIniziale;
  final double millesimi;
  final bool residente;
  final CondominoRuolo ruolo;
  final bool hasAppAccess;
  final String? condominoRootId;
  final String? keycloakUsername;
  final String? keycloakUserId;
  final CondominoPosizioneStato posizioneStato;
  final DateTime? dataIngresso;
  final DateTime? dataUscita;
  final String? motivoUscita;
  final String? precedenteCondominoId;
  final String? successivoCondominoId;
  final String? unitaImmobiliareId;
  final CondominoTitolaritaTipo titolaritaTipo;

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
      saldoIniziale: (json['saldoIniziale'] as num?)?.toDouble() ?? 0,
      millesimi: 0,
      residente: true,
      ruolo: _roleFromString(roleRaw),
      hasAppAccess: hasAccess,
      condominoRootId: (json['condominoRootId'] as String?)?.trim().isEmpty ?? true
          ? null
          : (json['condominoRootId'] as String),
      keycloakUsername: keycloakUsername.isEmpty ? null : keycloakUsername,
      keycloakUserId: keycloakUserId.isEmpty ? null : keycloakUserId,
      posizioneStato: _positionStateFromString(
        (json['statoPosizione'] ?? '').toString(),
      ),
      dataIngresso: _parseDateTime(json['dataIngresso']),
      dataUscita: _parseDateTime(json['dataUscita']),
      motivoUscita: (json['motivoUscita'] as String?)?.trim().isEmpty ?? true
          ? null
          : (json['motivoUscita'] as String),
      precedenteCondominoId:
          (json['precedenteCondominoId'] as String?)?.trim().isEmpty ?? true
              ? null
              : (json['precedenteCondominoId'] as String),
      successivoCondominoId:
          (json['successivoCondominoId'] as String?)?.trim().isEmpty ?? true
              ? null
              : (json['successivoCondominoId'] as String),
      unitaImmobiliareId:
          (json['unitaImmobiliareId'] as String?)?.trim().isEmpty ?? true
              ? null
              : (json['unitaImmobiliareId'] as String),
      titolaritaTipo: _titolaritaFromString(
        (json['titolaritaTipo'] ?? '').toString(),
      ),
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
      'saldoIniziale': saldoIniziale,
      'appRole': ruolo.keycloakRoleName,
      'appEnabled': hasAppAccess,
      'keycloakUsername': keycloakUsername,
      'keycloakUserId': keycloakUserId,
      'statoPosizione': posizioneStato.coreName,
      'dataIngresso': dataIngresso?.toUtc().toIso8601String(),
      'dataUscita': dataUscita?.toUtc().toIso8601String(),
      'motivoUscita': motivoUscita,
      'precedenteCondominoId': precedenteCondominoId,
      'successivoCondominoId': successivoCondominoId,
      'unitaImmobiliareId': unitaImmobiliareId,
      'titolaritaTipo': titolaritaTipo.coreName,
    };
    if (condominoRootId != null && condominoRootId!.trim().isNotEmpty) {
      payload['condominoRootId'] = condominoRootId;
    }
    if (id.trim().isNotEmpty) {
      payload['id'] = id;
    }
    return payload;
  }

  /// Nome completo pronto per uso UI.
  String get nominativo => '$nome $cognome';

  /// Etichetta sintetica unita' abitativa.
  String get unita => 'Scala $scala - Int. $interno';

  /// Il backend assegna un root stabile quando il condomino appartiene a un
  /// profilo condiviso tra esercizi e gestioni dello stesso condominio.
  bool get hasStableProfile =>
      condominoRootId != null && condominoRootId!.trim().isNotEmpty;

  /// Accesso applicativo realmente collegato a un utente del realm.
  bool get hasLinkedAppUser =>
      (keycloakUserId?.trim().isNotEmpty ?? false) ||
      (keycloakUsername?.trim().isNotEmpty ?? false);

  bool get isActivePosition => posizioneStato == CondominoPosizioneStato.attivo;
  bool get isCeasedPosition => !isActivePosition;

  String get posizioneStatoLabel => switch (posizioneStato) {
    CondominoPosizioneStato.attivo => 'attivo',
    CondominoPosizioneStato.cessato => 'cessato',
  };

  Condomino copyWith({
    String? id,
    String? nome,
    String? cognome,
    String? scala,
    String? interno,
    String? email,
    String? telefono,
    double? saldoIniziale,
    double? millesimi,
    bool? residente,
    CondominoRuolo? ruolo,
    bool? hasAppAccess,
    String? condominoRootId,
    String? keycloakUsername,
    String? keycloakUserId,
    CondominoPosizioneStato? posizioneStato,
    DateTime? dataIngresso,
    DateTime? dataUscita,
    String? motivoUscita,
    String? precedenteCondominoId,
    String? successivoCondominoId,
    String? unitaImmobiliareId,
    CondominoTitolaritaTipo? titolaritaTipo,
    bool clearCondominoRootId = false,
    bool clearKeycloakUsername = false,
    bool clearKeycloakUserId = false,
    bool clearDataUscita = false,
    bool clearMotivoUscita = false,
    bool clearPrecedenteCondominoId = false,
    bool clearSuccessivoCondominoId = false,
    bool clearUnitaImmobiliareId = false,
  }) {
    return Condomino(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      scala: scala ?? this.scala,
      interno: interno ?? this.interno,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      saldoIniziale: saldoIniziale ?? this.saldoIniziale,
      millesimi: millesimi ?? this.millesimi,
      residente: residente ?? this.residente,
      ruolo: ruolo ?? this.ruolo,
      hasAppAccess: hasAppAccess ?? this.hasAppAccess,
      condominoRootId: clearCondominoRootId
          ? null
          : (condominoRootId ?? this.condominoRootId),
      keycloakUsername: clearKeycloakUsername
          ? null
          : (keycloakUsername ?? this.keycloakUsername),
      keycloakUserId: clearKeycloakUserId
          ? null
          : (keycloakUserId ?? this.keycloakUserId),
      posizioneStato: posizioneStato ?? this.posizioneStato,
      dataIngresso: dataIngresso ?? this.dataIngresso,
      dataUscita: clearDataUscita ? null : (dataUscita ?? this.dataUscita),
      motivoUscita:
          clearMotivoUscita ? null : (motivoUscita ?? this.motivoUscita),
      precedenteCondominoId: clearPrecedenteCondominoId
          ? null
          : (precedenteCondominoId ?? this.precedenteCondominoId),
      successivoCondominoId: clearSuccessivoCondominoId
          ? null
          : (successivoCondominoId ?? this.successivoCondominoId),
      unitaImmobiliareId: clearUnitaImmobiliareId
          ? null
          : (unitaImmobiliareId ?? this.unitaImmobiliareId),
      titolaritaTipo: titolaritaTipo ?? this.titolaritaTipo,
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

enum CondominoPosizioneStato { attivo, cessato }
enum CondominoTitolaritaTipo { proprietario, inquilino, delegato }

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

extension CondominoPosizioneStatoLabel on CondominoPosizioneStato {
  String get coreName {
    return switch (this) {
      CondominoPosizioneStato.attivo => 'ATTIVO',
      CondominoPosizioneStato.cessato => 'CESSATO',
    };
  }
}

extension CondominoTitolaritaLabel on CondominoTitolaritaTipo {
  String get coreName {
    return switch (this) {
      CondominoTitolaritaTipo.proprietario => 'PROPRIETARIO',
      CondominoTitolaritaTipo.inquilino => 'INQUILINO',
      CondominoTitolaritaTipo.delegato => 'DELEGATO',
    };
  }

  String get label {
    return switch (this) {
      CondominoTitolaritaTipo.proprietario => 'proprietario',
      CondominoTitolaritaTipo.inquilino => 'inquilino',
      CondominoTitolaritaTipo.delegato => 'delegato',
    };
  }
}

CondominoPosizioneStato _positionStateFromString(String raw) {
  switch (raw.trim().toUpperCase()) {
    case 'CESSATO':
      return CondominoPosizioneStato.cessato;
    default:
      return CondominoPosizioneStato.attivo;
  }
}

DateTime? _parseDateTime(Object? raw) {
  if (raw is! String || raw.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw)?.toUtc();
}

CondominoTitolaritaTipo _titolaritaFromString(String raw) {
  switch (raw.trim().toUpperCase()) {
    case 'INQUILINO':
      return CondominoTitolaritaTipo.inquilino;
    case 'DELEGATO':
      return CondominoTitolaritaTipo.delegato;
    default:
      return CondominoTitolaritaTipo.proprietario;
  }
}
