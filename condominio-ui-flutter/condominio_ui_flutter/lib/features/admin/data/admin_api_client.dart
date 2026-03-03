import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/keycloak_config.dart';
import '../domain/admin_role.dart';
import '../domain/admin_user.dart';

class AdminApiClient {
  const AdminApiClient();

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse('${KeycloakAppConfig.keycloakServiceUrl}$path').replace(
      queryParameters: queryParameters,
    );
  }

  Map<String, String> _headers(String accessToken) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  Never _throwHttpError(String op, http.Response response) {
    throw Exception(
      '$op failed: status=${response.statusCode}, body=${response.body}',
    );
  }

  Future<List<AdminUser>> fetchUsers({
    required String accessToken,
    int page = 0,
    int size = 50,
  }) async {
    final response = await http.get(
      _uri('/users', {
        'page': '$page',
        'size': '$size',
        'sort': 'username',
        'direction': 'ASC',
      }),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchUsers', response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['content'] as List?) ?? const [];
    return content
        .whereType<Map<String, dynamic>>()
        .map(AdminUser.fromJson)
        .toList();
  }

  Future<void> createUser({
    required String accessToken,
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri('/users'),
      headers: _headers(accessToken),
      body: jsonEncode({
        'username': username.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'password': password,
        'enabled': true,
        'toGroupId': <String>[],
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('createUser', response);
    }
  }

  Future<void> deleteUser({
    required String accessToken,
    required String userId,
  }) async {
    final response = await http.delete(
      _uri('/users/$userId'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('deleteUser', response);
    }
  }

  Future<List<AdminRole>> fetchRoles({
    required String accessToken,
    int page = 0,
    int size = 50,
  }) async {
    final response = await http.get(
      _uri('/roles', {
        'page': '$page',
        'size': '$size',
        'sort': 'roleName',
        'direction': 'ASC',
      }),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchRoles', response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['content'] as List?) ?? const [];
    return content
        .whereType<Map<String, dynamic>>()
        .map(AdminRole.fromJson)
        .toList();
  }

  Future<void> createRole({
    required String accessToken,
    required String roleName,
    required String description,
  }) async {
    final response = await http.post(
      _uri('/roles'),
      headers: _headers(accessToken),
      body: jsonEncode({
        'roleName': roleName.trim(),
        'description': description.trim(),
        'groupIDs': <String>[],
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('createRole', response);
    }
  }

  Future<void> deleteRole({
    required String accessToken,
    required String roleId,
  }) async {
    final response = await http.delete(
      _uri('/roles', {'roleId': roleId}),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('deleteRole', response);
    }
  }
}
