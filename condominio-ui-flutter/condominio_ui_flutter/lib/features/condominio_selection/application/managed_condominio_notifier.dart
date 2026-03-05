import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_notifier.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/application/keycloak_provider.dart';
import '../../../utils/api_error.dart';
import '../data/managed_condominio_api_client.dart';
import '../domain/managed_condominio.dart';

class ManagedCondominioState {
  const ManagedCondominioState({
    required this.items,
    required this.selectedId,
    required this.isLoading,
    required this.isCreating,
    required this.ready,
    required this.errorMessage,
  });

  factory ManagedCondominioState.initial() {
    return const ManagedCondominioState(
      items: [],
      selectedId: null,
      isLoading: false,
      isCreating: false,
      ready: false,
      errorMessage: null,
    );
  }

  final List<ManagedCondominio> items;
  final String? selectedId;
  final bool isLoading;
  final bool isCreating;
  final bool ready;
  final String? errorMessage;

  ManagedCondominioState copyWith({
    List<ManagedCondominio>? items,
    String? selectedId,
    bool clearSelectedId = false,
    bool? isLoading,
    bool? isCreating,
    bool? ready,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ManagedCondominioState(
      items: items ?? this.items,
      selectedId: clearSelectedId ? null : (selectedId ?? this.selectedId),
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      ready: ready ?? this.ready,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class ManagedCondominioNotifier extends StateNotifier<ManagedCondominioState> {
  ManagedCondominioNotifier(this._ref, this._api)
    : super(ManagedCondominioState.initial());

  final Ref _ref;
  final ManagedCondominioApiClient _api;

  String _requireAccessToken() {
    final token = _ref.read(keycloakServiceProvider).accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Sessione scaduta: token assente');
    }
    return token;
  }

  bool _canCreateCondominio() {
    return _ref.read(canCreateCondominioProvider);
  }

  Future<void> bootstrap() async {
    if (state.ready || state.isLoading) return;
    await loadCondomini();
  }

  Future<void> loadCondomini() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      ready: false,
    );
    try {
      final token = _requireAccessToken();
      final items = await _api.fetchMine(accessToken: token);
      final selected = _computeSelectedId(items, state.selectedId);
      state = state.copyWith(
        items: items,
        selectedId: selected,
        isLoading: false,
        ready: true,
      );
    } catch (e) {
      if (e is ApiError) {
        // Manteniamo log tecnico separato dal messaggio utente.
        debugPrint(
          '[CONDOMINIO_SELECTION][loadCondomini] ${e.technicalMessage}',
        );
      }
      state = state.copyWith(isLoading: false, ready: true, errorMessage: '$e');
    }
  }

  String? _computeSelectedId(
    List<ManagedCondominio> items,
    String? currentSelectedId,
  ) {
    if (items.isEmpty) return null;
    if (currentSelectedId == null) return null;
    final exists = items.any((c) => c.id == currentSelectedId);
    return exists ? currentSelectedId : null;
  }

  void select(String condominioId) {
    state = state.copyWith(selectedId: condominioId, clearErrorMessage: true);
  }

  Future<void> createCondominio({
    required String label,
    required int anno,
  }) async {
    if (!_canCreateCondominio()) {
      state = state.copyWith(
        errorMessage:
            'Permesso negato: solo gli amministratori possono creare un condominio.',
      );
      return;
    }
    state = state.copyWith(isCreating: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      await _api.create(accessToken: token, label: label, anno: anno);
      state = state.copyWith(isCreating: false);
      await loadCondomini();
      if (state.items.length == 1 && state.selectedId == null) {
        state = state.copyWith(selectedId: state.items.first.id);
      }
    } catch (e) {
      if (e is ApiError) {
        debugPrint(
          '[CONDOMINIO_SELECTION][createCondominio] ${e.technicalMessage}',
        );
      }
      state = state.copyWith(isCreating: false, errorMessage: '$e');
    }
  }

  void resetForSession() {
    state = ManagedCondominioState.initial();
  }
}

final managedCondominioApiClientProvider = Provider<ManagedCondominioApiClient>(
  (ref) => const ManagedCondominioApiClient(),
);

final managedCondominioProvider =
    StateNotifierProvider<ManagedCondominioNotifier, ManagedCondominioState>((
      ref,
    ) {
      final api = ref.watch(managedCondominioApiClientProvider);
      final notifier = ManagedCondominioNotifier(ref, api);

      ref.listen<AuthState>(authStateProvider, (previous, next) {
        // Reset solo quando la sessione viene realmente chiusa/invalidata.
        // Non usare authSessionRevisionProvider: incrementa anche sul refresh
        // token e causerebbe un ritorno indesiderato alla selezione condominio.
        if (next == AuthState.unauthenticated || next == AuthState.error) {
          notifier.resetForSession();
        }
      });

      return notifier;
    });

final selectedManagedCondominioProvider = Provider<ManagedCondominio?>((ref) {
  final state = ref.watch(managedCondominioProvider);
  if (state.selectedId == null) return null;
  for (final condominio in state.items) {
    if (condominio.id == state.selectedId) return condominio;
  }
  return null;
});

/// Solo gli utenti con ruolo amministratore possono creare condomini.
final canCreateCondominioProvider = Provider<bool>((ref) {
  ref.watch(authSessionRevisionProvider);
  final keycloak = ref.watch(keycloakServiceProvider);
  return keycloak.hasRealmRole('amministratore');
});
