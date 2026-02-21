import 'package:flutter/material.dart';

/// Barra filtri/ricerca della tabella anagrafica.
///
/// Mantiene solo lo stato tecnico del campo testo (controller/cursore),
/// mentre il valore funzionale resta nel provider della pagina.
class RegistryFiltersBar extends StatefulWidget {
  const RegistryFiltersBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.residentFilter,
    required this.onSetResidentFilter,
    required this.onClearSearch,
  });

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final bool? residentFilter;
  final ValueChanged<bool?> onSetResidentFilter;
  final VoidCallback onClearSearch;

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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
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
        ),
        ChoiceChip(
          label: const Text('Tutti'),
          selected: widget.residentFilter == null,
          onSelected: (_) => widget.onSetResidentFilter(null),
        ),
        ChoiceChip(
          label: const Text('Solo residenti'),
          selected: widget.residentFilter == true,
          onSelected: (_) => widget.onSetResidentFilter(true),
        ),
        ChoiceChip(
          label: const Text('Solo non residenti'),
          selected: widget.residentFilter == false,
          onSelected: (_) => widget.onSetResidentFilter(false),
        ),
      ],
    );
  }
}
