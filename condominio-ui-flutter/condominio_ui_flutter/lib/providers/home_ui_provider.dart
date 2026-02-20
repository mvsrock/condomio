import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stato UI locale della Home.
///
/// Importante:
/// - NON contiene dati dominio (quelli stanno in altri provider, es. anagrafica);
/// - contiene solo stato di presentazione/navigazione della schermata.
class HomeUiState {
  const HomeUiState({
    required this.selectedIndex,
    required this.selectedCondominoId,
    required this.isLoggingOut,
  });

  factory HomeUiState.initial() {
    return const HomeUiState(
      selectedIndex: 0,
      selectedCondominoId: null,
      isLoggingOut: false,
    );
  }

  final int selectedIndex;
  final String? selectedCondominoId;
  final bool isLoggingOut;

  HomeUiState copyWith({
    int? selectedIndex,
    String? selectedCondominoId,
    bool clearSelectedCondominoId = false,
    bool? isLoggingOut,
  }) {
    // `clear*` serve per distinguere:
    // - "mantieni valore corrente"
    // - "imposta esplicitamente a null"
    return HomeUiState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedCondominoId: clearSelectedCondominoId
          ? null
          : (selectedCondominoId ?? this.selectedCondominoId),
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }
}

class HomeUiNotifier extends StateNotifier<HomeUiState> {
  HomeUiNotifier() : super(HomeUiState.initial());

  /// Cambio tab principale.
  ///
  /// Effetto rebuild:
  /// - aggiorna `selectedIndex`
  /// - i widget che osservano `selectedIndex` con `select` rebuildano
  /// - gli altri listener di `HomeUiState` non necessariamente rebuildano
  ///   se usano anch'essi `select` su campi diversi.
  void selectTab(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  /// Memorizza la riga attiva (usata per highlight e dettaglio).
  void selectCondomino(String id) {
    state = state.copyWith(selectedCondominoId: id);
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
