import 'package:flutter/material.dart';

import 'registry_types.dart';

/// Header tabella anagrafica con colonne ordinabili.
///
/// Questo widget e' puramente presentazionale:
/// - non mantiene stato;
/// - inoltra click colonna al callback `onSort`.
class RegistryTableHeader extends StatelessWidget {
  const RegistryTableHeader({
    super.key,
    required this.sortField,
    required this.sortAscending,
    required this.onSort,
  });

  final RegistrySortField? sortField;
  final bool sortAscending;
  final ValueChanged<RegistrySortField> onSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Row(
        children: [
          _sortableLabel('Nominativo', RegistrySortField.nominativo, flex: 3),
          _sortableLabel('Unita', RegistrySortField.unita, flex: 2),
          _sortableLabel('Millesimi', RegistrySortField.millesimi),
          _sortableLabel('Stato', RegistrySortField.stato),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _sortableLabel(String label, RegistrySortField field, {int flex = 1}) {
    final isActive = sortField == field;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => onSort(field),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: isActive ? const Color(0xFF155E75) : null,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: const Color(0xFF155E75),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
