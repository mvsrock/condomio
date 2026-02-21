import 'package:flutter/material.dart';

import '../../../../models/condomino.dart';

/// Riga tabella anagrafica.
///
/// Stato locale interno:
/// - `_isHovered` per effetto hover desktop/web
/// - `_isActionsExpanded` per pannello azioni riga
///
/// Motivazione performance:
/// - hover/espansione non passano da provider globale;
/// - al cambio hover/expand si ricostruisce solo questa riga.
class RegistryRow extends StatefulWidget {
  const RegistryRow({
    super.key,
    required this.condomino,
    required this.isSelected,
    required this.onRowTap,
    required this.onViewDetail,
    required this.onEdit,
  });

  final Condomino condomino;
  final bool isSelected;
  final VoidCallback onRowTap;
  final VoidCallback onViewDetail;
  final VoidCallback onEdit;

  @override
  State<RegistryRow> createState() => _RegistryRowState();
}

class _RegistryRowState extends State<RegistryRow> {
  bool _isHovered = false;
  bool _isActionsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 900;
    Color rowColor = Colors.white;
    if (widget.isSelected) {
      rowColor = const Color(0xFFDCECF3);
    } else if (_isHovered) {
      rowColor = const Color(0xFFF1F5F9);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
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
                        child: isCompact
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.condomino.nominativo,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text('Unita: ${widget.condomino.unita}'),
                                  Text(
                                    'Millesimi: ${widget.condomino.millesimi.toStringAsFixed(2)}',
                                  ),
                                  Text(
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
                                ],
                              )
                            : Row(
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
                      onPressed: widget.onViewDetail,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Vedi dettaglio'),
                    ),
                    FilledButton.tonalIcon(
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
