import 'package:flutter/material.dart';

/// Barra paginazione tabella anagrafica.
///
/// Solo UI: riceve valori gia' calcolati e callback di navigazione pagina.
class RegistryPaginationBar extends StatelessWidget {
  const RegistryPaginationBar({
    super.key,
    required this.totalItems,
    required this.start,
    required this.end,
    required this.totalPages,
    required this.pageIndex,
    required this.rowsPerPage,
    required this.onRowsPerPageChanged,
    required this.onPrevPage,
    required this.onNextPage,
  });

  final int totalItems;
  final int start;
  final int end;
  final int totalPages;
  final int pageIndex;
  final int rowsPerPage;
  final ValueChanged<int> onRowsPerPageChanged;
  final VoidCallback? onPrevPage;
  final VoidCallback? onNextPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          totalItems == 0 ? '0 risultati' : 'Risultati ${start + 1}-$end di $totalItems',
          style: const TextStyle(color: Color(0xFF52606D)),
        ),
        const Spacer(),
        const Text('Righe'),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: rowsPerPage,
          onChanged: (value) {
            if (value == null) return;
            onRowsPerPageChanged(value);
          },
          items: const [
            DropdownMenuItem(value: 5, child: Text('5')),
            DropdownMenuItem(value: 8, child: Text('8')),
            DropdownMenuItem(value: 10, child: Text('10')),
            DropdownMenuItem(value: 20, child: Text('20')),
          ],
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onPrevPage,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('${pageIndex + 1}/$totalPages'),
        IconButton(
          onPressed: onNextPage,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
