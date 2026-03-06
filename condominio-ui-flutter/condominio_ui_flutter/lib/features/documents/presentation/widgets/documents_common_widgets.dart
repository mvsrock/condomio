import 'package:flutter/material.dart';

/// Enum condiviso per menu riga edit/delete.
enum DocumentsRowAction { edit, delete }

/// Campo ricerca movimenti con controller interno sincronizzato al valore esterno.
class DocumentsMovimentiSearchField extends StatefulWidget {
  const DocumentsMovimentiSearchField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<DocumentsMovimentiSearchField> createState() =>
      _DocumentsMovimentiSearchFieldState();
}

class _DocumentsMovimentiSearchFieldState
    extends State<DocumentsMovimentiSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant DocumentsMovimentiSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_controller.text == widget.value) return;
    widget.onChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        isDense: true,
        labelText: 'Filtra per codice/descrizione',
        suffixIcon: Icon(Icons.search),
      ),
    );
  }
}

/// Chip informativo usato nell'header documenti.
class DocumentsStatChip extends StatelessWidget {
  const DocumentsStatChip({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

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

class DocumentsMobileCondominoTile extends StatelessWidget {
  const DocumentsMobileCondominoTile({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.residuo,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final double residuo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      selected: selected,
      selectedTileColor: const Color(0xFFE6F0F4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(residuo.toStringAsFixed(2)),
      ),
      onTap: onTap,
    );
  }
}

class DocumentsMobileMovimentoTile extends StatelessWidget {
  const DocumentsMobileMovimentoTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.importo,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final double importo;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: DocumentsListTileActionsMenu(
        amountText: importo.toStringAsFixed(2),
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

class DocumentsMobileTabellaTile extends StatelessWidget {
  const DocumentsMobileTabellaTile({
    super.key,
    required this.codice,
    required this.descrizione,
    required this.onEdit,
    required this.onDelete,
  });

  final String codice;
  final String descrizione;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F0F4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          codice,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
      title: Text(descrizione),
      trailing: DocumentsListTileActionsMenu(
        amountText: '',
        showAmount: false,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

/// Menu azioni riga riusabile con importo opzionale.
class DocumentsListTileActionsMenu extends StatelessWidget {
  const DocumentsListTileActionsMenu({
    super.key,
    required this.amountText,
    required this.onEdit,
    required this.onDelete,
    this.showAmount = true,
  });

  final String amountText;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showAmount;

  @override
  Widget build(BuildContext context) {
    final hasActions = onEdit != null || onDelete != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAmount)
          Text(
            amountText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        if (hasActions)
          PopupMenuButton<DocumentsRowAction>(
            onSelected: (value) {
              if (value == DocumentsRowAction.edit) {
                onEdit?.call();
              } else {
                onDelete?.call();
              }
            },
            itemBuilder: (context) => [
              if (onEdit != null)
                const PopupMenuItem(
                  value: DocumentsRowAction.edit,
                  child: Text('Modifica'),
                ),
              if (onDelete != null)
                const PopupMenuItem(
                  value: DocumentsRowAction.delete,
                  child: Text('Elimina'),
                ),
            ],
          ),
      ],
    );
  }
}
