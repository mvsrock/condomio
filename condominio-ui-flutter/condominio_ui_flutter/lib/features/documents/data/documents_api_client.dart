import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../config/keycloak_config.dart';
import '../../../utils/api_error.dart';
import '../domain/condominio_document_model.dart';
import '../domain/condomino_document_model.dart';
import '../domain/movimento_model.dart';
import '../domain/tabella_model.dart';

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
      _uri('/condominio/$condominioId'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchCondominioById', response);
    }
    final json = (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
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
    required String descrizione,
    required double importo,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final response = await http.post(
      _uri('/movimenti'),
      headers: _headers(accessToken),
      body: jsonEncode({
        'idCondominio': condominioId,
        'codiceSpesa': codiceSpesa.trim(),
        'descrizione': descrizione.trim(),
        'importo': importo,
        'date': nowIso,
        'insertedAt': nowIso,
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
    required String descrizione,
    required double importo,
  }) async {
    final response = await http.patch(
      _uri('/movimenti/$movimentoId'),
      headers: _mergePatchHeaders(accessToken),
      body: jsonEncode({
        'codiceSpesa': codiceSpesa.trim(),
        'descrizione': descrizione.trim(),
        'importo': importo,
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
        '[DOCUMENTS][patchCondominioConfigurazioniSpesa] condominioId=$condominioId payload=${jsonEncode(payload)}',
      );
    }
    final response = await http.patch(
      _uri('/condominio/$condominioId'),
      headers: _mergePatchHeaders(accessToken),
      body: jsonEncode(payload),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('patchCondominioConfigurazioniSpesa', response);
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
        'config': {
          'tabelle': tabelle,
        },
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
}
