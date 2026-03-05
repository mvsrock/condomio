import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/keycloak_config.dart';
import '../domain/condomino.dart';

class CondominoApiClient {
  const CondominoApiClient();

  Uri _uri(String path) => Uri.parse('${KeycloakAppConfig.coreApiUrl}$path');

  Map<String, String> _jsonHeaders(String accessToken) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  Map<String, String> _mergePatchHeaders(String accessToken) => {
    'Content-Type': 'application/merge-patch+json',
    'Authorization': 'Bearer $accessToken',
  };

  Never _throwHttpError(String op, http.Response response) {
    throw Exception(
      '$op failed: status=${response.statusCode}, body=${response.body}',
    );
  }

  Future<List<Condomino>> fetchCondomini({
    required String accessToken,
    required String condominioId,
  }) async {
    final response = await http.get(
      _uri('/condomino'),
      headers: _jsonHeaders(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchCondomini', response);
    }
    final raw = (jsonDecode(response.body) as List?) ?? const [];
    // Endpoint `core` non filtra ancora per condominio lato API:
    // applichiamo filtro client-side per mantenere isolamento tenant UI.
    return raw
        .whereType<Map<String, dynamic>>()
        .where((e) => (e['idCondominio'] ?? '').toString() == condominioId)
        .map(Condomino.fromCoreJson)
        .toList();
  }

  Future<Condomino> createCondomino({
    required String accessToken,
    required Condomino condomino,
    required String condominioId,
  }) async {
    // Backend core espone creazione/replace via PUT sul resource endpoint.
    final response = await http.put(
      _uri('/condomino'),
      headers: _jsonHeaders(accessToken),
      body: jsonEncode(condomino.toCoreJson(condominioId: condominioId)),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('createCondomino', response);
    }
    final json = (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return Condomino.fromCoreJson(json);
  }

  Future<Condomino> updateCondomino({
    required String accessToken,
    required Condomino condomino,
    required String condominioId,
  }) async {
    // Modifica incrementale: solo PATCH (nessun fallback).
    final payload = condomino.toCoreJson(condominioId: condominioId);
    final response = await http.patch(
      _uri('/condomino/${condomino.id}'),
      headers: _mergePatchHeaders(accessToken),
      body: jsonEncode(payload),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('updateCondominoPatch', response);
    }
    final json = (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return Condomino.fromCoreJson(json);
  }
}
