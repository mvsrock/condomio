import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stato UI locale della Home.
///
/// Importante:
/// - NON contiene dati dominio (quelli stanno in altri provider, es. anagrafica);
/// - contiene solo stato di presentazione/navigazione della schermata.
class HomeUiState {
  const HomeUiState({
    required this.selectedCondominoId,
    required this.isLoggingOut,
  });

  factory HomeUiState.initial() {
    return const HomeUiState(
      selectedCondominoId: null,
      isLoggingOut: false,
    );
  }

  final String? selectedCondominoId;
  final bool isLoggingOut;

  HomeUiState copyWith({
    String? selectedCondominoId,
    bool clearSelectedCondominoId = false,
    bool? isLoggingOut,
  }) {
    // `clear*` serve per distinguere:
    // - "mantieni valore corrente"
    // - "imposta esplicitamente a null"
    return HomeUiState(
      selectedCondominoId: clearSelectedCondominoId
          ? null
          : (selectedCondominoId ?? this.selectedCondominoId),
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }
}

class HomeUiNotifier extends StateNotifier<HomeUiState> {
  HomeUiNotifier() : super(HomeUiState.initial());

  /// Memorizza la riga attiva (usata per highlight e dettaglio).
  void selectCondomino(String id) {
    state = state.copyWith(selectedCondominoId: id);
  }

  void clearSelectedCondomino() {
    state = state.copyWith(clearSelectedCondominoId: true);
  }

  /// Flag UI per overlay durante logout in corso.
  void setLoggingOut(bool value) {
    state = state.copyWith(isLoggingOut: value);
  }
}

/// Provider UI di Home.
///
/// Uso consigliato:
/// - `ref.watch(homeUiProvider.select(...))` per ridurre rebuild
/// - `ref.read(homeUiProvider.notifier)` per invocare azioni UI
final homeUiProvider = StateNotifierProvider<HomeUiNotifier, HomeUiState>((
  ref,
) {
  return HomeUiNotifier();
});
