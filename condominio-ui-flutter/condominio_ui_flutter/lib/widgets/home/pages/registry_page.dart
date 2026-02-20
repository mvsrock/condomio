import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/condomino.dart';
import '../../../providers/registry_table_provider.dart';
import 'registry_filters_bar.dart';
import 'registry_info_chip.dart';
import 'registry_pagination_bar.dart';
import 'registry_row.dart';
import 'registry_table_header.dart';
import 'registry_types.dart';

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
    required this.condomini,
    required this.selectedCondominoId,
    required this.onCondominoRowTap,
    required this.onCondominoTap,
    required this.onCondominoEdit,
  });

  final List<Condomino> condomini;
  final String? selectedCondominoId;
  final ValueChanged<Condomino> onCondominoRowTap;
  final ValueChanged<Condomino> onCondominoTap;
  final ValueChanged<Condomino> onCondominoEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(registryTableProvider);
    final tableNotifier = ref.read(registryTableProvider.notifier);

    final filteredSorted = _buildFilteredSorted(
      source: condomini,
      tableState: tableState,
    );
    final totalItems = filteredSorted.length;
    final totalPages =
        totalItems == 0 ? 1 : (totalItems / tableState.rowsPerPage).ceil();

    // Evitiamo mutazioni di stato in build: usiamo un indice pagina "safe" locale.
    final safePageIndex = tableState.pageIndex
        .clamp(0, totalPages - 1)
        .toInt();
    final start = (safePageIndex * tableState.rowsPerPage)
        .clamp(0, totalItems)
        .toInt();
    final end = (start + tableState.rowsPerPage).clamp(0, totalItems).toInt();
    final paged = filteredSorted.sublist(start, end);
    final residenti = filteredSorted.where((c) => c.residente).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anagrafica Condomini',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            RegistryInfoChip(
              label: 'Totale visibili: ${filteredSorted.length}',
              icon: Icons.people_alt_outlined,
            ),
            RegistryInfoChip(
              label: 'Residenti: $residenti',
              icon: Icons.home_outlined,
            ),
            RegistryInfoChip(
              label: 'Non residenti: ${filteredSorted.length - residenti}',
              icon: Icons.business_center_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        RegistryFiltersBar(
          searchQuery: tableState.searchQuery,
          onSearchChanged: tableNotifier.setSearchQuery,
          residentFilter: tableState.residentFilter,
          onSetResidentFilter: tableNotifier.setResidentFilter,
          onClearSearch: tableNotifier.clearSearch,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Column(
            children: [
              RegistryTableHeader(
                sortField: tableState.sortField,
                sortAscending: tableState.sortAscending,
                onSort: tableNotifier.toggleSort,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: paged.isEmpty
                    ? const Center(
                        child: Text('Nessun risultato per i filtri impostati.'),
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
  }

  /// Pipeline dati tabella:
  /// 1) filtro residente
  /// 2) filtro testuale
  /// 3) ordinamento opzionale
  List<Condomino> _buildFilteredSorted({
    required List<Condomino> source,
    required RegistryTableState tableState,
  }) {
    final query = tableState.searchQuery.trim().toLowerCase();
    final result = source.where((c) {
      if (tableState.residentFilter != null &&
          c.residente != tableState.residentFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      return c.nominativo.toLowerCase().contains(query) ||
          c.unita.toLowerCase().contains(query) ||
          c.email.toLowerCase().contains(query) ||
          c.telefono.toLowerCase().contains(query);
    }).toList(growable: false);

    if (tableState.sortField != null) {
      result.sort((a, b) {
        int cmp;
        switch (tableState.sortField!) {
          case RegistrySortField.nominativo:
            cmp = a.nominativo.compareTo(b.nominativo);
            break;
          case RegistrySortField.unita:
            cmp = a.unita.compareTo(b.unita);
            break;
          case RegistrySortField.millesimi:
            cmp = a.millesimi.compareTo(b.millesimi);
            break;
          case RegistrySortField.stato:
            cmp = (a.residente ? 1 : 0).compareTo(b.residente ? 1 : 0);
            break;
        }
        return tableState.sortAscending ? cmp : -cmp;
      });
    }
    return result;
  }
}
