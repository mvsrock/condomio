import 'package:flutter/material.dart';

import '../../domain/condomino.dart';

/// Riga tabella anagrafica allineata ai campi realmente persistiti da `core`.
class RegistryRow extends StatefulWidget {
  const RegistryRow({
    super.key,
    required this.condomino,
    required this.isSelected,
    required this.canEdit,
    required this.onRowTap,
    required this.onViewDetail,
    required this.onEdit,
  });

  final Condomino condomino;
  final bool isSelected;
  final bool canEdit;
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text('Unita: ${widget.condomino.unita}'),
                                  Text('Email: ${widget.condomino.email}'),
                                  const SizedBox(height: 8),
                                  _RegistryRowChips(
                                    condomino: widget.condomino,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.condomino.nominativo,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        _RegistryRowChips(
                                          condomino: widget.condomino,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(widget.condomino.unita),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(widget.condomino.email),
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
                    if (widget.canEdit)
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

class _RegistryRowChips extends StatelessWidget {
  const _RegistryRowChips({required this.condomino});

  final Condomino condomino;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _RegistryRowChip(
          label: condomino.hasStableProfile
              ? 'Profilo condiviso'
              : 'Solo esercizio',
          color: condomino.hasStableProfile
              ? const Color(0xFFE0F2FE)
              : const Color(0xFFFFF7ED),
          foreground: condomino.hasStableProfile
              ? const Color(0xFF075985)
              : const Color(0xFF9A3412),
        ),
        _RegistryRowChip(
          label: condomino.hasAppAccess
              ? 'Accesso app attivo'
              : 'Accesso app off',
          color: condomino.hasAppAccess
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFF1F5F9),
          foreground: condomino.hasAppAccess
              ? const Color(0xFF166534)
              : const Color(0xFF475569),
        ),
      ],
    );
  }
}

class _RegistryRowChip extends StatelessWidget {
  const _RegistryRowChip({
    required this.label,
    required this.color,
    required this.foreground,
  });

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
