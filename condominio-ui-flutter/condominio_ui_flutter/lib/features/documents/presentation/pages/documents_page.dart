import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_breakpoints.dart';
import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../home/application/home_navigation_provider.dart';
import '../../application/documents_ui_notifier.dart';
import '../../data/documents_repository_provider.dart';
import '../../domain/condominio_document_model.dart';
import '../../domain/condomino_document_model.dart';
import '../../domain/movimento_model.dart';
import '../../domain/tabella_model.dart';
import '../dialogs/documents_config_dialogs.dart';
import '../dialogs/documents_crud_dialogs.dart';
import '../dialogs/documents_budget_dialogs.dart';
import '../dialogs/documents_morosita_dialogs.dart';
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
    final isLoading = ref.watch(documentsIsLoadingProvider);
    final errorMessage = ref.watch(documentsErrorMessageProvider);
    final dataset = ref.watch(documentsRepositoryProvider);
    final dataNotifier = ref.read(documentsDataProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = AppBreakpoints.isDocumentsWide(constraints.maxWidth);

        if (isLoading && dataset.condomini.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage != null) ...[
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
                          errorMessage,
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
              onCreateTabella: () =>
                  _openCreateTabellaDialog(context: context, ref: ref),
              onCreateMovimento: (selectedCondominio) =>
                  _openCreateMovimentoDialog(
                    context: context,
                    ref: ref,
                    selectedCondominio: selectedCondominio,
                  ),
              onOpenPreventivo: (selectedCondominio) => _openPreventivoDialog(
                context: context,
                ref: ref,
                selectedCondominio: selectedCondominio,
              ),
              onOpenMorosita: (selectedCondominio) => _openMorositaDialog(
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
                      onDeleteMovimento: (movimento) => _confirmDeleteMovimento(
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
      await ref
          .read(documentsDataProvider.notifier)
          .createTabella(
            codice: result.codice,
            descrizione: result.descrizione,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tabella creata')));
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
      await ref
          .read(documentsDataProvider.notifier)
          .updateConfigurazioniSpesa(
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
        await ref
            .read(documentsDataProvider.notifier)
            .rebuildStoricoCondominio();
      }
      if (context.mounted) {
        final message = result.rebuildStorico
            ? 'Configurazioni aggiornate e storico ricalcolato'
            : 'Configurazioni aggiornate (valide per nuove spese)';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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
    final condomini = ref
        .read(condominiBySelectedCondominioProvider)
        .where((c) => c.isActivePosition)
        .toList(growable: false);
    final spesaCodes = (selectedCondominio?.configurazioniSpesa ?? const [])
        .map<String>((c) => c.codice)
        .where((c) => c.trim().isNotEmpty)
        .toList(growable: false);
    final result = await showDocumentsMovimentoFormDialog(
      context: context,
      title: 'Nuova spesa',
      confirmLabel: 'Registra',
      spesaCodes: spesaCodes,
      condomini: condomini,
      initialCodiceSpesa: spesaCodes.isNotEmpty ? spesaCodes.first : '',
      lockToAvailableCodes: true,
    );
    if (result == null) return;
    try {
      await ref
          .read(documentsDataProvider.notifier)
          .createMovimento(
            codiceSpesa: result.codiceSpesa,
            tipoRiparto: result.tipoRiparto,
            descrizione: result.descrizione,
            importo: result.importo,
            ripartizioneCondomini: result.ripartizioneCondomini
                .map(
                  (q) => MovimentoRipartoCondominoDraft(
                    idCondomino: q.idCondomino,
                    nominativo: q.nominativo,
                    importo: q.importo,
                  ),
                )
                .toList(growable: false),
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

  Future<void> _openPreventivoDialog({
    required BuildContext context,
    required WidgetRef ref,
    required CondominioDocumentModel? selectedCondominio,
  }) async {
    if (selectedCondominio == null) return;
    final snapshot = ref.read(selectedPreventivoSnapshotProvider);
    final isReadOnly = ref.read(selectedManagedCondominioIsClosedProvider);
    final isAdmin = ref.read(homeIsAdminProvider);
    final result = await showDocumentsPreventivoDialog(
      context: context,
      snapshot: snapshot,
      isReadOnly: isReadOnly || !isAdmin,
    );
    if (result == null || !context.mounted) {
      return;
    }
    try {
      await ref
          .read(documentsDataProvider.notifier)
          .savePreventivoRows(
            rows: result.rows
                .map(
                  (row) => PreventivoRowDraft(
                    codiceSpesa: row.codiceSpesa,
                    codiceTabella: row.codiceTabella,
                    descrizioneTabella: row.descrizioneTabella,
                    preventivo: row.preventivo,
                  ),
                )
                .toList(growable: false),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Preventivo aggiornato')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore salvataggio preventivo: $e')),
        );
      }
    }
  }

  Future<void> _openMorositaDialog({
    required BuildContext context,
    required WidgetRef ref,
    required CondominioDocumentModel? selectedCondominio,
  }) async {
    if (selectedCondominio == null) return;
    final items = ref.read(selectedMorositaItemsProvider);
    final isSaving = ref.read(documentsIsSavingProvider);
    final isReadOnly = ref.read(selectedManagedCondominioIsClosedProvider);
    final isAdmin = ref.read(homeIsAdminProvider);
    await showDocumentsMorositaDialog(
      context: context,
      items: items,
      isSaving: isSaving,
      isReadOnly: isReadOnly || !isAdmin,
      onUpdateStato: (item, stato) async {
        await ref
            .read(documentsDataProvider.notifier)
            .updateMorositaStato(condominoId: item.condominoId, stato: stato);
      },
      onAddSollecito: (item, canale, titolo, note) async {
        await ref
            .read(documentsDataProvider.notifier)
            .addMorositaSollecito(
              condominoId: item.condominoId,
              canale: canale,
              titolo: titolo,
              note: note,
            );
      },
      onGenerateAutomatic: (minDays) {
        return ref
            .read(documentsDataProvider.notifier)
            .generateAutomaticSolleciti(minDaysOverdue: minDays);
      },
      onReloadItems: () {
        return ref.read(documentsDataProvider.notifier).reloadMorositaItems();
      },
      readSollecitiMap: () {
        return ref.read(selectedSollecitiByCondominoProvider);
      },
    );
  }

  Future<void> _openEditMovimentoDialog({
    required BuildContext context,
    required WidgetRef ref,
    required MovimentoModel movimento,
  }) async {
    final condomini = ref.read(condominiBySelectedCondominioProvider);
    final result = await showDocumentsMovimentoFormDialog(
      context: context,
      title: 'Modifica spesa',
      confirmLabel: 'Salva',
      spesaCodes: const [],
      condomini: condomini,
      initialCodiceSpesa: movimento.codiceSpesa,
      initialTipoRiparto: movimento.tipoRiparto,
      initialDescrizione: movimento.descrizione,
      initialImporto: movimento.importo,
      initialRipartizioneCondomini: movimento.ripartizioneCondomini
          .map(
            (q) => DocumentsMovimentoRipartoCondominoForm(
              idCondomino: q.idCondomino,
              nominativo: q.nominativo,
              importo: q.importo,
            ),
          )
          .toList(growable: false),
    );
    if (result == null) return;
    try {
      await ref
          .read(documentsDataProvider.notifier)
          .updateMovimento(
            movimentoId: movimento.id,
            codiceSpesa: result.codiceSpesa,
            tipoRiparto: result.tipoRiparto,
            descrizione: result.descrizione,
            importo: result.importo,
            ripartizioneCondomini: result.ripartizioneCondomini
                .map(
                  (q) => MovimentoRipartoCondominoDraft(
                    idCondomino: q.idCondomino,
                    nominativo: q.nominativo,
                    importo: q.importo,
                  ),
                )
                .toList(growable: false),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Spesa aggiornata')));
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
      await ref
          .read(documentsDataProvider.notifier)
          .deleteMovimento(movimentoId: movimento.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Spesa eliminata')));
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
      final linkedCodes = _linkedSpesaCodesForTabella(
        selectedCondominio,
        tabella,
      );
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
      await ref
          .read(documentsDataProvider.notifier)
          .updateTabella(
            tabellaId: tabella.id,
            codice: result.codice,
            descrizione: result.descrizione,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tabella aggiornata')));
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
    final linkedCodes = _linkedSpesaCodesForTabella(
      selectedCondominio,
      tabella,
    );
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
          await ref
              .read(documentsDataProvider.notifier)
              .cleanupDeleteTabella(tabellaId: tabella.id);
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
      await ref
          .read(documentsDataProvider.notifier)
          .deleteTabella(tabellaId: tabella.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tabella eliminata')));
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
        (t) =>
            t.codice.trim().toLowerCase() ==
            tabella.codice.trim().toLowerCase(),
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
            onOpenQuoteDialog: (selectedCondomino, allCondomini, tabelle) =>
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
            onAddRata: (selectedCondomino) => _openAddRataDialog(
              context: context,
              ref: ref,
              selectedCondomino: selectedCondomino,
            ),
            onEditRata: (selectedCondomino, rata) => _openEditRataDialog(
              context: context,
              ref: ref,
              selectedCondomino: selectedCondomino,
              rata: rata,
            ),
            onDeleteRata: (selectedCondomino, rata) => _confirmDeleteRata(
              context: context,
              ref: ref,
              selectedCondomino: selectedCondomino,
              rata: rata,
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
                  onAddVersamento: (selectedCondomino) =>
                      _openAddVersamentoDialog(
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
                  onAddRata: (selectedCondomino) => _openAddRataDialog(
                    context: context,
                    ref: ref,
                    selectedCondomino: selectedCondomino,
                  ),
                  onEditRata: (selectedCondomino, rata) => _openEditRataDialog(
                    context: context,
                    ref: ref,
                    selectedCondomino: selectedCondomino,
                    rata: rata,
                  ),
                  onDeleteRata: (selectedCondomino, rata) => _confirmDeleteRata(
                    context: context,
                    ref: ref,
                    selectedCondomino: selectedCondomino,
                    rata: rata,
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
      await ref
          .read(documentsDataProvider.notifier)
          .updateCondominoQuoteTabelle(
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
        await ref
            .read(documentsDataProvider.notifier)
            .rebuildStoricoCondominio();
      }
      if (context.mounted) {
        final message = result.rebuildStorico
            ? 'Quote aggiornate e storico ricalcolato'
            : 'Quote aggiornate (valide per nuove spese)';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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
      rataItems: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Nessuna rata'),
        ),
        ...selectedCondomino.config.rate.map(
          (rata) => DropdownMenuItem<String?>(
            value: rata.id,
            child: Text('${rata.codice} - ${rata.descrizione}'),
          ),
        ),
      ],
      initialDescrizione: 'Versamento',
    );
    if (result == null) return;
    if (!context.mounted) return;

    try {
      final now = DateTime.now().toUtc();
      await ref
          .read(documentsDataProvider.notifier)
          .addCondominoVersamento(
            condominoId: selectedCondomino.id,
            versamento: CondominoVersamentoDraft(
              descrizione: result.descrizione,
              importo: result.importo,
              rataId: result.rataId,
              date: now,
              insertedAt: now,
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Versamento registrato')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore versamento: $e')));
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
      rataItems: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Nessuna rata'),
        ),
        ...selectedCondomino.config.rate.map(
          (rata) => DropdownMenuItem<String?>(
            value: rata.id,
            child: Text('${rata.codice} - ${rata.descrizione}'),
          ),
        ),
      ],
      initialRataId: versamento.rataId,
      initialDescrizione: versamento.descrizione,
      initialImporto: versamento.importo,
    );
    if (result == null) return;
    if (!context.mounted) return;

    try {
      await ref
          .read(documentsDataProvider.notifier)
          .updateCondominoVersamento(
            condominoId: selectedCondomino.id,
            versamentoId: versamento.id,
            versamento: CondominoVersamentoDraft(
              id: versamento.id,
              descrizione: result.descrizione,
              importo: result.importo,
              rataId: result.rataId,
              date: versamento.date,
              insertedAt: versamento.insertedAt,
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Versamento aggiornato')));
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
      await ref
          .read(documentsDataProvider.notifier)
          .deleteCondominoVersamento(
            condominoId: selectedCondomino.id,
            versamentoId: versamento.id,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Versamento eliminato')));
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD9E2EC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movimento.descrizione,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(
                              'Riparto: ${movimento.tipoRiparto.label}',
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          Chip(
                            label: Text(
                              'Importo: ${movimento.importo.toStringAsFixed(2)}',
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      if (movimento.tipoRiparto ==
                              MovimentoRipartoTipo.individuale &&
                          movimento.ripartizioneCondomini.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Assegnata a: ${movimento.ripartizioneCondomini.first.nominativo}',
                          ),
                        ),
                    ],
                  ),
                ),
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
                    (r) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFDFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.table_chart_outlined,
                            size: 18,
                            color: Color(0xFF4B5563),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('${r.codice} - ${r.descrizione}'),
                          ),
                          Text(
                            r.importo.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
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
                    (r) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFDFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 18,
                            color: Color(0xFF4B5563),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(r.nominativo)),
                          Text(
                            r.importo.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
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

  Future<void> _openAddRataDialog({
    required BuildContext context,
    required WidgetRef ref,
    required CondominoDocumentModel selectedCondomino,
  }) async {
    final result = await showDocumentsRataFormDialog(
      context: context,
      title: 'Nuova rata - ${selectedCondomino.nominativo}',
      confirmLabel: 'Salva',
    );
    if (result == null) return;
    try {
      await ref
          .read(documentsDataProvider.notifier)
          .addCondominoRata(
            condominoId: selectedCondomino.id,
            rata: CondominoRataDraft(
              codice: result.codice,
              descrizione: result.descrizione,
              tipo: result.tipo,
              scadenza: result.scadenza,
              importo: result.importo,
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Rata aggiunta')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore rata: $e')));
      }
    }
  }

  Future<void> _openEditRataDialog({
    required BuildContext context,
    required WidgetRef ref,
    required CondominoDocumentModel selectedCondomino,
    required RataModel rata,
  }) async {
    final result = await showDocumentsRataFormDialog(
      context: context,
      title: 'Modifica rata',
      confirmLabel: 'Salva',
      initialCodice: rata.codice,
      initialDescrizione: rata.descrizione,
      initialTipo: rata.tipo.isEmpty ? 'ORDINARIA' : rata.tipo,
      initialScadenza: rata.scadenza?.toLocal(),
      initialImporto: rata.importo,
    );
    if (result == null) return;
    try {
      await ref
          .read(documentsDataProvider.notifier)
          .updateCondominoRata(
            condominoId: selectedCondomino.id,
            rataId: rata.id,
            rata: CondominoRataDraft(
              id: rata.id,
              codice: result.codice,
              descrizione: result.descrizione,
              tipo: result.tipo,
              scadenza: result.scadenza,
              importo: result.importo,
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Rata aggiornata')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore modifica rata: $e')));
      }
    }
  }

  Future<void> _confirmDeleteRata({
    required BuildContext context,
    required WidgetRef ref,
    required CondominoDocumentModel selectedCondomino,
    required RataModel rata,
  }) async {
    final ok = await showDocumentsDeleteRataDialog(
      context: context,
      codice: rata.codice,
    );
    if (ok != true) return;
    try {
      await ref
          .read(documentsDataProvider.notifier)
          .deleteCondominoRata(
            condominoId: selectedCondomino.id,
            rataId: rata.id,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Rata eliminata')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore elimina rata: $e')));
      }
    }
  }
}
