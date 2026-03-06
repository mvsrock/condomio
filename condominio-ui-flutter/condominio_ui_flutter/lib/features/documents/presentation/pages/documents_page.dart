import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_breakpoints.dart';
import '../../application/documents_ui_notifier.dart';
import '../../data/documents_repository_provider.dart';
import '../../domain/condominio_document_model.dart';
import '../../domain/condomino_document_model.dart';
import '../../domain/movimento_model.dart';
import '../../domain/tabella_model.dart';
import '../dialogs/documents_config_dialogs.dart';
import '../dialogs/documents_crud_dialogs.dart';
import '../widgets/documents_panels.dart';
import '../widgets/documents_shell_sections.dart';

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
            const DocumentsCondominioSelectorBar(),
            const SizedBox(height: 12),
            const DocumentsSummaryHeader(),
            const SizedBox(height: 12),
            DocumentsActionsBar(
              onConfigureRiparto: (selectedCondominio, tabelle) =>
                  _openConfigurazioniSpesaDialog(
                    context: context,
                    ref: ref,
                    selectedCondominio: selectedCondominio,
                    tabelle: tabelle,
                  ),
              onCreateTabella: () => _openCreateTabellaDialog(
                context: context,
                ref: ref,
              ),
              onCreateMovimento: (selectedCondominio) =>
                  _openCreateMovimentoDialog(
                    context: context,
                    ref: ref,
                    selectedCondominio: selectedCondominio,
                  ),
              onRefresh: dataNotifier.loadForSelectedCondominio,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isWide
                  ? _desktopLayout(
                      context: context,
                      ref: ref,
                      onSelectCondomino: ref
                          .read(documentsUiProvider.notifier)
                          .selectCondomino,
                    )
                  : DocumentsMobileLayout(
                      onOpenSelectedCondominoDetail:
                          (selectedCondomino, isSaving) =>
                              _openCondominoDetailBottomSheet(
                                context: context,
                                ref: ref,
                                condomino: selectedCondomino,
                                isSaving: isSaving,
                              ),
                      onOpenMovimentoDetail: (movimento) =>
                          _openMovimentoDetailDialog(
                            context: context,
                            movimento: movimento,
                          ),
                      onEditMovimento: (movimento) => _openEditMovimentoDialog(
                        context: context,
                        ref: ref,
                        movimento: movimento,
                      ),
                      onDeleteMovimento: (movimento) =>
                          _confirmDeleteMovimento(
                            context: context,
                            ref: ref,
                            movimento: movimento,
                          ),
                      onEditTabella: (selectedCondominio, tabelle, tabella) =>
                          _openEditTabellaDialog(
                            context: context,
                            ref: ref,
                            selectedCondominio: selectedCondominio,
                            tabelle: tabelle,
                            tabella: tabella,
                          ),
                      onDeleteTabella:
                          (selectedCondominio, tabelle, tabella) =>
                              _confirmDeleteTabella(
                                context: context,
                                ref: ref,
                                selectedCondominio: selectedCondominio,
                                tabelle: tabelle,
                                tabella: tabella,
                              ),
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
    final result = await showDocumentsTabellaFormDialog(
      context: context,
      title: 'Nuova tabella',
      confirmLabel: 'Crea',
    );
    if (result == null) return;
    try {
      await ref.read(documentsDataProvider.notifier).createTabella(
            codice: result.codice,
            descrizione: result.descrizione,
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
    final result = await showDialog<DocumentsConfigurazioniSaveResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DocumentsConfigurazioniSpesaDialog(
        initial: selectedCondominio.configurazioniSpesa
            .map(DocumentsConfigurazioneSpesaDraft.fromModel)
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
    final spesaCodes = (selectedCondominio?.configurazioniSpesa ?? const [])
        .map<String>((c) => c.codice)
        .where((c) => c.trim().isNotEmpty)
        .toList(growable: false);
    final result = await showDocumentsMovimentoFormDialog(
      context: context,
      title: 'Nuova spesa',
      confirmLabel: 'Registra',
      spesaCodes: spesaCodes,
      initialCodiceSpesa: spesaCodes.isNotEmpty ? spesaCodes.first : '',
      lockToAvailableCodes: true,
    );
    if (result == null) return;
    try {
      await ref.read(documentsDataProvider.notifier).createMovimento(
            codiceSpesa: result.codiceSpesa,
            descrizione: result.descrizione,
            importo: result.importo,
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
    final result = await showDocumentsMovimentoFormDialog(
      context: context,
      title: 'Modifica spesa',
      confirmLabel: 'Salva',
      spesaCodes: const [],
      initialCodiceSpesa: movimento.codiceSpesa,
      initialDescrizione: movimento.descrizione,
      initialImporto: movimento.importo,
    );
    if (result == null) return;
    try {
      await ref.read(documentsDataProvider.notifier).updateMovimento(
            movimentoId: movimento.id,
            codiceSpesa: result.codiceSpesa,
            descrizione: result.descrizione,
            importo: result.importo,
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
    final ok = await showDocumentsDeleteMovimentoDialog(
      context: context,
      descrizione: movimento.descrizione,
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
    final result = await showDocumentsTabellaFormDialog(
      context: context,
      title: 'Modifica tabella',
      confirmLabel: 'Salva',
      initialCodice: tabella.codice,
      initialDescrizione: tabella.descrizione,
    );
    if (result == null) return;
    if (!context.mounted) return;
    final newCode = result.codice.trim();
    if (newCode.toLowerCase() != tabella.codice.trim().toLowerCase()) {
      final linkedCodes = _linkedSpesaCodesForTabella(selectedCondominio, tabella);
      if (linkedCodes.isNotEmpty) {
        final proceed = await showDocumentsRenameTabellaInUseDialog(
          context: context,
          codiceTabella: tabella.codice,
          linkedCodes: linkedCodes,
        );
        if (proceed != true) {
          return;
        }
      }
    }
    try {
      await ref.read(documentsDataProvider.notifier).updateTabella(
            tabellaId: tabella.id,
            codice: result.codice,
            descrizione: result.descrizione,
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
      final action = await showDocumentsLinkedTabellaDialog(
        context: context,
        codiceTabella: tabella.codice,
        linkedCodes: linkedCodes,
      );
      if (action == DocumentsLinkedTabellaAction.openConfig &&
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
      if (action == DocumentsLinkedTabellaAction.autoCleanup &&
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
      if (action != DocumentsLinkedTabellaAction.openConfig) {
        return;
      }
    }
    if (!context.mounted) return;

    final ok = await showDocumentsDeleteTabellaDialog(
      context: context,
      codiceTabella: tabella.codice,
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
    required ValueChanged<String?> onSelectCondomino,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DocumentsCondominiPanel(onSelect: onSelectCondomino),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: DocumentsMovimentiPanel(
            onOpenMovimentoDetail: (movimento) => _openMovimentoDetailDialog(
              context: context,
              movimento: movimento,
            ),
            onEditMovimento: (movimento) => _openEditMovimentoDialog(
              context: context,
              ref: ref,
              movimento: movimento,
            ),
            onDeleteMovimento: (movimento) => _confirmDeleteMovimento(
              context: context,
              ref: ref,
              movimento: movimento,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: DocumentsDetailPanel(
            onOpenQuoteDialog: (
              selectedCondomino,
              allCondomini,
              tabelle,
            ) =>
                _openCondominoQuoteDialog(
                  context: context,
                  ref: ref,
                  selectedCondomino: selectedCondomino,
                  allCondomini: allCondomini,
                  tabelle: tabelle,
                ),
            onAddVersamento: (selectedCondomino) => _openAddVersamentoDialog(
              context: context,
              ref: ref,
              selectedCondomino: selectedCondomino,
            ),
            onEditVersamento: (selectedCondomino, versamento) =>
                _openEditVersamentoDialog(
                  context: context,
                  ref: ref,
                  selectedCondomino: selectedCondomino,
                  versamento: versamento,
                ),
            onDeleteVersamento: (selectedCondomino, versamento) =>
                _confirmDeleteVersamento(
                  context: context,
                  ref: ref,
                  selectedCondomino: selectedCondomino,
                  versamento: versamento,
                ),
            onEditTabella: (selectedCondominio, tabelle, tabella) =>
                _openEditTabellaDialog(
                  context: context,
                  ref: ref,
                  selectedCondominio: selectedCondominio,
                  tabelle: tabelle,
                  tabella: tabella,
                ),
            onDeleteTabella: (selectedCondominio, tabelle, tabella) =>
                _confirmDeleteTabella(
                  context: context,
                  ref: ref,
                  selectedCondominio: selectedCondominio,
                  tabelle: tabelle,
                  tabella: tabella,
                ),
          ),
        ),
      ],
    );
  }

  void _openCondominoDetailBottomSheet({
    required BuildContext context,
    required WidgetRef ref,
    required CondominoDocumentModel condomino,
    required bool isSaving,
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
                DocumentsCondominoDetailSheetContent(
                  condomino: condomino,
                  isSaving: isSaving,
                  onAddVersamento: (selectedCondomino) => _openAddVersamentoDialog(
                    context: context,
                    ref: ref,
                    selectedCondomino: selectedCondomino,
                  ),
                  onEditVersamento: (selectedCondomino, versamento) =>
                      _openEditVersamentoDialog(
                        context: context,
                        ref: ref,
                        selectedCondomino: selectedCondomino,
                        versamento: versamento,
                      ),
                  onDeleteVersamento: (selectedCondomino, versamento) =>
                      _confirmDeleteVersamento(
                        context: context,
                        ref: ref,
                        selectedCondomino: selectedCondomino,
                        versamento: versamento,
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
    final result = await showDialog<DocumentsQuoteSaveResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DocumentsCondominoQuoteDialog(
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

  Future<void> _openAddVersamentoDialog({
    required BuildContext context,
    required WidgetRef ref,
    required CondominoDocumentModel selectedCondomino,
  }) async {
    final result = await showDocumentsVersamentoFormDialog(
      context: context,
      title: 'Nuovo versamento - ${selectedCondomino.nominativo}',
      confirmLabel: 'Salva',
      initialDescrizione: 'Versamento',
    );
    if (result == null) return;
    if (!context.mounted) return;

    try {
      final now = DateTime.now().toUtc();
      await ref.read(documentsDataProvider.notifier).addCondominoVersamento(
            condominoId: selectedCondomino.id,
            versamento: CondominoVersamentoDraft(
              descrizione: result.descrizione,
              importo: result.importo,
              date: now,
              insertedAt: now,
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Versamento registrato')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore versamento: $e')),
        );
      }
    }
  }

  Future<void> _openEditVersamentoDialog({
    required BuildContext context,
    required WidgetRef ref,
    required CondominoDocumentModel selectedCondomino,
    required VersamentoModel versamento,
  }) async {
    final result = await showDocumentsVersamentoFormDialog(
      context: context,
      title: 'Modifica versamento',
      confirmLabel: 'Salva',
      initialDescrizione: versamento.descrizione,
      initialImporto: versamento.importo,
    );
    if (result == null) return;
    if (!context.mounted) return;

    try {
      await ref.read(documentsDataProvider.notifier).updateCondominoVersamento(
            condominoId: selectedCondomino.id,
            versamentoId: versamento.id,
            versamento: CondominoVersamentoDraft(
              id: versamento.id,
              descrizione: result.descrizione,
              importo: result.importo,
              date: versamento.date,
              insertedAt: versamento.insertedAt,
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Versamento aggiornato')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore modifica versamento: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteVersamento({
    required BuildContext context,
    required WidgetRef ref,
    required CondominoDocumentModel selectedCondomino,
    required VersamentoModel versamento,
  }) async {
    final ok = await showDocumentsDeleteVersamentoDialog(
      context: context,
      descrizione: versamento.descrizione,
      importo: versamento.importo,
    );
    if (ok != true) return;
    if (!context.mounted) return;

    try {
      await ref.read(documentsDataProvider.notifier).deleteCondominoVersamento(
            condominoId: selectedCondomino.id,
            versamentoId: versamento.id,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Versamento eliminato')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore elimina versamento: $e')),
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

}
