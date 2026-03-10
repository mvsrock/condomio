import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/keycloak_config.dart';
import '../../../utils/api_error.dart';
import '../domain/admin_group.dart';
import '../domain/admin_role.dart';
import '../domain/admin_user.dart';

class AdminApiClient {
  const AdminApiClient();

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse(
      '${KeycloakAppConfig.coreApiUrl}/keycloak-admin$path',
    ).replace(
      queryParameters: queryParameters,
    );
  }

  Map<String, String> _headers(String accessToken) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  Never _throwHttpError(String op, http.Response response) {
    throw ApiError.fromHttp(operation: op, response: response);
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

  Future<AdminUser> createUser({
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
    final json = (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return AdminUser.fromJson(json);
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

  Future<List<AdminGroup>> fetchGroups({
    required String accessToken,
    int page = 0,
    int size = 200,
  }) async {
    final response = await http.get(
      _uri('/groups', {
        'page': '$page',
        'size': '$size',
        'sort': 'groupName',
        'direction': 'ASC',
      }),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('fetchGroups', response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['content'] as List?) ?? const [];
    return content
        .whereType<Map<String, dynamic>>()
        .map(AdminGroup.fromJson)
        .toList(growable: false);
  }

  /// Aggiorna gruppo/ruolo di un utente Keycloak tramite endpoint `/users`.
  Future<void> updateUserGroup({
    required String accessToken,
    required AdminUser user,
    required String fromGroupId,
    required String toGroupId,
  }) async {
    final response = await http.put(
      _uri('/users'),
      headers: _headers(accessToken),
      body: jsonEncode({
        'userId': user.userId,
        'username': user.username,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'password': null,
        'enabled': user.enabled,
        'fromGroupId': fromGroupId,
        'toGroupId': [toGroupId],
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('updateUserGroup', response);
    }
  }

  /// Assegna uno o piu' gruppi a un utente senza richiedere `fromGroupId`.
  ///
  /// Utile come fallback quando il backend utenti non espone il gruppo corrente
  /// (caso legacy/inconsistente): consente comunque di propagare il ruolo
  /// verso Keycloak.
  Future<void> addUserToGroups({
    required String accessToken,
    required String userId,
    required List<String> groupIds,
  }) async {
    final response = await http.post(
      _uri('/users/$userId/add_groups'),
      headers: _headers(accessToken),
      body: jsonEncode({'groupIds': groupIds}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('addUserToGroups', response);
    }
  }

  /// Aggiorna il ruolo applicativo utente con endpoint semantico backend.
  Future<void> updateUserAppRole({
    required String accessToken,
    required String userId,
    required String roleName,
  }) async {
    final response = await http.put(
      _uri('/users/$userId/app-role'),
      headers: _headers(accessToken),
      body: jsonEncode({'roleName': roleName}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('updateUserAppRole', response);
    }
  }

  Future<AdminRole> createRole({
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
    final json = (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return AdminRole(
      roleId: (json['roleId'] ?? json['id'] ?? '').toString(),
      roleName: (json['roleName'] ?? json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      groupIds: const [],
    );
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
