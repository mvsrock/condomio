import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/keycloak_provider.dart';
import '../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../utils/api_error.dart';
import '../data/condomino_api_client.dart';
import '../domain/unita_immobiliare.dart';
import '../domain/unita_titolarita_entry.dart';

class UnitaImmobiliariState {
  const UnitaImmobiliariState({
    required this.items,
    required this.isLoading,
    required this.errorMessage,
  });

  factory UnitaImmobiliariState.initial() {
    return const UnitaImmobiliariState(
      items: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  final List<UnitaImmobiliare> items;
  final bool isLoading;
  final String? errorMessage;

  UnitaImmobiliariState copyWith({
    List<UnitaImmobiliare>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return UnitaImmobiliariState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class UnitaImmobiliariNotifier extends StateNotifier<UnitaImmobiliariState> {
  UnitaImmobiliariNotifier(this._ref, this._api)
      : super(UnitaImmobiliariState.initial());

  final Ref _ref;
  final CondominoApiClient _api;

  String _requireAccessToken() {
    final token = _ref.read(keycloakServiceProvider).accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Sessione scaduta: token assente');
    }
    return token;
  }

  String _requireSelectedCondominioId() {
    final selected = _ref.read(selectedManagedCondominioProvider);
    if (selected == null) {
      throw Exception('Nessun condominio selezionato');
    }
    return selected.id;
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      final items = await _api.fetchUnitaImmobiliari(
        accessToken: token,
        condominioId: condominioId,
      );
      state = state.copyWith(items: items, isLoading: false);
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[UNITA][load] ${e.technicalMessage}');
      } else {
        debugPrint('[UNITA][load] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  Future<void> create(UnitaImmobiliare unita) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      final created = await _api.createUnitaImmobiliare(
        accessToken: token,
        condominioId: condominioId,
        unita: unita,
      );
      state = state.copyWith(
        items: [...state.items, created]
          ..sort((a, b) => a.label.compareTo(b.label)),
        isLoading: false,
      );
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[UNITA][create] ${e.technicalMessage}');
      } else {
        debugPrint('[UNITA][create] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isLoading: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> update(UnitaImmobiliare unita) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      final saved = await _api.updateUnitaImmobiliare(
        accessToken: token,
        condominioId: condominioId,
        unita: unita,
      );
      state = state.copyWith(
        items: state.items
            .map((item) => item.id == saved.id ? saved : item)
            .toList(growable: false),
        isLoading: false,
      );
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[UNITA][update] ${e.technicalMessage}');
      } else {
        debugPrint('[UNITA][update] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isLoading: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> delete(String unitaId) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      await _api.deleteUnitaImmobiliare(
        accessToken: token,
        condominioId: condominioId,
        unitaId: unitaId,
      );
      state = state.copyWith(
        items: state.items.where((item) => item.id != unitaId).toList(growable: false),
        isLoading: false,
      );
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[UNITA][delete] ${e.technicalMessage}');
      } else {
        debugPrint('[UNITA][delete] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isLoading: false, errorMessage: '$e');
      rethrow;
    }
  }

  /// Carica lo storico titolarita' di una unita' su tutti gli esercizi del root.
  Future<List<UnitaTitolaritaEntry>> loadTitolaritaStorico(String unitaId) async {
    final token = _requireAccessToken();
    final condominioId = _requireSelectedCondominioId();
    return _api.fetchUnitaTitolaritaStorico(
      accessToken: token,
      condominioId: condominioId,
      unitaId: unitaId,
    );
  }
}

final unitaImmobiliariProvider =
    StateNotifierProvider<UnitaImmobiliariNotifier, UnitaImmobiliariState>((ref) {
  final api = const CondominoApiClient();
  final notifier = UnitaImmobiliariNotifier(ref, api);
  if (ref.read(selectedManagedCondominioProvider) != null) {
    notifier.load();
  }
  ref.listen<String?>(
    selectedManagedCondominioProvider.select((value) => value?.id),
    (previous, next) {
      if (next == null) return;
      if (previous != next) {
        notifier.load();
      }
    },
  );
  return notifier;
});

final unitaImmobiliariItemsProvider = Provider<List<UnitaImmobiliare>>((ref) {
  return ref.watch(unitaImmobiliariProvider.select((state) => state.items));
});
