import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/keycloak_config.dart';
import '../../../utils/api_error.dart';
import '../domain/managed_condominio.dart';
import '../domain/managed_condominio_root.dart';

/// Client HTTP del modulo selezione contesto.
///
/// Espone due concetti distinti:
/// - `condomini`: root stabili del dominio
/// - `esercizi`: contesti annuali/gestionali su cui l'app opera davvero
class ManagedCondominioApiClient {
  const ManagedCondominioApiClient();

  Uri _uri(String path) => Uri.parse('${KeycloakAppConfig.coreApiUrl}$path');

  Uri _uriWithQuery(String path, Map<String, String> queryParameters) =>
      _uri(path).replace(queryParameters: queryParameters);

  Map<String, String> _headers(String accessToken) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  Never _throwHttpError(String op, http.Response response) {
    throw ApiError.fromHttp(operation: op, response: response);
  }

  Future<List<ManagedCondominio>> fetchMine({
    required String accessToken,
  }) async {
    final response = await http.get(
      _uri('/esercizi'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchEsercizi', response);
    }
    final list = (jsonDecode(response.body) as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ManagedCondominio.fromJson)
        .toList();
  }

  Future<List<ManagedCondominioRoot>> fetchOwnedRoots({
    required String accessToken,
  }) async {
    final response = await http.get(
      _uri('/condomini'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchCondomini', response);
    }
    final list = (jsonDecode(response.body) as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ManagedCondominioRoot.fromJson)
        .toList();
  }

  Future<ManagedCondominio> create({
    required String accessToken,
    required String label,
    required int anno,
    required double saldoIniziale,
  }) async {
    final response = await http.post(
      _uri('/condomini'),
      headers: _headers(accessToken),
      body: jsonEncode({
        'label': label.trim(),
        'gestioneLabel': 'Ordinaria',
        'anno': anno,
        // In creazione il backend inizializza residuo a saldoIniziale.
        'saldoIniziale': saldoIniziale,
        'configurazioniSpesa': <Map<String, Object?>>[],
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('createCondominio', response);
    }
    return ManagedCondominio.fromJson(
      (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
    );
  }

  Future<ManagedCondominio> createExercise({
    required String accessToken,
    required String rootId,
    required String label,
    required String gestioneLabel,
    required int anno,
    required double saldoIniziale,
    required bool carryOverBalances,
  }) async {
    final response = await http.post(
      _uriWithQuery('/condomini/$rootId/esercizi', {
        'carryOverBalances': carryOverBalances.toString(),
      }),
      headers: _headers(accessToken),
      body: jsonEncode({
        'label': label.trim(),
        'gestioneLabel': gestioneLabel.trim(),
        'anno': anno,
        'saldoIniziale': saldoIniziale,
        'configurazioniSpesa': <Map<String, Object?>>[],
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('createEsercizio', response);
    }
    return ManagedCondominio.fromJson(
      (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
    );
  }

  Future<void> closeExercise({
    required String accessToken,
    required String exerciseId,
  }) async {
    final response = await http.post(
      _uri('/esercizi/$exerciseId/close'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('closeEsercizio', response);
    }
  }
}
