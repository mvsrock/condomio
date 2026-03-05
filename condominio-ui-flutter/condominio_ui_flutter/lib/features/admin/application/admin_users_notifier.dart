import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/keycloak_provider.dart';
import 'admin_providers.dart';
import '../data/admin_api_client.dart';
import '../domain/admin_user.dart';

class AdminUsersState {
  const AdminUsersState({
    required this.items,
    required this.isLoading,
    required this.isCreating,
    required this.deletingIds,
    required this.errorMessage,
  });

  factory AdminUsersState.initial() {
    return const AdminUsersState(
      items: [],
      isLoading: false,
      isCreating: false,
      deletingIds: {},
      errorMessage: null,
    );
  }

  final List<AdminUser> items;
  final bool isLoading;
  final bool isCreating;
  final Set<String> deletingIds;
  final String? errorMessage;

  AdminUsersState copyWith({
    List<AdminUser>? items,
    bool? isLoading,
    bool? isCreating,
    Set<String>? deletingIds,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AdminUsersState(
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

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  AdminUsersNotifier(this._ref, this._api) : super(AdminUsersState.initial());

  final Ref _ref;
  final AdminApiClient _api;

  String _requireAccessToken() {
    final token = _ref.read(keycloakServiceProvider).accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Sessione scaduta: token assente');
    }
    return token;
  }

  bool _isHiddenUser(AdminUser user) {
    return user.username.trim().toLowerCase() == 'svc-admin';
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      final users = await _api.fetchUsers(accessToken: token);
      state = state.copyWith(
        items: users.where((u) => !_isHiddenUser(u)).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  Future<void> createUser({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isCreating: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      final created = await _api.createUser(
        accessToken: token,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      final items = [...state.items];
      if (!_isHiddenUser(created)) {
        items.add(created);
        items.sort((a, b) => a.username.compareTo(b.username));
      }
      state = state.copyWith(isCreating: false, items: items);
    } catch (e) {
      state = state.copyWith(isCreating: false, errorMessage: '$e');
    }
  }

  Future<void> createUserOnly({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isCreating: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      await _api.createUser(
        accessToken: token,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      state = state.copyWith(isCreating: false);
    } catch (e) {
      state = state.copyWith(isCreating: false, errorMessage: '$e');
    }
  }

  Future<void> deleteUser(String userId) async {
    final nextDeleting = {...state.deletingIds, userId};
    state = state.copyWith(deletingIds: nextDeleting, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      await _api.deleteUser(accessToken: token, userId: userId);
      final afterDelete = {...state.deletingIds}..remove(userId);
      final items = state.items
          .where((u) => u.userId != userId)
          .toList(growable: false);
      state = state.copyWith(deletingIds: afterDelete, items: items);
    } catch (e) {
      final afterDelete = {...state.deletingIds}..remove(userId);
      state = state.copyWith(deletingIds: afterDelete, errorMessage: '$e');
    }
  }
}

final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier, AdminUsersState>((ref) {
      final api = ref.watch(adminApiClientProvider);
      return AdminUsersNotifier(ref, api);
    });
