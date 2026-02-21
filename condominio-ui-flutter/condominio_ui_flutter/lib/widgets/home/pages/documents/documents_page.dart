import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../models/documents/condomino_document_model.dart';
import '../../../../../models/documents/movimento_model.dart';
import '../../../../../models/documents/tabella_model.dart';
import '../../../../../providers/documents/documents_repository_provider.dart';
import '../../../../../providers/documents/documents_ui_provider.dart';

/// Pagina documenti condominio.
///
/// Obiettivo UX:
/// - mobile: un solo asse di scroll (evita conflitti gesture e aree bloccate)
/// - desktop: pannelli affiancati per consultazione rapida
class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataset = ref.watch(documentsRepositoryProvider);
    final selectedCondominio = ref.watch(selectedCondominioProvider);
    final condomini = ref.watch(condominiBySelectedCondominioProvider);
    final tabelle = ref.watch(tabelleBySelectedCondominioProvider);
    final movimenti = ref.watch(movimentiBySelectedCondominioProvider);
    final selectedCondomino = ref.watch(selectedCondominoDocumentProvider);
    final ui = ref.read(documentsUiProvider.notifier);
    final search = ref.watch(
      documentsUiProvider.select((s) => s.searchMovimenti),
    );
    final isWide = MediaQuery.of(context).size.width >= 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documenti Condominio',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dataset.condomini.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final c = dataset.condomini[index];
              final selected = selectedCondominio?.id == c.id;
              return ChoiceChip(
                label: Text('${c.label} (${c.anno})'),
                selected: selected,
                onSelected: (_) => ui.selectCondominio(c.id),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (selectedCondominio != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(
                icon: Icons.account_balance_wallet_outlined,
                label:
                    'Residuo condominio: ${selectedCondominio.residuo.toStringAsFixed(2)}',
              ),
              _StatChip(
                icon: Icons.people_outline,
                label: 'Condomini: ${condomini.length}',
              ),
              _StatChip(
                icon: Icons.table_chart_outlined,
                label: 'Tabelle: ${tabelle.length}',
              ),
              _StatChip(
                icon: Icons.receipt_long_outlined,
                label: 'Movimenti: ${movimenti.length}',
              ),
            ],
          ),
        const SizedBox(height: 12),
        Expanded(
          child: isWide
              ? _desktopLayout(
                  condomini: condomini,
                  selectedCondomino: selectedCondomino,
                  movimenti: movimenti,
                  tabelle: tabelle,
                  search: search,
                  onSearchChanged: ui.setSearchMovimenti,
                  onSelectCondomino: ui.selectCondomino,
                )
              : _mobileLayout(
                  context: context,
                  condomini: condomini,
                  selectedCondomino: selectedCondomino,
                  movimenti: movimenti,
                  tabelle: tabelle,
                  search: search,
                  onSearchChanged: ui.setSearchMovimenti,
                  onSelectCondomino: ui.selectCondomino,
                ),
        ),
      ],
    );
  }

  Widget _desktopLayout({
    required List<CondominoDocumentModel> condomini,
    required CondominoDocumentModel? selectedCondomino,
    required List<MovimentoModel> movimenti,
    required List<TabellaModel> tabelle,
    required String search,
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<String?> onSelectCondomino,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _conodominiPanel(
            condomini: condomini,
            selectedCondominoId: selectedCondomino?.id,
            onSelect: onSelectCondomino,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: _movimentiPanel(
            movimenti: movimenti,
            search: search,
            onSearchChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: _detailPanel(
            selectedCondomino: selectedCondomino,
            tabelle: tabelle,
          ),
        ),
      ],
    );
  }

  Widget _mobileLayout({
    required BuildContext context,
    required List<CondominoDocumentModel> condomini,
    required CondominoDocumentModel? selectedCondomino,
    required List<MovimentoModel> movimenti,
    required List<TabellaModel> tabelle,
    required String search,
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<String?> onSelectCondomino,
  }) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD9E2EC)),
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              labelColor: const Color(0xFF102A43),
              unselectedLabelColor: const Color(0xFF627D98),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Condomini'),
                Tab(text: 'Movimenti'),
                Tab(text: 'Tabelle'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (selectedCondomino != null)
            Card(
              child: ListTile(
                dense: true,
                title: Text(
                  selectedCondomino.nominativo,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Residuo ${selectedCondomino.residuo.toStringAsFixed(2)}',
                ),
                trailing: TextButton(
                  onPressed: () {
                    _openCondominoDetailBottomSheet(
                      context: context,
                      condomino: selectedCondomino,
                      tabelle: tabelle,
                    );
                  },
                  child: const Text('Dettaglio'),
                ),
              ),
            ),
          if (selectedCondomino != null) const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: condomini.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = condomini[index];
                      return _MobileCondominoTile(
                        selected: selectedCondomino?.id == item.id,
                        title: item.nominativo,
                        subtitle: 'Scala ${item.scala} - Int ${item.interno}',
                        residuo: item.residuo,
                        onTap: () => onSelectCondomino(item.id),
                      );
                    },
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        child: _MovimentiSearchField(
                          value: search,
                          onChanged: onSearchChanged,
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: movimenti.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final m = movimenti[index];
                            return _MobileMovimentoTile(
                              title: m.descrizione,
                              subtitle: 'Codice ${m.codiceSpesa}',
                              importo: m.importo,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: tabelle.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = tabelle[index];
                      return _MobileTabellaTile(
                        codice: t.codice,
                        descrizione: t.descrizione,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCondominoDetailBottomSheet({
    required BuildContext context,
    required CondominoDocumentModel condomino,
    required List<TabellaModel> tabelle,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  condomino.nominativo,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(condomino.email),
                const SizedBox(height: 4),
                Text('Telefono: ${condomino.cellulare}'),
                const SizedBox(height: 4),
                Text('Residuo: ${condomino.residuo.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                const Text(
                  'Tabelle condominio',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...tabelle.map(
                  (t) => ListTile(
                    dense: true,
                    title: Text(t.codice),
                    subtitle: Text(t.descrizione),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _conodominiPanel({
    required List<CondominoDocumentModel> condomini,
    required String? selectedCondominoId,
    required ValueChanged<String?> onSelect,
    bool shrinkListForParentScroll = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Condomini',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (shrinkListForParentScroll)
              ListView.separated(
                itemCount: condomini.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = condomini[index];
                  return ListTile(
                    dense: true,
                    selected: selectedCondominoId == item.id,
                    title: Text(item.nominativo),
                    subtitle: Text('Scala ${item.scala} - Int ${item.interno}'),
                    trailing: Text(item.residuo.toStringAsFixed(2)),
                    onTap: () => onSelect(item.id),
                  );
                },
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: condomini.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = condomini[index];
                    return ListTile(
                      dense: true,
                      selected: selectedCondominoId == item.id,
                      title: Text(item.nominativo),
                      subtitle: Text('Scala ${item.scala} - Int ${item.interno}'),
                      trailing: Text(item.residuo.toStringAsFixed(2)),
                      onTap: () => onSelect(item.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _movimentiPanel({
    required List<MovimentoModel> movimenti,
    required String search,
    required ValueChanged<String> onSearchChanged,
    bool shrinkListForParentScroll = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Movimenti',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _MovimentiSearchField(
              value: search,
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 10),
            if (shrinkListForParentScroll)
              ListView.separated(
                itemCount: movimenti.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final m = movimenti[index];
                  return ListTile(
                    dense: true,
                    title: Text(m.descrizione),
                    subtitle: Text('Codice ${m.codiceSpesa}'),
                    trailing: Text(m.importo.toStringAsFixed(2)),
                  );
                },
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: movimenti.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final m = movimenti[index];
                    return ListTile(
                      dense: true,
                      title: Text(m.descrizione),
                      subtitle: Text('Codice ${m.codiceSpesa}'),
                      trailing: Text(m.importo.toStringAsFixed(2)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailPanel({
    required CondominoDocumentModel? selectedCondomino,
    required List<TabellaModel> tabelle,
    bool shrinkListsForParentScroll = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dettaglio + Tabelle',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (selectedCondomino == null)
              const Text('Seleziona un condomino')
            else ...[
              Text(
                selectedCondomino.nominativo,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(selectedCondomino.email),
              const SizedBox(height: 4),
              Text('Telefono: ${selectedCondomino.cellulare}'),
              const SizedBox(height: 4),
              Text('Residuo: ${selectedCondomino.residuo.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
            ],
            const Text('Tabelle condominio'),
            const SizedBox(height: 6),
            if (shrinkListsForParentScroll)
              ListView.separated(
                itemCount: tabelle.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final t = tabelle[index];
                  return ListTile(
                    dense: true,
                    title: Text(t.codice),
                    subtitle: Text(t.descrizione),
                  );
                },
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: tabelle.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final t = tabelle[index];
                    return ListTile(
                      dense: true,
                      title: Text(t.codice),
                      subtitle: Text(t.descrizione),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MovimentiSearchField extends StatefulWidget {
  const _MovimentiSearchField({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_MovimentiSearchField> createState() => _MovimentiSearchFieldState();
}

class _MovimentiSearchFieldState extends State<_MovimentiSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _MovimentiSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

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

class _MobileCondominoTile extends StatelessWidget {
  const _MobileCondominoTile({
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

class _MobileMovimentoTile extends StatelessWidget {
  const _MobileMovimentoTile({
    required this.title,
    required this.subtitle,
    required this.importo,
  });

  final String title;
  final String subtitle;
  final double importo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Text(
        importo.toStringAsFixed(2),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MobileTabellaTile extends StatelessWidget {
  const _MobileTabellaTile({
    required this.codice,
    required this.descrizione,
  });

  final String codice;
  final String descrizione;

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
    );
  }
}
