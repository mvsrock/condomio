import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_breakpoints.dart';
import '../../application/registry_table_notifier.dart';
import '../../application/condomini_notifier.dart';
import '../../domain/condomino.dart';
import '../widgets/registry_filters_bar.dart';
import '../widgets/registry_info_chip.dart';
import '../widgets/registry_pagination_bar.dart';
import '../widgets/registry_row.dart';
import '../widgets/registry_table_header.dart';

/// Pagina anagrafica:
/// - osserva dati dominio (`condomini`) via parametro
/// - osserva stato tabella (search/sort/filter/pagination) via Riverpod
/// - delega rendering a widget UI separati
///
/// Strategia rebuild:
/// - questa pagina si ricostruisce quando cambia `registryTableProvider`
///   o quando cambia lista `condomini` passata dal parent.
/// - ogni riga resta isolata in `RegistryRow` (stato espansione locale di riga).
class RegistryPage extends ConsumerWidget {
  const RegistryPage({
    super.key,
    required this.selectedCondominoId,
    required this.canEditCondomino,
    required this.onCondominoRowTap,
    required this.onCondominoTap,
    required this.onCondominoEdit,
  });

  final String? selectedCondominoId;
  final bool Function(Condomino) canEditCondomino;
  final ValueChanged<Condomino> onCondominoRowTap;
  final ValueChanged<Condomino> onCondominoTap;
  final ValueChanged<Condomino> onCondominoEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(registryTableProvider);
    final tableNotifier = ref.read(registryTableProvider.notifier);
    final filteredSorted = ref.watch(registryFilteredSortedProvider);
    final allItems = ref.watch(condominiItemsProvider);
    final totalItems = filteredSorted.length;
    final totalPages =
        totalItems == 0 ? 1 : (totalItems / tableState.rowsPerPage).ceil();
    final activeCount = allItems.where((item) => item.isActivePosition).length;
    final ceasedCount = allItems.length - activeCount;

    // Evitiamo mutazioni di stato in build: usiamo un indice pagina "safe" locale.
    final safePageIndex = tableState.pageIndex
        .clamp(0, totalPages - 1)
        .toInt();
    final start = (safePageIndex * tableState.rowsPerPage)
        .clamp(0, totalItems)
        .toInt();
    final end = (start + tableState.rowsPerPage).clamp(0, totalItems).toInt();
    final paged = filteredSorted.sublist(start, end);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = AppBreakpoints.isRegistryCompact(
          constraints.maxWidth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                RegistryInfoChip(
                  label: 'Totale visibili: ${filteredSorted.length}',
                  icon: Icons.people_alt_outlined,
                ),
                RegistryInfoChip(
                  label: 'Attivi: $activeCount',
                  icon: Icons.how_to_reg_outlined,
                ),
                RegistryInfoChip(
                  label: 'Cessati: $ceasedCount',
                  icon: Icons.history_toggle_off_outlined,
                ),
                RegistryInfoChip(
                  label: 'Pagina ${safePageIndex + 1} di $totalPages',
                  icon: Icons.format_list_numbered_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            RegistryFiltersBar(
              searchQuery: tableState.searchQuery,
              showCeased: tableState.showCeased,
              onSearchChanged: tableNotifier.setSearchQuery,
              onClearSearch: tableNotifier.clearSearch,
              onShowCeasedChanged: tableNotifier.setShowCeased,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                children: [
                  if (!isCompact) ...[
                    RegistryTableHeader(
                      sortField: tableState.sortField,
                      sortAscending: tableState.sortAscending,
                      onSort: tableNotifier.toggleSort,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Expanded(
                    child: paged.isEmpty
                        ? const Center(
                            child: Text(
                              'Nessun risultato per i filtri impostati.',
                            ),
                          )
                        : ListView.separated(
                            itemCount: paged.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final condomino = paged[index];
                              return RegistryRow(
                                key: ValueKey(condomino.id),
                                condomino: condomino,
                                isSelected: selectedCondominoId == condomino.id,
                                canEdit: canEditCondomino(condomino),
                                onRowTap: () => onCondominoRowTap(condomino),
                                onViewDetail: () => onCondominoTap(condomino),
                                onEdit: () => onCondominoEdit(condomino),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  RegistryPaginationBar(
                    totalItems: totalItems,
                    start: start,
                    end: end,
                    totalPages: totalPages,
                    pageIndex: safePageIndex,
                    rowsPerPage: tableState.rowsPerPage,
                    onRowsPerPageChanged: tableNotifier.setRowsPerPage,
                    onPrevPage: safePageIndex == 0
                        ? null
                        : tableNotifier.prevPage,
                    onNextPage: safePageIndex >= totalPages - 1
                        ? null
                        : () => tableNotifier.nextPage(totalPages),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
