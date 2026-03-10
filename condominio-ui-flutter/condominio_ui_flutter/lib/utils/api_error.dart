import 'dart:convert';

import 'package:http/http.dart' as http;

/// Errore API normalizzato per evitare parsing duplicato nei vari client HTTP.
class ApiError implements Exception {
  ApiError({
    required this.operation,
    required this.statusCode,
    required this.technicalMessage,
    required this.userMessage,
    this.responseBody,
  });

  final String operation;
  final int statusCode;
  final String technicalMessage;
  final String userMessage;
  final String? responseBody;

  factory ApiError.fromHttp({
    required String operation,
    required http.Response response,
  }) {
    final status = response.statusCode;
    final body = response.body;
    final parsedMessage = _extractMessage(body);
    final mappedBusinessMessage = _mapBusinessMessage(parsedMessage);
    final userMessage = switch (status) {
      400 => mappedBusinessMessage ?? parsedMessage ?? 'Richiesta non valida.',
      401 => 'Sessione scaduta. Effettua nuovamente il login.',
      403 => 'Operazione non consentita per il tuo profilo.',
      404 => 'Risorsa non trovata.',
      409 => mappedBusinessMessage ??
          parsedMessage ??
          'Conflitto dati: elemento gia\' presente.',
      _ => mappedBusinessMessage ??
          parsedMessage ??
          'Errore di comunicazione con il server.',
    };
    return ApiError(
      operation: operation,
      statusCode: status,
      technicalMessage: '$operation failed: status=$status, body=$body',
      userMessage: userMessage,
      responseBody: body,
    );
  }

  @override
  String toString() => userMessage;

  static String? _extractMessage(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final errorCodes = decoded['errorCodes'];
        if (errorCodes is List && errorCodes.isNotEmpty) {
          final first = errorCodes.first;
          if (first is String && first.trim().isNotEmpty) {
            return first.trim();
          }
        }
        final direct = [
          decoded['message'],
          decoded['error'],
          decoded['detail'],
          decoded['validationMessage'],
        ];
        for (final candidate in direct) {
          if (candidate is String && candidate.trim().isNotEmpty) {
            return candidate.trim();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  static String? _mapBusinessMessage(String? rawCode) {
    if (rawCode == null || rawCode.trim().isEmpty) return null;
    final code = rawCode.trim();

    const direct = <String, String>{
      'validation.required.rata.codice': 'Inserisci il codice rata.',
      'validation.required.rata.scadenza': 'Inserisci la data di scadenza della rata.',
      'validation.invalid.rata.importo': 'L\'importo rata non e\' valido.',
      'validation.required.versamento.descrizione': 'Inserisci una descrizione del versamento.',
      'validation.invalid.versamento.importo': 'L\'importo versamento non e\' valido.',
      'validation.notfound.versamento.rata': 'La rata selezionata non esiste piu\'.',
      'validation.required.unitaImmobiliare.codice': 'Inserisci il codice dell\'unita immobiliare.',
      'validation.required.unitaImmobiliare.scala': 'Inserisci la scala dell\'unita immobiliare.',
      'validation.required.unitaImmobiliare.interno': 'Inserisci l\'interno dell\'unita immobiliare.',
      'validation.duplicate.unitaImmobiliare.scalaInterno':
          'Esiste gia\' un\'unita immobiliare con la stessa scala e interno.',
      'validation.inuse.unitaImmobiliare':
          'Unita immobiliare in uso: non puo\' essere eliminata finche\' esistono posizioni collegate.',
      'validation.required.condomino.unitaImmobiliare':
          'Seleziona un\'unita immobiliare oppure compila scala e interno.',
      'validation.overlap.condomino.unitaImmobiliare':
          'Esiste gia\' una posizione attiva/sovrapposta sulla stessa unita immobiliare.',
      'validation.invalid.condomino.dataUscitaBeforeIngresso':
          'La data di uscita non puo\' essere precedente alla data di ingresso.',
      'validation.invalid.condomino.positionNotActive':
          'La posizione non e\' attiva, quindi l\'operazione non e\' consentita.',
      'validation.inuse.condomino.versamenti':
          'Non puoi eliminare questa posizione: sono presenti versamenti collegati.',
      'validation.inuse.condomino.movimenti':
          'Non puoi eliminare questa posizione: sono presenti movimenti collegati.',
      'validation.inuse.condomino.subentro':
          'Non puoi eliminare questa posizione: e\' collegata a un subentro.',
      'validation.esercizio.closed':
          'L\'esercizio e\' chiuso: operazione non consentita in sola lettura.',
    };
    final directHit = direct[code];
    if (directHit != null) return directHit;

    if (code.startsWith('validation.invalid.movimento.ripartizioneCondomini.sumMismatch')) {
      return 'La ripartizione individuale non coincide con l\'importo del movimento.';
    }
    if (code.startsWith('validation.required.riparto.quotaTabella.') &&
        code.endsWith('.noPartecipanti')) {
      return 'Nessun condomino partecipa alla tabella selezionata: assegna almeno una quota valida.';
    }
    if (code.startsWith('validation.required.riparto.quotaTabella.')) {
      return 'Configurazione quote tabellari non valida per il riparto richiesto.';
    }
    if (code.startsWith('validation.required.riparto.sommaMillesimiIncoerente.')) {
      return 'La somma delle quote non e\' coerente con il denominatore della tabella.';
    }
    if (code.startsWith('invalid.percent.')) {
      return 'Le percentuali della configurazione spesa non sono valide (devono sommare a 100).';
    }
    return null;
  }
}
