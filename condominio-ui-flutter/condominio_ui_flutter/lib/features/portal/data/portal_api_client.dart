import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/keycloak_config.dart';
import '../../../utils/api_error.dart';
import '../domain/portal_snapshot_model.dart';

/// API client del portale condomino (self-service).
class PortalApiClient {
  const PortalApiClient();

  Uri _uri(String path) => Uri.parse('${KeycloakAppConfig.coreApiUrl}$path');

  Uri _uriWithQuery(String path, Map<String, String> queryParameters) =>
      _uri(path).replace(queryParameters: queryParameters);

  Map<String, String> _headers(String accessToken) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  Never _throwHttpError(String operation, http.Response response) {
    throw ApiError.fromHttp(operation: operation, response: response);
  }

  Future<PortalSnapshotModel> fetchMySnapshot({
    required String accessToken,
    required String condominioId,
  }) async {
    final response = await http.get(
      _uriWithQuery('/portale/me', {'idCondominio': condominioId}),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchPortalSnapshot', response);
    }
    final raw =
        (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return PortalSnapshotModel.fromJson(raw);
  }
}

