import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/keycloak_config.dart';
import '../domain/managed_condominio.dart';

class ManagedCondominioApiClient {
  const ManagedCondominioApiClient();

  Uri _uri(String path) => Uri.parse('${KeycloakAppConfig.coreApiUrl}$path');

  Map<String, String> _headers(String accessToken) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  Never _throwHttpError(String op, http.Response response) {
    throw Exception(
      '$op failed: status=${response.statusCode}, body=${response.body}',
    );
  }

  Future<List<ManagedCondominio>> fetchMine({
    required String accessToken,
  }) async {
    final response = await http.get(
      _uri('/condominio'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchCondomini', response);
    }
    final list = (jsonDecode(response.body) as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ManagedCondominio.fromJson)
        .toList();
  }

  Future<void> create({
    required String accessToken,
    required String label,
    required int anno,
  }) async {
    final response = await http.post(
      _uri('/condominio'),
      headers: _headers(accessToken),
      body: jsonEncode({
        'label': label.trim(),
        'anno': anno,
        'residuo': 0,
        'configurazioniSpesa': <Map<String, Object?>>[],
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('createCondominio', response);
    }
  }
}
