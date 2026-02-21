import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/home/pages/registry/registry_types.dart';

/// Stato UI della tabella anagrafica.
///
/// Include solo presentazione:
/// - query ricerca
/// - filtro residente
/// - ordinamento
/// - paginazione
///
/// Non contiene dati dominio (lista condomini), che restano in `condominiProvider`.
class RegistryTableState {
  const RegistryTableState({
    required this.searchQuery,
    required this.sortField,
    required this.sortAscending,
    required this.residentFilter,
    required this.rowsPerPage,
    required this.pageIndex,
  });

  factory RegistryTableState.initial() {
    return const RegistryTableState(
      searchQuery: '',
      sortField: null,
      sortAscending: true,
      residentFilter: null,
      rowsPerPage: 8,
      pageIndex: 0,
    );
  }

  final String searchQuery;
  final RegistrySortField? sortField;
  final bool sortAscending;
  final bool? residentFilter;
  final int rowsPerPage;
  final int pageIndex;

  RegistryTableState copyWith({
    String? searchQuery,
    RegistrySortField? sortField,
    bool clearSortField = false,
    bool? sortAscending,
    bool? residentFilter,
    bool clearResidentFilter = false,
    int? rowsPerPage,
    int? pageIndex,
  }) {
    return RegistryTableState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortField: clearSortField ? null : (sortField ?? this.sortField),
      sortAscending: sortAscending ?? this.sortAscending,
      residentFilter: clearResidentFilter
          ? null
          : (residentFilter ?? this.residentFilter),
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }
}

/// Notifier UI-only della tabella anagrafica.
class RegistryTableNotifier extends StateNotifier<RegistryTableState> {
  RegistryTableNotifier() : super(RegistryTableState.initial());

  /// Aggiorna la ricerca e torna sempre a pagina 1.
  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value, pageIndex: 0);
  }

  /// Pulisce query ricerca e torna a pagina 1.
  void clearSearch() {
    state = state.copyWith(searchQuery: '', pageIndex: 0);
  }

  /// Imposta filtro residente (null = tutti) e torna a pagina 1.
  void setResidentFilter(bool? value) {
    state = value == null
        ? state.copyWith(clearResidentFilter: true, pageIndex: 0)
        : state.copyWith(residentFilter: value, pageIndex: 0);
  }

  /// Ordinamento a 3 stati sulla colonna cliccata:
  /// none -> asc -> desc -> none.
  void toggleSort(RegistrySortField field) {
    if (state.sortField == null) {
      state = state.copyWith(
        sortField: field,
        sortAscending: true,
        pageIndex: 0,
      );
      return;
    }
    if (state.sortField == field && state.sortAscending) {
      state = state.copyWith(sortAscending: false, pageIndex: 0);
      return;
    }
    if (state.sortField == field && !state.sortAscending) {
      state = state.copyWith(
        clearSortField: true,
        sortAscending: true,
        pageIndex: 0,
      );
      return;
    }
    state = state.copyWith(sortField: field, sortAscending: true, pageIndex: 0);
  }

  /// Cambia righe per pagina e torna a pagina 1.
  void setRowsPerPage(int value) {
    state = state.copyWith(rowsPerPage: value, pageIndex: 0);
  }

  /// Pagina precedente (se possibile).
  void prevPage() {
    if (state.pageIndex <= 0) return;
    state = state.copyWith(pageIndex: state.pageIndex - 1);
  }

  /// Pagina successiva (limite passato dalla UI derivata).
  void nextPage(int totalPages) {
    if (state.pageIndex >= totalPages - 1) return;
    state = state.copyWith(pageIndex: state.pageIndex + 1);
  }

  /// Clampa l'indice pagina quando filtri/sorting riducono i risultati.
  void clampPageIndex(int totalPages) {
    final safeTotalPages = totalPages <= 0 ? 1 : totalPages;
    final maxIndex = safeTotalPages - 1;
    if (state.pageIndex <= maxIndex) return;
    state = state.copyWith(pageIndex: maxIndex);
  }
}

/// Provider autoDispose:
/// - vive finche' RegistryPage e' visibile
/// - si resetta automaticamente quando si esce dalla pagina/tab.
final registryTableProvider =
    StateNotifierProvider.autoDispose<RegistryTableNotifier, RegistryTableState>(
      (ref) => RegistryTableNotifier(),
    );
