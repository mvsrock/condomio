import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/keycloak_provider.dart';
import 'admin_providers.dart';
import '../data/admin_api_client.dart';
import '../domain/admin_role.dart';

class AdminRolesState {
  const AdminRolesState({
    required this.items,
    required this.isLoading,
    required this.isCreating,
    required this.deletingIds,
    required this.errorMessage,
  });

  factory AdminRolesState.initial() {
    return const AdminRolesState(
      items: [],
      isLoading: false,
      isCreating: false,
      deletingIds: {},
      errorMessage: null,
    );
  }

  final List<AdminRole> items;
  final bool isLoading;
  final bool isCreating;
  final Set<String> deletingIds;
  final String? errorMessage;

  AdminRolesState copyWith({
    List<AdminRole>? items,
    bool? isLoading,
    bool? isCreating,
    Set<String>? deletingIds,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AdminRolesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      deletingIds: deletingIds ?? this.deletingIds,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class AdminRolesNotifier extends StateNotifier<AdminRolesState> {
  AdminRolesNotifier(this._ref, this._api) : super(AdminRolesState.initial());

  final Ref _ref;
  final AdminApiClient _api;

  String _requireAccessToken() {
    final token = _ref.read(keycloakServiceProvider).accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Sessione scaduta: token assente');
    }
    return token;
  }

  bool _isHiddenRole(AdminRole role) {
    return role.roleName.trim().toLowerCase() == 'authority_admin';
  }

  Future<void> loadRoles() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      final roles = await _api.fetchRoles(accessToken: token);
      state = state.copyWith(
        items: roles.where((r) => !_isHiddenRole(r)).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  Future<void> createRole({
    required String roleName,
    required String description,
  }) async {
    state = state.copyWith(isCreating: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      await _api.createRole(
        accessToken: token,
        roleName: roleName,
        description: description,
      );
      state = state.copyWith(isCreating: false);
      await loadRoles();
    } catch (e) {
      state = state.copyWith(isCreating: false, errorMessage: '$e');
    }
  }

  Future<void> deleteRole(String roleId) async {
    final nextDeleting = {...state.deletingIds, roleId};
    state = state.copyWith(deletingIds: nextDeleting, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      await _api.deleteRole(accessToken: token, roleId: roleId);
      final afterDelete = {...state.deletingIds}..remove(roleId);
      state = state.copyWith(deletingIds: afterDelete);
      await loadRoles();
    } catch (e) {
      final afterDelete = {...state.deletingIds}..remove(roleId);
      state = state.copyWith(deletingIds: afterDelete, errorMessage: '$e');
    }
  }
}

final adminRolesProvider =
    StateNotifierProvider<AdminRolesNotifier, AdminRolesState>((ref) {
      final api = ref.watch(adminApiClientProvider);
      return AdminRolesNotifier(ref, api);
    });
