import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_breakpoints.dart';
import '../../application/documents_ui_notifier.dart';
import '../../data/documents_repository_provider.dart';
import '../../domain/condominio_document_model.dart';
import '../../domain/condomino_document_model.dart';
import '../../domain/movimento_model.dart';
import '../../domain/tabella_model.dart';

/// Pagina documenti condominio.
///
/// Obiettivo UX:
/// - mobile: un solo asse di scroll (evita conflitti gesture e aree bloccate)
/// - desktop: pannelli affiancati per consultazione rapida
class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataState = ref.watch(documentsDataProvider);
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
    final dataNotifier = ref.read(documentsDataProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = AppBreakpoints.isDocumentsWide(constraints.maxWidth);

        if (dataState.isLoading && dataset.condomini.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dataState.errorMessage != null) ...[
              Material(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade900),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dataState.errorMessage!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Chiudi errore',
                        onPressed: () => ref
                            .read(documentsDataProvider.notifier)
                            .clearError(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: (dataState.isSaving || selectedCondominio == null)
                      ? null
                      : () => _openConfigurazioniSpesaDialog(
                            context: context,
                            ref: ref,
                            selectedCondominio: selectedCondominio,
                            tabelle: tabelle,
                          ),
                  icon: const Icon(Icons.settings_suggest_outlined),
                  label: const Text('Configura riparto'),
                ),
                FilledButton.icon(
                  onPressed: dataState.isSaving
                      ? null
                      : () => _openCreateTabellaDialog(
                            context: context,
                            ref: ref,
                          ),
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('Nuova tabella'),
                ),
                FilledButton.icon(
                  onPressed: dataState.isSaving
                      ? null
                      : () => _openCreateMovimentoDialog(
                            context: context,
                            ref: ref,
                            selectedCondominio: selectedCondominio,
                          ),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Nuova spesa'),
                ),
                OutlinedButton.icon(
                  onPressed: dataState.isLoading
                      ? null
                      : dataNotifier.loadForSelectedCondominio,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Aggiorna'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isWide
                  ? _desktopLayout(
                      context: context,
                      ref: ref,
                      selectedCondominio: selectedCondominio,
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
                      ref: ref,
                      selectedCondominio: selectedCondominio,
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
      },
    );
  }

  Future<void> _openCreateTabellaDialog({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final formKey = GlobalKey<FormState>();
    final codiceCtrl = TextEditingController();
    final descrizioneCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova tabella'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codiceCtrl,
                decoration: const InputDecoration(labelText: 'Codice'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Obbligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descrizioneCtrl,
                decoration: const InputDecoration(labelText: 'Descrizione'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Obbligatorio'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(context).pop(true);
            },
            child: const Text('Crea'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(documentsDataProvider.notifier).createTabella(
            codice: codiceCtrl.text,
            descrizione: descrizioneCtrl.text,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tabella creata')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  Future<void> _openConfigurazioniSpesaDialog({
    required BuildContext context,
    required WidgetRef ref,
    required CondominioDocumentModel selectedCondominio,
    required List<TabellaModel> tabelle,
  }) async {
    final result = await showDialog<_ConfigurazioniSaveResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ConfigurazioniSpesaDialog(
        initial: selectedCondominio.configurazioniSpesa
            .map(_ConfigurazioneSpesaDraft.fromModel)
            .toList(growable: false),
        tabelle: tabelle,
      ),
    );
    if (result == null) return;
    if (!context.mounted) return;

    try {
      await ref.read(documentsDataProvider.notifier).updateConfigurazioniSpesa(
            configurazioni: result.items
                .map(
                  (c) => CondominioConfigurazioneDraft(
                    codice: c.codice.trim(),
                    tabelle: c.splits
                        .map(
                          (s) => CondominioTabellaPercentualeDraft(
                            codice: s.codiceTabella.trim(),
                            descrizione: s.descrizioneTabella.trim(),
                            percentuale: s.percentuale,
                          ),
                        )
                        .toList(growable: false),
                  ),
                )
                .toList(growable: false),
          );
      if (result.rebuildStorico) {
        await ref.read(documentsDataProvider.notifier).rebuildStoricoCondominio();
      }
      if (context.mounted) {
        final message = result.rebuildStorico
            ? 'Configurazioni aggiornate e storico ricalcolato'
            : 'Configurazioni aggiornate (valide per nuove spese)';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  Future<void> _openCreateMovimentoDialog({
    required BuildContext context,
    required WidgetRef ref,
    required CondominioDocumentModel? selectedCondominio,
  }) async {
    final formKey = GlobalKey<FormState>();
    final codiceCtrl = TextEditingController();
    final descrizioneCtrl = TextEditingController();
    final importoCtrl = TextEditingController();

    final spesaCodes = (selectedCondominio?.configurazioniSpesa ?? const [])
        .map<String>((c) => c.codice)
        .where((c) => c.trim().isNotEmpty)
        .toList(growable: false);
    if (spesaCodes.isNotEmpty) {
      codiceCtrl.text = spesaCodes.first;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova spesa'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: codiceCtrl.text.isEmpty ? null : codiceCtrl.text,
                decoration: const InputDecoration(labelText: 'Codice spesa'),
                items: spesaCodes
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (value) => codiceCtrl.text = value ?? '',
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Seleziona codice spesa'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descrizioneCtrl,
                decoration: const InputDecoration(labelText: 'Descrizione'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Obbligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: importoCtrl,
                decoration: const InputDecoration(labelText: 'Importo'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  if (parsed == null || parsed <= 0) {
                    return 'Importo non valido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(context).pop(true);
            },
            child: const Text('Registra'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final importo = double.parse(importoCtrl.text.replaceAll(',', '.'));
      await ref.read(documentsDataProvider.notifier).createMovimento(
            codiceSpesa: codiceCtrl.text,
            descrizione: descrizioneCtrl.text,
            importo: importo,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Spesa registrata e riparto aggiornato'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  Future<void> _openEditMovimentoDialog({
    required BuildContext context,
    required WidgetRef ref,
    required MovimentoModel movimento,
  }) async {
    final formKey = GlobalKey<FormState>();
    final codiceCtrl = TextEditingController(text: movimento.codiceSpesa);
    final descrizioneCtrl = TextEditingController(text: movimento.descrizione);
    final importoCtrl = TextEditingController(
      text: movimento.importo.toStringAsFixed(2),
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica spesa'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codiceCtrl,
                decoration: const InputDecoration(labelText: 'Codice spesa'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Obbligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descrizioneCtrl,
                decoration: const InputDecoration(labelText: 'Descrizione'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Obbligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: importoCtrl,
                decoration: const InputDecoration(labelText: 'Importo'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  if (parsed == null || parsed <= 0) {
                    return 'Importo non valido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(context).pop(true);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(documentsDataProvider.notifier).updateMovimento(
            movimentoId: movimento.id,
            codiceSpesa: codiceCtrl.text,
            descrizione: descrizioneCtrl.text,
            importo: double.parse(importoCtrl.text.replaceAll(',', '.')),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spesa aggiornata')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  Future<void> _confirmDeleteMovimento({
    required BuildContext context,
    required WidgetRef ref,
    required MovimentoModel movimento,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina spesa'),
        content: Text('Confermi eliminazione "${movimento.descrizione}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(documentsDataProvider.notifier).deleteMovimento(
            movimentoId: movimento.id,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spesa eliminata')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  Future<void> _openEditTabellaDialog({
    required BuildContext context,
    required WidgetRef ref,
    required CondominioDocumentModel? selectedCondominio,
    required List<TabellaModel> tabelle,
    required TabellaModel tabella,
  }) async {
    final formKey = GlobalKey<FormState>();
    final codiceCtrl = TextEditingController(text: tabella.codice);
    final descrizioneCtrl = TextEditingController(text: tabella.descrizione);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica tabella'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codiceCtrl,
                decoration: const InputDecoration(labelText: 'Codice'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Obbligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descrizioneCtrl,
                decoration: const InputDecoration(labelText: 'Descrizione'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Obbligatorio'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(context).pop(true);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;
    final newCode = codiceCtrl.text.trim();
    if (newCode.toLowerCase() != tabella.codice.trim().toLowerCase()) {
      final linkedCodes = _linkedSpesaCodesForTabella(selectedCondominio, tabella);
      if (linkedCodes.isNotEmpty) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Rinomina tabella in uso'),
            content: Text(
              'La tabella "${tabella.codice}" e\' referenziata in:\n'
              '${linkedCodes.join(', ')}\n\n'
              'Conferma: il backend aggiornera\' automaticamente i riferimenti '
              'in un\'unica operazione.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Conferma'),
              ),
            ],
          ),
        );
        if (proceed != true) {
          return;
        }
      }
    }
    try {
      await ref.read(documentsDataProvider.notifier).updateTabella(
            tabellaId: tabella.id,
            codice: codiceCtrl.text,
            descrizione: descrizioneCtrl.text,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tabella aggiornata')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  Future<void> _confirmDeleteTabella({
    required BuildContext context,
    required WidgetRef ref,
    required CondominioDocumentModel? selectedCondominio,
    required List<TabellaModel> tabelle,
    required TabellaModel tabella,
  }) async {
    final linkedCodes = _linkedSpesaCodesForTabella(selectedCondominio, tabella);
    if (linkedCodes.isNotEmpty) {
      final action = await showDialog<_LinkedTabellaAction>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tabella in uso'),
          content: Text(
            'La tabella "${tabella.codice}" e\' usata nelle configurazioni spesa:\n'
            '${linkedCodes.join(', ')}\n\n'
            'Rimuovila prima da "Configura riparto".',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(_LinkedTabellaAction.cancel),
              child: const Text('Chiudi'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(_LinkedTabellaAction.autoCleanup),
              child: const Text('Rimuovi automaticamente'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_LinkedTabellaAction.openConfig),
              child: const Text('Apri Configura riparto'),
            ),
          ],
        ),
      );
      if (action == _LinkedTabellaAction.openConfig &&
          context.mounted &&
          selectedCondominio != null) {
        await _openConfigurazioniSpesaDialog(
          context: context,
          ref: ref,
          selectedCondominio: selectedCondominio,
          tabelle: tabelle,
        );
        return;
      }
      if (action == _LinkedTabellaAction.autoCleanup &&
          context.mounted &&
          selectedCondominio != null) {
        try {
          await ref.read(documentsDataProvider.notifier).cleanupDeleteTabella(
                tabellaId: tabella.id,
              );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Tabella rimossa con cleanup automatico dei riferimenti',
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Errore: $e')));
          }
        }
        return;
      }
      if (action != _LinkedTabellaAction.openConfig) {
        return;
      }
    }
    if (!context.mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina tabella'),
        content: Text(
          'Confermi eliminazione tabella "${tabella.codice}"?\n'
          'Attenzione: le configurazioni spesa che la usano andranno aggiornate.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(documentsDataProvider.notifier).deleteTabella(
            tabellaId: tabella.id,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tabella eliminata')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  List<String> _linkedSpesaCodesForTabella(
    CondominioDocumentModel? selectedCondominio,
    TabellaModel tabella,
  ) {
    if (selectedCondominio == null) return const [];
    final linked = <String>[];
    for (final config in selectedCondominio.configurazioniSpesa) {
      final hasLink = config.tabelle.any(
        (t) => t.codice.trim().toLowerCase() == tabella.codice.trim().toLowerCase(),
      );
      if (hasLink) {
        linked.add(config.codice);
      }
    }
    return linked;
  }

  Widget _desktopLayout({
    required BuildContext context,
    required WidgetRef ref,
    required CondominioDocumentModel? selectedCondominio,
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
            context: context,
            ref: ref,
            movimenti: movimenti,
            search: search,
            onSearchChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: _detailPanel(
            context: context,
            ref: ref,
            selectedCondominio: selectedCondominio,
            selectedCondomino: selectedCondomino,
            condomini: condomini,
            tabelle: tabelle,
          ),
        ),
      ],
    );
  }

  Widget _mobileLayout({
    required BuildContext context,
    required WidgetRef ref,
    required CondominioDocumentModel? selectedCondominio,
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
                              onTap: () => _openMovimentoDetailDialog(
                                context: context,
                                movimento: m,
                              ),
                              onEdit: () => _openEditMovimentoDialog(
                                context: context,
                                ref: ref,
                                movimento: m,
                              ),
                              onDelete: () => _confirmDeleteMovimento(
                                context: context,
                                ref: ref,
                                movimento: m,
                              ),
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
                      onEdit: () => _openEditTabellaDialog(
                        context: context,
                        ref: ref,
                        selectedCondominio: selectedCondominio,
                        tabelle: tabelle,
                        tabella: t,
                      ),
                      onDelete: () => _confirmDeleteTabella(
                        context: context,
                        ref: ref,
                        selectedCondominio: selectedCondominio,
                        tabelle: tabelle,
                        tabella: t,
                      ),
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

  Future<void> _openCondominoQuoteDialog({
    required BuildContext context,
    required WidgetRef ref,
    required CondominoDocumentModel selectedCondomino,
    required List<CondominoDocumentModel> allCondomini,
    required List<TabellaModel> tabelle,
  }) async {
    final result = await showDialog<_QuoteSaveResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CondominoQuoteDialog(
        condomino: selectedCondomino,
        allCondomini: allCondomini,
        tabelle: tabelle,
      ),
    );
    if (result == null) return;
    if (!context.mounted) return;

    try {
      await ref.read(documentsDataProvider.notifier).updateCondominoQuoteTabelle(
            condominoId: selectedCondomino.id,
            quote: result.rows
                .map(
                  (q) => CondominoTabellaQuotaDraft(
                    codice: q.codiceTabella,
                    descrizione: q.descrizioneTabella,
                    numeratore: q.numeratore,
                    denominatore: q.denominatore,
                  ),
                )
                .toList(growable: false),
          );
      if (result.rebuildStorico) {
        await ref.read(documentsDataProvider.notifier).rebuildStoricoCondominio();
      }
      if (context.mounted) {
        final message = result.rebuildStorico
            ? 'Quote aggiornate e storico ricalcolato'
            : 'Quote aggiornate (valide per nuove spese)';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore aggiornamento quote: $e')),
        );
      }
    }
  }

  Future<void> _openMovimentoDetailDialog({
    required BuildContext context,
    required MovimentoModel movimento,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dettaglio riparto - ${movimento.codiceSpesa}'),
        content: SizedBox(
          width: 760,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimento.descrizione,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text('Importo: ${movimento.importo.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                const Text(
                  'Ripartizione per tabella',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                if (movimento.ripartizioneTabelle.isEmpty)
                  const Text('Nessuna ripartizione tabella disponibile')
                else
                  ...movimento.ripartizioneTabelle.map(
                    (r) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('${r.codice} - ${r.descrizione}'),
                      trailing: Text(r.importo.toStringAsFixed(2)),
                    ),
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Ripartizione per condomino',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                if (movimento.ripartizioneCondomini.isEmpty)
                  const Text('Nessuna ripartizione condomino disponibile')
                else
                  ...movimento.ripartizioneCondomini.map(
                    (r) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(r.nominativo),
                      subtitle: Text(r.idCondomino),
                      trailing: Text(r.importo.toStringAsFixed(2)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
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
    required BuildContext context,
    required WidgetRef ref,
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
                    onTap: () => _openMovimentoDetailDialog(
                      context: context,
                      movimento: m,
                    ),
                    trailing: _ListTileActionsMenu(
                      amountText: m.importo.toStringAsFixed(2),
                      onEdit: () => _openEditMovimentoDialog(
                        context: context,
                        ref: ref,
                        movimento: m,
                      ),
                      onDelete: () => _confirmDeleteMovimento(
                        context: context,
                        ref: ref,
                        movimento: m,
                      ),
                    ),
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
                      onTap: () => _openMovimentoDetailDialog(
                        context: context,
                        movimento: m,
                      ),
                      trailing: _ListTileActionsMenu(
                        amountText: m.importo.toStringAsFixed(2),
                        onEdit: () => _openEditMovimentoDialog(
                          context: context,
                          ref: ref,
                          movimento: m,
                        ),
                        onDelete: () => _confirmDeleteMovimento(
                          context: context,
                          ref: ref,
                          movimento: m,
                        ),
                      ),
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
    required BuildContext context,
    required WidgetRef ref,
    required CondominioDocumentModel? selectedCondominio,
    required CondominoDocumentModel? selectedCondomino,
    required List<CondominoDocumentModel> condomini,
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
                OutlinedButton.icon(
                  onPressed: () => _openCondominoQuoteDialog(
                    context: context,
                    ref: ref,
                    selectedCondomino: selectedCondomino,
                    allCondomini: condomini,
                    tabelle: tabelle,
                  ),
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Modifica quote'),
                ),
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
                    trailing: _ListTileActionsMenu(
                      amountText: '',
                      showAmount: false,
                      onEdit: () => _openEditTabellaDialog(
                        context: context,
                        ref: ref,
                        selectedCondominio: selectedCondominio,
                        tabelle: tabelle,
                        tabella: t,
                      ),
                      onDelete: () => _confirmDeleteTabella(
                        context: context,
                        ref: ref,
                        selectedCondominio: selectedCondominio,
                        tabelle: tabelle,
                        tabella: t,
                      ),
                    ),
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
                      trailing: _ListTileActionsMenu(
                        amountText: '',
                        showAmount: false,
                        onEdit: () => _openEditTabellaDialog(
                          context: context,
                          ref: ref,
                          selectedCondominio: selectedCondominio,
                          tabelle: tabelle,
                          tabella: t,
                        ),
                        onDelete: () => _confirmDeleteTabella(
                          context: context,
                          ref: ref,
                          selectedCondominio: selectedCondominio,
                          tabelle: tabelle,
                          tabella: t,
                        ),
                      ),
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
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final double importo;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: _ListTileActionsMenu(
        amountText: importo.toStringAsFixed(2),
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

class _MobileTabellaTile extends StatelessWidget {
  const _MobileTabellaTile({
    required this.codice,
    required this.descrizione,
    required this.onEdit,
    required this.onDelete,
  });

  final String codice;
  final String descrizione;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
      trailing: _ListTileActionsMenu(
        amountText: '',
        showAmount: false,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

class _ListTileActionsMenu extends StatelessWidget {
  const _ListTileActionsMenu({
    required this.amountText,
    required this.onEdit,
    required this.onDelete,
    this.showAmount = true,
  });

  final String amountText;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showAmount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAmount)
          Text(
            amountText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        PopupMenuButton<_RowAction>(
          onSelected: (value) {
            if (value == _RowAction.edit) {
              onEdit();
            } else {
              onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _RowAction.edit,
              child: Text('Modifica'),
            ),
            PopupMenuItem(
              value: _RowAction.delete,
              child: Text('Elimina'),
            ),
          ],
        ),
      ],
    );
  }
}

enum _RowAction { edit, delete }

class _ConfigurazioniSpesaDialog extends StatefulWidget {
  const _ConfigurazioniSpesaDialog({
    required this.initial,
    required this.tabelle,
  });

  final List<_ConfigurazioneSpesaDraft> initial;
  final List<TabellaModel> tabelle;

  @override
  State<_ConfigurazioniSpesaDialog> createState() =>
      _ConfigurazioniSpesaDialogState();
}

class _ConfigurazioniSpesaDialogState extends State<_ConfigurazioniSpesaDialog> {
  late List<_ConfigurazioneSpesaDraft> _items;
  bool _rebuildStorico = false;

  @override
  void initState() {
    super.initState();
    _items = widget.initial
        .map((e) => e.copy())
        .toList(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configura riparto spese'),
      content: SizedBox(
        width: 760,
        height: 520,
        child: ListView(
          children: [
            const Text(
              'Le modifiche vengono applicate quando premi "Salva".',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nessuna configurazione presente.'),
              ),
            for (var i = 0; i < _items.length; i++)
              _buildConfigurazioneCard(i),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addConfigurazione,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi codice spesa'),
            ),
            const SizedBox(height: 6),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _rebuildStorico,
              onChanged: (value) => setState(() => _rebuildStorico = value ?? false),
              title: const Text('Ricostruisci storico'),
              subtitle: const Text(
                'Applica le modifiche a tutte le spese gia registrate '
                'dell\'anno corrente.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: const Text('Salva'),
        ),
      ],
    );
  }

  Widget _buildConfigurazioneCard(int index) {
    final item = _items[index];
    return Card(
      key: ValueKey('cfg-${item.uid}'),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('cfg-code-${item.uid}'),
                    initialValue: item.codice,
                    decoration: const InputDecoration(
                      labelText: 'Codice spesa',
                    ),
                    onChanged: (value) => item.codice = value,
                  ),
                ),
                IconButton(
                  tooltip: 'Duplica configurazione',
                  onPressed: () => setState(() {
                    final duplicate = item.copy();
                    duplicate.codice = '${item.codice}_copy';
                    _items.insert(index + 1, duplicate);
                  }),
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  tooltip: 'Sposta su',
                  onPressed: index == 0
                      ? null
                      : () => setState(() {
                          final current = _items.removeAt(index);
                          _items.insert(index - 1, current);
                        }),
                  icon: const Icon(Icons.keyboard_arrow_up),
                ),
                IconButton(
                  tooltip: 'Sposta giu',
                  onPressed: index >= _items.length - 1
                      ? null
                      : () => setState(() {
                          final current = _items.removeAt(index);
                          _items.insert(index + 1, current);
                        }),
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
                IconButton(
                  tooltip: 'Rimuovi configurazione',
                  onPressed: () => setState(() => _items.removeAt(index)),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var s = 0; s < item.splits.length; s++)
              _buildSplitRow(item: item, splitIndex: s),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() {
                final fallback = widget.tabelle.isNotEmpty
                    ? widget.tabelle.first
                    : null;
                item.splits.add(
                  _TabellaSplitDraft(
                    uid: _DraftId.next(),
                    codiceTabella: fallback?.codice ?? '',
                    descrizioneTabella: fallback?.descrizione ?? '',
                    percentuale: 0,
                  ),
                );
              }),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi tabella'),
            ),
            const SizedBox(height: 4),
            Text(
              'Totale percentuale: ${item.totalPercent}%',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: item.totalPercent == 100 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitRow({
    required _ConfigurazioneSpesaDraft item,
    required int splitIndex,
  }) {
    final split = item.splits[splitIndex];
    return Padding(
      key: ValueKey('split-${item.uid}-${split.uid}'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: DropdownButtonFormField<String>(
              key: ValueKey('split-table-${item.uid}-${split.uid}'),
              initialValue: split.codiceTabella.isEmpty
                  ? null
                  : split.codiceTabella,
              decoration: const InputDecoration(labelText: 'Tabella'),
              items: widget.tabelle
                  .map(
                    (t) => DropdownMenuItem<String>(
                      value: t.codice,
                      child: Text('${t.codice} - ${t.descrizione}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                final selected = widget.tabelle.firstWhere(
                  (t) => t.codice == value,
                );
                setState(() {
                  split.codiceTabella = selected.codice;
                  split.descrizioneTabella = selected.descrizione;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              key: ValueKey('split-pct-${item.uid}-${split.uid}'),
              initialValue: '${split.percentuale}',
              decoration: const InputDecoration(labelText: '%'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = int.tryParse(value) ?? 0;
                setState(() => split.percentuale = parsed);
              },
            ),
          ),
          IconButton(
            tooltip: 'Rimuovi tabella',
            onPressed: () => setState(() => item.splits.removeAt(splitIndex)),
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }

  void _addConfigurazione() {
    final fallback = widget.tabelle.isNotEmpty ? widget.tabelle.first : null;
    setState(() {
      _items.add(
        _ConfigurazioneSpesaDraft(
          uid: _DraftId.next(),
          codice: '',
          splits: [
            _TabellaSplitDraft(
              uid: _DraftId.next(),
              codiceTabella: fallback?.codice ?? '',
              descrizioneTabella: fallback?.descrizione ?? '',
              percentuale: 100,
            ),
          ],
        ),
      );
    });
  }

  void _onSave() {
    final seenCodes = <String>{};
    for (final item in _items) {
      if (item.codice.trim().isEmpty) {
        _showError('Ogni configurazione deve avere un codice spesa');
        return;
      }
      final normalizedCode = item.codice.trim().toLowerCase();
      if (seenCodes.contains(normalizedCode)) {
        _showError('Codici spesa duplicati non consentiti');
        return;
      }
      seenCodes.add(normalizedCode);
      if (item.splits.isEmpty) {
        _showError('Ogni configurazione deve avere almeno una tabella');
        return;
      }
      final seenTables = <String>{};
      for (final split in item.splits) {
        final tableCode = split.codiceTabella.trim().toLowerCase();
        if (tableCode.isEmpty) {
          _showError('Seleziona la tabella per tutte le righe');
          return;
        }
        if (seenTables.contains(tableCode)) {
          _showError('Tabella duplicata nella configurazione "${item.codice}"');
          return;
        }
        seenTables.add(tableCode);
      }
      if (item.totalPercent != 100) {
        _showError(
          'Il totale percentuali per "${item.codice}" deve essere 100%',
        );
        return;
      }
    }
    Navigator.of(context).pop(
      _ConfigurazioniSaveResult(
        items: _items,
        rebuildStorico: _rebuildStorico,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ConfigurazioneSpesaDraft {
  _ConfigurazioneSpesaDraft({
    required this.uid,
    required this.codice,
    required this.splits,
  });

  final int uid;
  String codice;
  List<_TabellaSplitDraft> splits;

  int get totalPercent =>
      splits.fold<int>(0, (sum, s) => sum + s.percentuale);

  factory _ConfigurazioneSpesaDraft.fromModel(ConfigurazioneSpesaModel model) {
    return _ConfigurazioneSpesaDraft(
      uid: _DraftId.next(),
      codice: model.codice,
      splits: model.tabelle
          .map(
            (t) => _TabellaSplitDraft(
              uid: _DraftId.next(),
              codiceTabella: t.codice,
              descrizioneTabella: t.descrizione,
              percentuale: t.percentuale,
            ),
          )
          .toList(growable: true),
    );
  }

  _ConfigurazioneSpesaDraft copy() {
    return _ConfigurazioneSpesaDraft(
      uid: _DraftId.next(),
      codice: codice,
      splits: splits.map((s) => s.copy()).toList(growable: true),
    );
  }
}

class _TabellaSplitDraft {
  _TabellaSplitDraft({
    required this.uid,
    required this.codiceTabella,
    required this.descrizioneTabella,
    required this.percentuale,
  });

  final int uid;
  String codiceTabella;
  String descrizioneTabella;
  int percentuale;

  _TabellaSplitDraft copy() {
    return _TabellaSplitDraft(
      uid: _DraftId.next(),
      codiceTabella: codiceTabella,
      descrizioneTabella: descrizioneTabella,
      percentuale: percentuale,
    );
  }
}

class _DraftId {
  static int _counter = 0;
  static int next() => ++_counter;
}

enum _LinkedTabellaAction { cancel, openConfig, autoCleanup }

class _ConfigurazioniSaveResult {
  const _ConfigurazioniSaveResult({
    required this.items,
    required this.rebuildStorico,
  });

  final List<_ConfigurazioneSpesaDraft> items;
  final bool rebuildStorico;
}

class _CondominoQuoteDialog extends StatefulWidget {
  const _CondominoQuoteDialog({
    required this.condomino,
    required this.allCondomini,
    required this.tabelle,
  });

  final CondominoDocumentModel condomino;
  final List<CondominoDocumentModel> allCondomini;
  final List<TabellaModel> tabelle;

  @override
  State<_CondominoQuoteDialog> createState() => _CondominoQuoteDialogState();
}

class _CondominoQuoteDialogState extends State<_CondominoQuoteDialog> {
  late List<_CondominoQuotaDraft> _rows;
  late List<_TabellaQuoteHealth> _health;
  bool _rebuildStorico = false;

  @override
  void initState() {
    super.initState();
    _rows = _buildInitialRows();
    _health = _computeHealth();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Quote - ${widget.condomino.nominativo}'),
      content: SizedBox(
        width: 700,
        height: 500,
        child: ListView(
          children: [
            for (var i = 0; i < _rows.length; i++) _buildRow(i),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi tabella'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Verifica coerenza quote tabella',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            ..._health.map(_buildHealthRow),
            const SizedBox(height: 6),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _rebuildStorico,
              onChanged: (value) => setState(() => _rebuildStorico = value ?? false),
              title: const Text('Ricostruisci storico'),
              subtitle: const Text(
                'Applica le nuove quote anche alle spese gia registrate '
                'dell\'anno corrente.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: const Text('Salva'),
        ),
      ],
    );
  }

  List<_CondominoQuotaDraft> _buildInitialRows() {
    final byCode = <String, TabellaConfigModel>{};
    for (final t in widget.condomino.config.tabelle) {
      byCode[t.codiceTabella.trim().toLowerCase()] = t;
    }
    final rows = <_CondominoQuotaDraft>[];
    for (final tab in widget.tabelle) {
      final existing = byCode[tab.codice.trim().toLowerCase()];
      rows.add(
        _CondominoQuotaDraft(
          codiceTabella: tab.codice,
          descrizioneTabella: tab.descrizione,
          numeratore: existing?.numeratore ?? 0,
          denominatore: existing?.denominatore ?? 1000,
        ),
      );
    }
    if (rows.isEmpty) {
      rows.add(
        _CondominoQuotaDraft(
          codiceTabella: '',
          descrizioneTabella: '',
          numeratore: 0,
          denominatore: 1000,
        ),
      );
    }
    return rows;
  }

  Widget _buildRow(int index) {
    final row = _rows[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: DropdownButtonFormField<String>(
              initialValue: row.codiceTabella.isEmpty ? null : row.codiceTabella,
              decoration: const InputDecoration(labelText: 'Tabella'),
              items: widget.tabelle
                  .map(
                    (t) => DropdownMenuItem<String>(
                      value: t.codice,
                      child: Text('${t.codice} - ${t.descrizione}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                final selected = widget.tabelle.firstWhere(
                  (t) => t.codice == value,
                );
                setState(() {
                  row.codiceTabella = selected.codice;
                  row.descrizioneTabella = selected.descrizione;
                  _health = _computeHealth();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: row.numeratore.toStringAsFixed(2),
              decoration: const InputDecoration(labelText: 'Numeratore'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  row.numeratore = double.tryParse(value.replaceAll(',', '.')) ?? 0;
                  _health = _computeHealth();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: row.denominatore.toStringAsFixed(2),
              decoration: const InputDecoration(labelText: 'Denominatore'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  row.denominatore = double.tryParse(value.replaceAll(',', '.')) ?? 0;
                  _health = _computeHealth();
                });
              },
            ),
          ),
          IconButton(
            tooltip: 'Rimuovi',
            onPressed: () => setState(() {
              _rows.removeAt(index);
              _health = _computeHealth();
            }),
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }

  void _addRow() {
    final fallback = widget.tabelle.isNotEmpty ? widget.tabelle.first : null;
    setState(() {
      _rows.add(
        _CondominoQuotaDraft(
          codiceTabella: fallback?.codice ?? '',
          descrizioneTabella: fallback?.descrizione ?? '',
          numeratore: 0,
          denominatore: 1000,
        ),
      );
      _health = _computeHealth();
    });
  }

  Future<void> _onSave() async {
    final seen = <String>{};
    for (final row in _rows) {
      final code = row.codiceTabella.trim().toLowerCase();
      if (code.isEmpty) {
        _showError('Seleziona la tabella per tutte le righe');
        return;
      }
      if (seen.contains(code)) {
        _showError('Tabella duplicata nelle quote condomino');
        return;
      }
      seen.add(code);
      if (row.denominatore <= 0) {
        _showError('Il denominatore deve essere > 0');
        return;
      }
      if (row.numeratore < 0) {
        _showError('Il numeratore non puo\' essere negativo');
        return;
      }
    }
    final issues = _computeHealth().where((h) => !h.coherent).toList(growable: false);
    if (issues.isNotEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quote tabella non coerenti'),
          content: Text(
            'Alcune tabelle non sono ancora allineate (somma numeratori / denominatore).\n'
            'Potrai comunque salvare ora e completare le quote sugli altri condomini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Torna a modificare'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Salva comunque'),
            ),
          ],
        ),
      );
      if (proceed != true) {
        return;
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop(
      _QuoteSaveResult(
        rows: _rows,
        rebuildStorico: _rebuildStorico,
      ),
    );
  }

  Widget _buildHealthRow(_TabellaQuoteHealth health) {
    final color = health.coherent ? Colors.green : Colors.orange;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        health.coherent ? Icons.check_circle_outline : Icons.warning_amber_outlined,
        color: color,
      ),
      title: Text(health.codice),
      subtitle: Text(health.message),
      trailing: Text(
        health.coherent ? 'OK' : 'Da verificare',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  List<_TabellaQuoteHealth> _computeHealth() {
    final byCodeCurrent = <String, _CondominoQuotaDraft>{};
    for (final row in _rows) {
      final code = row.codiceTabella.trim().toLowerCase();
      if (code.isEmpty) continue;
      byCodeCurrent[code] = row;
    }

    final result = <_TabellaQuoteHealth>[];
    for (final tab in widget.tabelle) {
      final code = tab.codice.trim().toLowerCase();
      if (code.isEmpty) continue;

      double? denRef;
      double sumNum = 0;
      bool denomMismatch = false;
      final missing = <String>[];

      for (final condomino in widget.allCondomini) {
        double num = 0;
        double den = 0;
        bool found = false;

        if (condomino.id == widget.condomino.id) {
          final row = byCodeCurrent[code];
          if (row != null) {
            num = row.numeratore;
            den = row.denominatore;
            found = true;
          }
        } else {
          for (final cfg in condomino.config.tabelle) {
            if (cfg.codiceTabella.trim().toLowerCase() == code) {
              num = cfg.numeratore;
              den = cfg.denominatore;
              found = true;
              break;
            }
          }
        }

        if (!found || num <= 0 || den <= 0) {
          missing.add(condomino.nominativo);
          continue;
        }

        if (denRef == null) {
          denRef = den;
        } else if ((denRef - den).abs() > 0.0001) {
          denomMismatch = true;
        }
        sumNum += num;
      }

      final coherent = missing.isEmpty &&
          !denomMismatch &&
          denRef != null &&
          (sumNum - denRef).abs() <= 0.0001;

      String message;
      if (missing.isNotEmpty) {
        message = 'Mancano quote per: ${missing.join(', ')}';
      } else if (denomMismatch) {
        message = 'Denominatore non coerente tra condomini';
      } else if (denRef == null) {
        message = 'Nessuna quota valida';
      } else {
        message = 'Somma numeratori ${sumNum.toStringAsFixed(2)} / '
            'denominatore ${denRef.toStringAsFixed(2)}';
      }

      result.add(
        _TabellaQuoteHealth(
          codice: tab.codice,
          coherent: coherent,
          message: message,
        ),
      );
    }
    return result;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CondominoQuotaDraft {
  _CondominoQuotaDraft({
    required this.codiceTabella,
    required this.descrizioneTabella,
    required this.numeratore,
    required this.denominatore,
  });

  String codiceTabella;
  String descrizioneTabella;
  double numeratore;
  double denominatore;
}

class _QuoteSaveResult {
  const _QuoteSaveResult({
    required this.rows,
    required this.rebuildStorico,
  });

  final List<_CondominoQuotaDraft> rows;
  final bool rebuildStorico;
}

class _TabellaQuoteHealth {
  const _TabellaQuoteHealth({
    required this.codice,
    required this.coherent,
    required this.message,
  });

  final String codice;
  final bool coherent;
  final String message;
}
