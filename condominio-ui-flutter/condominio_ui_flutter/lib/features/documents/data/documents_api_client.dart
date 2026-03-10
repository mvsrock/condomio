import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../config/keycloak_config.dart';
import '../../../utils/api_error.dart';
import '../domain/condominio_document_model.dart';
import '../domain/condomino_document_model.dart';
import '../domain/morosita_item_model.dart';
import '../domain/movimento_model.dart';
import '../domain/preventivo_snapshot_model.dart';
import '../domain/tabella_model.dart';

/// Client HTTP del modulo documenti.
///
/// Le letture/scritture del modulo lavorano sempre sull'esercizio selezionato,
/// anche se alcuni parametri locali mantengono il nome storico `condominioId`
/// per compatibilita' con il resto del frontend.
class DocumentsApiClient {
  const DocumentsApiClient();

  Uri _uri(String path) => Uri.parse('${KeycloakAppConfig.coreApiUrl}$path');

  Uri _uriWithQuery(String path, Map<String, String> query) {
    final base = Uri.parse('${KeycloakAppConfig.coreApiUrl}$path');
    return base.replace(queryParameters: query);
  }

  Map<String, String> _headers(String accessToken) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  Map<String, String> _mergePatchHeaders(String accessToken) => {
    'Content-Type': 'application/merge-patch+json',
    'Authorization': 'Bearer $accessToken',
  };

  Never _throwHttpError(String op, http.Response response) {
    throw ApiError.fromHttp(operation: op, response: response);
  }

  Future<CondominioDocumentModel> fetchCondominioById({
    required String accessToken,
    required String condominioId,
  }) async {
    final response = await http.get(
      _uri('/esercizi/$condominioId'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchEsercizioById', response);
    }
    final json =
        (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return CondominioDocumentModel.fromJson(json);
  }

  Future<List<CondominoDocumentModel>> fetchCondomini({
    required String accessToken,
    required String condominioId,
  }) async {
    final response = await http.get(
      _uriWithQuery('/condomino', {'idCondominio': condominioId}),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchCondominiDocuments', response);
    }
    final raw = (jsonDecode(response.body) as List?) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CondominoDocumentModel.fromJson)
        .toList(growable: false);
  }

  Future<List<TabellaModel>> fetchTabelle({
    required String accessToken,
    required String condominioId,
  }) async {
    final response = await http.get(
      _uriWithQuery('/tabelle', {'idCondominio': condominioId}),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchTabelle', response);
    }
    final raw = (jsonDecode(response.body) as List?) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(TabellaModel.fromJson)
        .toList(growable: false);
  }

  Future<List<MovimentoModel>> fetchMovimenti({
    required String accessToken,
    required String condominioId,
  }) async {
    final response = await http.get(
      _uriWithQuery('/movimenti', {'idCondominio': condominioId}),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchMovimenti', response);
    }
    final raw = (jsonDecode(response.body) as List?) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(MovimentoModel.fromJson)
        .toList(growable: false);
  }

  Future<List<MorositaItemModel>> fetchMorosita({
    required String accessToken,
    required String condominioId,
  }) async {
    final response = await http.get(
      _uriWithQuery('/morosita', {'idCondominio': condominioId}),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchMorosita', response);
    }
    final raw = (jsonDecode(response.body) as List?) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(MorositaItemModel.fromJson)
        .toList(growable: false);
  }

  Future<PreventivoSnapshotModel> fetchPreventivoSnapshot({
    required String accessToken,
    required String condominioId,
  }) async {
    final response = await http.get(
      _uri('/preventivi/$condominioId'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchPreventivoSnapshot', response);
    }
    final raw =
        (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return PreventivoSnapshotModel.fromJson(raw);
  }

  Future<void> savePreventivoSnapshot({
    required String accessToken,
    required String condominioId,
    required List<Map<String, dynamic>> rows,
  }) async {
    final response = await http.put(
      _uri('/preventivi/$condominioId'),
      headers: _headers(accessToken),
      body: jsonEncode({'rows': rows}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('savePreventivoSnapshot', response);
    }
  }

  Future<void> updateMorositaStato({
    required String accessToken,
    required String condominoId,
    required String stato,
  }) async {
    final response = await http.patch(
      _uri('/morosita/$condominoId/stato'),
      headers: _headers(accessToken),
      body: jsonEncode({'stato': stato}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('updateMorositaStato', response);
    }
  }

  Future<void> addMorositaSollecito({
    required String accessToken,
    required String condominoId,
    required String canale,
    required String titolo,
    required String? note,
    required bool automatico,
  }) async {
    final response = await http.post(
      _uri('/morosita/$condominoId/solleciti'),
      headers: _headers(accessToken),
      body: jsonEncode({
        'canale': canale.trim(),
        'titolo': titolo.trim(),
        'note': note?.trim(),
        'automatico': automatico,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('addMorositaSollecito', response);
    }
  }

  Future<int> generateAutomaticSolleciti({
    required String accessToken,
    required String condominioId,
    required int minDaysOverdue,
  }) async {
    final response = await http.post(
      _uriWithQuery('/morosita/solleciti/automatici/$condominioId', {
        'minDaysOverdue': '$minDaysOverdue',
      }),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('generateAutomaticSolleciti', response);
    }
    final payload = jsonDecode(response.body);
    if (payload is num) return payload.toInt();
    return int.tryParse(payload.toString()) ?? 0;
  }

  Future<void> createTabella({
    required String accessToken,
    required String condominioId,
    required String codice,
    required String descrizione,
  }) async {
    final response = await http.post(
      _uri('/tabelle'),
      headers: _headers(accessToken),
      body: jsonEncode({
        'idCondominio': condominioId,
        'codice': codice.trim(),
        'descrizione': descrizione.trim(),
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('createTabella', response);
    }
  }

  Future<void> updateTabella({
    required String accessToken,
    required String tabellaId,
    required String codice,
    required String descrizione,
  }) async {
    final response = await http.patch(
      _uri('/tabelle/$tabellaId'),
      headers: _mergePatchHeaders(accessToken),
      body: jsonEncode({
        'codice': codice.trim(),
        'descrizione': descrizione.trim(),
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('updateTabella', response);
    }
  }

  Future<void> deleteTabella({
    required String accessToken,
    required String tabellaId,
  }) async {
    final response = await http.delete(
      _uri('/tabelle/$tabellaId'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('deleteTabella', response);
    }
  }

  Future<void> cleanupDeleteTabella({
    required String accessToken,
    required String tabellaId,
  }) async {
    final response = await http.post(
      _uri('/tabelle/$tabellaId/cleanup-delete'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('cleanupDeleteTabella', response);
    }
  }

  Future<void> createMovimento({
    required String accessToken,
    required String condominioId,
    required String codiceSpesa,
    required String tipoRiparto,
    required String descrizione,
    required double importo,
    required List<Map<String, dynamic>> ripartizioneCondomini,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final response = await http.post(
      _uri('/movimenti'),
      headers: _headers(accessToken),
      body: jsonEncode({
        'idCondominio': condominioId,
        'codiceSpesa': codiceSpesa.trim(),
        'tipoRiparto': tipoRiparto,
        'descrizione': descrizione.trim(),
        'importo': importo,
        'date': nowIso,
        'insertedAt': nowIso,
        'ripartizioneCondomini': ripartizioneCondomini,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('createMovimento', response);
    }
  }

  Future<void> updateMovimento({
    required String accessToken,
    required String movimentoId,
    required String codiceSpesa,
    required String tipoRiparto,
    required String descrizione,
    required double importo,
    required List<Map<String, dynamic>> ripartizioneCondomini,
  }) async {
    final response = await http.patch(
      _uri('/movimenti/$movimentoId'),
      headers: _mergePatchHeaders(accessToken),
      body: jsonEncode({
        'codiceSpesa': codiceSpesa.trim(),
        'tipoRiparto': tipoRiparto,
        'descrizione': descrizione.trim(),
        'importo': importo,
        'ripartizioneCondomini': ripartizioneCondomini,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('updateMovimento', response);
    }
  }

  Future<void> deleteMovimento({
    required String accessToken,
    required String movimentoId,
  }) async {
    final response = await http.delete(
      _uri('/movimenti/$movimentoId'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('deleteMovimento', response);
    }
  }

  Future<void> patchCondominioConfigurazioniSpesa({
    required String accessToken,
    required String condominioId,
    required List<Map<String, dynamic>> configurazioniSpesa,
  }) async {
    final payload = {'configurazioniSpesa': configurazioniSpesa};
    if (kDebugMode) {
      debugPrint(
        '[DOCUMENTS][patchEsercizioConfigurazioniSpesa] condominioId=$condominioId payload=${jsonEncode(payload)}',
      );
    }
    final response = await http.patch(
      _uri('/esercizi/$condominioId'),
      headers: _mergePatchHeaders(accessToken),
      body: jsonEncode(payload),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('patchEsercizioConfigurazioniSpesa', response);
    }
  }

  Future<void> patchCondominoQuoteTabelle({
    required String accessToken,
    required String condominoId,
    required List<Map<String, dynamic>> tabelle,
  }) async {
    final response = await http.patch(
      _uri('/condomino/$condominoId'),
      headers: _mergePatchHeaders(accessToken),
      body: jsonEncode({
        'config': {'tabelle': tabelle},
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('patchCondominoQuoteTabelle', response);
    }
  }

  Future<void> addCondominoVersamento({
    required String accessToken,
    required String condominoId,
    required Map<String, dynamic> versamento,
  }) async {
    final response = await http.post(
      _uri('/condomino/$condominoId/versamenti'),
      headers: _headers(accessToken),
      body: jsonEncode(versamento),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('addCondominoVersamento', response);
    }
  }

  Future<void> updateCondominoVersamento({
    required String accessToken,
    required String condominoId,
    required String versamentoId,
    required Map<String, dynamic> versamento,
  }) async {
    final response = await http.patch(
      _uri('/condomino/$condominoId/versamenti/$versamentoId'),
      headers: _headers(accessToken),
      body: jsonEncode(versamento),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('updateCondominoVersamento', response);
    }
  }

  Future<void> deleteCondominoVersamento({
    required String accessToken,
    required String condominoId,
    required String versamentoId,
  }) async {
    final response = await http.delete(
      _uri('/condomino/$condominoId/versamenti/$versamentoId'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('deleteCondominoVersamento', response);
    }
  }

  Future<void> rebuildStoricoCondominio({
    required String accessToken,
    required String condominioId,
  }) async {
    final response = await http.post(
      _uri('/movimenti/rebuild-storico/$condominioId'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('rebuildStoricoCondominio', response);
    }
  }

  Future<void> addCondominoRata({
    required String accessToken,
    required String condominoId,
    required Map<String, dynamic> rata,
  }) async {
    final response = await http.post(
      _uri('/condomino/$condominoId/rate'),
      headers: _headers(accessToken),
      body: jsonEncode(rata),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('addCondominoRata', response);
    }
  }

  Future<void> updateCondominoRata({
    required String accessToken,
    required String condominoId,
    required String rataId,
    required Map<String, dynamic> rata,
  }) async {
    final response = await http.patch(
      _uri('/condomino/$condominoId/rate/$rataId'),
      headers: _headers(accessToken),
      body: jsonEncode(rata),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('updateCondominoRata', response);
    }
  }

  Future<void> deleteCondominoRata({
    required String accessToken,
    required String condominoId,
    required String rataId,
  }) async {
    final response = await http.delete(
      _uri('/condomino/$condominoId/rate/$rataId'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('deleteCondominoRata', response);
    }
  }
}
