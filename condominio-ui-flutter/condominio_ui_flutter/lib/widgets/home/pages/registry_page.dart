import 'package:flutter/material.dart';

import '../../../models/condomino.dart';

class RegistryPage extends StatelessWidget {
  const RegistryPage({
    super.key,
    required this.condomini,
    required this.selectedCondominoId,
    required this.hoveredCondominoId,
    required this.onHoverChanged,
    required this.onCondominoRowTap,
    required this.onCondominoTap,
    required this.onCondominoEdit,
  });

  final List<Condomino> condomini;
  final String? selectedCondominoId;
  final String? hoveredCondominoId;
  final ValueChanged<String?> onHoverChanged;
  final ValueChanged<Condomino> onCondominoRowTap;
  final ValueChanged<Condomino> onCondominoTap;
  final ValueChanged<Condomino> onCondominoEdit;

  @override
  Widget build(BuildContext context) {
    // Questa pagina riceve gia' i dati filtrati dal parent (`HomeScreen` + Consumer locale).
    // Rebuild tipici:
    // - update lista condomini
    // - cambio riga selezionata / hover
    final residenti = condomini.where((c) => c.residente).length;

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
            _InfoChip(
              label: 'Totale condomini: ${condomini.length}',
              icon: Icons.people_alt_outlined,
            ),
            _InfoChip(label: 'Residenti: $residenti', icon: Icons.home_outlined),
            _InfoChip(
              label: 'Non residenti: ${condomini.length - residenti}',
              icon: Icons.business_center_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Column(
            children: [
              const _RegistryTableHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: condomini.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final condomino = condomini[index];
                    return _RegistryRow(
                      condomino: condomino,
                      isSelected: selectedCondominoId == condomino.id,
                      isHovered: hoveredCondominoId == condomino.id,
                      onHoverChanged: onHoverChanged,
                      onRowTap: () => onCondominoRowTap(condomino),
                      onViewDetail: () => onCondominoTap(condomino),
                      onEdit: () => onCondominoEdit(condomino),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegistryTableHeader extends StatelessWidget {
  const _RegistryTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Nominativo',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Unita',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              'Millesimi',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              'Stato',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _RegistryRow extends StatefulWidget {
  const _RegistryRow({
    required this.condomino,
    required this.isSelected,
    required this.isHovered,
    required this.onHoverChanged,
    required this.onRowTap,
    required this.onViewDetail,
    required this.onEdit,
  });

  final Condomino condomino;
  final bool isSelected;
  final bool isHovered;
  final ValueChanged<String?> onHoverChanged;
  final VoidCallback onRowTap;
  final VoidCallback onViewDetail;
  final VoidCallback onEdit;

  @override
  State<_RegistryRow> createState() => _RegistryRowState();
}

class _RegistryRowState extends State<_RegistryRow> {
  // Stato SOLO locale alla riga:
  // espansione azioni non tocca provider e non richiede rebuild della lista intera.
  bool _isActionsExpanded = false;

  @override
  Widget build(BuildContext context) {
    Color rowColor = Colors.white;
    if (widget.isSelected) {
      rowColor = const Color(0xFFDCECF3);
    } else if (widget.isHovered) {
      rowColor = const Color(0xFFF1F5F9);
    }

    return MouseRegion(
      // Hover propagato al parent per evidenziare riga.
      onEnter: (_) => widget.onHoverChanged(widget.condomino.id),
      onExit: (_) => widget.onHoverChanged(null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: rowColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF155E75)
                : const Color(0xFFD9E2EC),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        widget.onRowTap();
                        setState(() => _isActionsExpanded = !_isActionsExpanded);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                widget.condomino.nominativo,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(flex: 2, child: Text(widget.condomino.unita)),
                            Expanded(
                              child: Text(widget.condomino.millesimi.toStringAsFixed(2)),
                            ),
                            Expanded(
                              child: Text(
                                widget.condomino.residente
                                    ? 'Residente'
                                    : 'Non residente',
                                style: TextStyle(
                                  color: widget.condomino.residente
                                      ? const Color(0xFF147D64)
                                      : const Color(0xFFB9770E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Azioni',
                    onPressed: () {
                      // Questo setState rebuilda solo questa riga.
                      setState(() => _isActionsExpanded = !_isActionsExpanded);
                    },
                    icon: Icon(
                      _isActionsExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 160),
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      // Apre la schermata dettaglio full-screen.
                      onPressed: widget.onViewDetail,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Vedi dettaglio'),
                    ),
                    FilledButton.tonalIcon(
                      // Apre dialog edit nel parent.
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Modifica'),
                    ),
                  ],
                ),
              ),
              crossFadeState: _isActionsExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF334E68)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
