import 'package:flutter/material.dart';

/// Barra filtri/ricerca della tabella anagrafica.
///
/// Mantiene solo lo stato tecnico del campo testo (controller/cursore),
/// mentre il valore funzionale resta nel provider della pagina.
class RegistryFiltersBar extends StatefulWidget {
  const RegistryFiltersBar({
    super.key,
    required this.searchQuery,
    required this.showCeased,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onShowCeasedChanged,
  });

  final String searchQuery;
  final bool showCeased;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<bool> onShowCeasedChanged;

  @override
  State<RegistryFiltersBar> createState() => _RegistryFiltersBarState();
}

class _RegistryFiltersBarState extends State<RegistryFiltersBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant RegistryFiltersBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sincronizza il testo solo quando il valore esterno cambia davvero
    // (es. clear da pulsante o reset provider).
    if (widget.searchQuery != _controller.text) {
      _controller.text = widget.searchQuery;
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
    if (_controller.text == widget.searchQuery) return;
    widget.onSearchChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final fieldWidth = availableWidth.clamp(180.0, 320.0).toDouble();
        final compact = availableWidth < 460;

        final searchField = SizedBox(
          width: fieldWidth,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Cerca (nome, unita, email, telefono)',
              suffixIcon: widget.searchQuery.isEmpty
                  ? const Icon(Icons.search)
                  : IconButton(
                      onPressed: widget.onClearSearch,
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        );

        final ceasedChip = FilterChip(
          label: const Text('Mostra cessati'),
          selected: widget.showCeased,
          onSelected: widget.onShowCeasedChanged,
        );

        if (compact) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [searchField, const SizedBox(width: 10), ceasedChip],
            ),
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [searchField, ceasedChip],
        );
      },
    );
  }
}
