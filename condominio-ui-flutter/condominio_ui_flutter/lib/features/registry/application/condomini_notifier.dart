import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/keycloak_provider.dart';
import '../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../utils/api_error.dart';
import '../data/condomino_api_client.dart';
import '../domain/condomino.dart';

class CondominiState {
  const CondominiState({
    required this.items,
    required this.isLoading,
    required this.errorMessage,
  });

  factory CondominiState.initial() {
    return const CondominiState(
      items: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  final List<Condomino> items;
  final bool isLoading;
  final String? errorMessage;

  CondominiState copyWith({
    List<Condomino>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CondominiState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier dominio anagrafica (fonte dati: backend `core`).
///
/// Responsabilita':
/// - caricare la lista condomini per condominio attivo
/// - creare/aggiornare record su API `core`
/// - mantenere stato UI (`loading`/`error`) riusabile dai widget
class CondominiNotifier extends StateNotifier<CondominiState> {
  CondominiNotifier(this._ref, this._api) : super(CondominiState.initial());

  final Ref _ref;
  final CondominoApiClient _api;

  String _requireAccessToken() {
    final token = _ref.read(keycloakServiceProvider).accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Sessione scaduta: token assente');
    }
    return token;
  }

  /// Richiede che sia stato selezionato un condominio attivo nel flusso post-login.
  String _requireSelectedCondominioId() {
    final selected = _ref.read(selectedManagedCondominioProvider);
    if (selected == null) {
      throw Exception('Nessun condominio selezionato');
    }
    return selected.id;
  }

  void _ensureSelectedExerciseWritable() {
    final selected = _ref.read(selectedManagedCondominioProvider);
    if (selected == null) {
      throw Exception('Nessun condominio selezionato');
    }
    if (selected.isClosed) {
      throw Exception(
        'Esercizio chiuso: modifica anagrafica non consentita in modalita sola lettura.',
      );
    }
  }

  /// Ricarica l'anagrafica dal backend per il condominio attivo.
  Future<void> loadForSelectedCondominio() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      final items = await _api.fetchCondomini(
        accessToken: token,
        condominioId: condominioId,
      );
      state = state.copyWith(items: items, isLoading: false);
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[REGISTRY][loadForSelectedCondominio] ${e.technicalMessage}');
      } else {
        debugPrint('[REGISTRY][loadForSelectedCondominio] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  /// Crea un nuovo condomino su backend e riallinea la lista locale.
  Future<void> createCondomino(Condomino condomino) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      final created = await _api.createCondomino(
        accessToken: token,
        condomino: condomino,
        condominioId: condominioId,
      );
      final nextItems = [...state.items, created];
      nextItems.sort((a, b) => a.nominativo.compareTo(b.nominativo));
      state = state.copyWith(items: nextItems, isLoading: false);
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[REGISTRY][createCondomino] ${e.technicalMessage}');
      } else {
        debugPrint('[REGISTRY][createCondomino] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isLoading: false, errorMessage: '$e');
      rethrow;
    }
  }

  /// Aggiorna un condomino su backend e riallinea la lista locale.
  Future<void> updateCondomino(Condomino updated) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      final saved = await _api.updateCondomino(
        accessToken: token,
        condomino: updated,
        condominioId: condominioId,
      );
      final nextItems = state.items
          .map((item) => item.id == saved.id ? saved : item)
          .toList(growable: false);
      state = state.copyWith(items: nextItems, isLoading: false);
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[REGISTRY][updateCondomino] ${e.technicalMessage}');
      } else {
        debugPrint('[REGISTRY][updateCondomino] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isLoading: false, errorMessage: '$e');
      rethrow;
    }
  }

  void clear() {
    state = CondominiState.initial();
  }
}

final condominoApiClientProvider = Provider<CondominoApiClient>((ref) {
  return const CondominoApiClient();
});

final condominiProvider =
    StateNotifierProvider<CondominiNotifier, CondominiState>((ref) {
      final api = ref.watch(condominoApiClientProvider);
      final notifier = CondominiNotifier(ref, api);
      if (ref.read(selectedManagedCondominioProvider) != null) {
        notifier.loadForSelectedCondominio();
      }
      ref.listen<String?>(
        selectedManagedCondominioProvider.select((value) => value?.id),
        (previous, next) {
          if (next == null) {
            notifier.clear();
            return;
          }
          // Su cambio condominio attivo, la tab anagrafica deve sempre riflettere
          // il dataset del nuovo contesto.
          if (previous != next) {
            notifier.loadForSelectedCondominio();
          }
        },
      );
      return notifier;
    });

final condominiItemsProvider = Provider<List<Condomino>>((ref) {
  return ref.watch(condominiProvider.select((state) => state.items));
});
