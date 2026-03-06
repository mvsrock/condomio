import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_notifier.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/application/keycloak_provider.dart';
import '../../../utils/api_error.dart';
import '../data/managed_condominio_api_client.dart';
import '../domain/managed_condominio.dart';
import '../domain/managed_condominio_root.dart';

class ManagedCondominioState {
  const ManagedCondominioState({
    required this.items,
    required this.roots,
    required this.selectedId,
    required this.isLoading,
    required this.isCreating,
    required this.isCreatingExercise,
    required this.isClosingExercise,
    required this.ready,
    required this.errorMessage,
  });

  factory ManagedCondominioState.initial() {
    return const ManagedCondominioState(
      items: [],
      roots: [],
      selectedId: null,
      isLoading: false,
      isCreating: false,
      isCreatingExercise: false,
      isClosingExercise: false,
      ready: false,
      errorMessage: null,
    );
  }

  final List<ManagedCondominio> items;
  final List<ManagedCondominioRoot> roots;
  final String? selectedId;
  final bool isLoading;
  final bool isCreating;
  final bool isCreatingExercise;
  final bool isClosingExercise;
  final bool ready;
  final String? errorMessage;

  ManagedCondominioState copyWith({
    List<ManagedCondominio>? items,
    List<ManagedCondominioRoot>? roots,
    String? selectedId,
    bool clearSelectedId = false,
    bool? isLoading,
    bool? isCreating,
    bool? isCreatingExercise,
    bool? isClosingExercise,
    bool? ready,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ManagedCondominioState(
      items: items ?? this.items,
      roots: roots ?? this.roots,
      selectedId: clearSelectedId ? null : (selectedId ?? this.selectedId),
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isCreatingExercise: isCreatingExercise ?? this.isCreatingExercise,
      isClosingExercise: isClosingExercise ?? this.isClosingExercise,
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
      final roots = _canCreateCondominio()
          ? await _api.fetchOwnedRoots(accessToken: token)
          : const <ManagedCondominioRoot>[];
      final selected = _computeSelectedId(items, state.selectedId);
      state = state.copyWith(
        items: items,
        roots: roots,
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
    required double saldoIniziale,
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
      final created = await _api.create(
        accessToken: token,
        label: label,
        anno: anno,
        saldoIniziale: saldoIniziale,
      );
      state = state.copyWith(isCreating: false);
      await loadCondomini();
      if (state.items.any((item) => item.id == created.id)) {
        state = state.copyWith(selectedId: created.id);
      } else if (state.items.length == 1 && state.selectedId == null) {
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

  Future<void> createExercise({
    required String rootId,
    required String label,
    required int anno,
    required double saldoIniziale,
    required bool carryOverBalances,
  }) async {
    if (!_canCreateCondominio()) {
      state = state.copyWith(
        errorMessage:
            'Permesso negato: solo gli amministratori possono creare un esercizio.',
      );
      return;
    }
    state = state.copyWith(
      isCreatingExercise: true,
      clearErrorMessage: true,
    );
    try {
      final token = _requireAccessToken();
      final created = await _api.createExercise(
        accessToken: token,
        rootId: rootId,
        label: label,
        anno: anno,
        saldoIniziale: saldoIniziale,
        carryOverBalances: carryOverBalances,
      );
      state = state.copyWith(isCreatingExercise: false);
      await loadCondomini();
      if (state.items.any((item) => item.id == created.id)) {
        state = state.copyWith(selectedId: created.id);
      }
    } catch (e) {
      if (e is ApiError) {
        debugPrint(
          '[CONDOMINIO_SELECTION][createExercise] ${e.technicalMessage}',
        );
      }
      state = state.copyWith(
        isCreatingExercise: false,
        errorMessage: '$e',
      );
    }
  }

  Future<void> closeSelectedExercise() async {
    final selected = _selectedItem();
    if (selected == null) {
      state = state.copyWith(
        errorMessage: 'Seleziona un esercizio prima di chiuderlo.',
      );
      return;
    }
    if (selected.isClosed) {
      return;
    }
    state = state.copyWith(
      isClosingExercise: true,
      clearErrorMessage: true,
    );
    try {
      final token = _requireAccessToken();
      await _api.closeExercise(accessToken: token, exerciseId: selected.id);
      state = state.copyWith(isClosingExercise: false);
      await loadCondomini();
    } catch (e) {
      if (e is ApiError) {
        debugPrint(
          '[CONDOMINIO_SELECTION][closeExercise] ${e.technicalMessage}',
        );
      }
      state = state.copyWith(
        isClosingExercise: false,
        errorMessage: '$e',
      );
    }
  }

  ManagedCondominio? _selectedItem() {
    final selectedId = state.selectedId;
    if (selectedId == null) return null;
    for (final item in state.items) {
      if (item.id == selectedId) return item;
    }
    return null;
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

/// Flag read-only del contesto attivo.
final selectedManagedCondominioIsClosedProvider = Provider<bool>((ref) {
  return ref.watch(
    selectedManagedCondominioProvider.select((value) => value?.isClosed ?? false),
  );
});

/// Solo gli utenti con ruolo amministratore possono creare condomini.
final canCreateCondominioProvider = Provider<bool>((ref) {
  ref.watch(authSessionRevisionProvider);
  final keycloak = ref.watch(keycloakServiceProvider);
  return keycloak.hasRealmRole('amministratore');
});
