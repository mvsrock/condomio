import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../home/application/home_navigation_provider.dart';
import '../../application/documents_ui_notifier.dart';
import '../../data/documents_repository_provider.dart';
import '../../domain/condominio_document_model.dart';
import '../../domain/condomino_document_model.dart';
import '../../domain/movimento_model.dart';
import '../../domain/tabella_model.dart';
import 'documents_common_widgets.dart';

typedef DocumentsConfigureRipartoCallback =
    Future<void> Function(
      CondominioDocumentModel selectedCondominio,
      List<TabellaModel> tabelle,
    );
typedef DocumentsCreateMovimentoCallback =
    Future<void> Function(CondominioDocumentModel? selectedCondominio);
typedef DocumentsOpenPreventivoCallback =
    Future<void> Function(CondominioDocumentModel? selectedCondominio);
typedef DocumentsOpenMorositaCallback =
    Future<void> Function(CondominioDocumentModel? selectedCondominio);
typedef DocumentsOpenArchivioCallback =
    Future<void> Function(CondominioDocumentModel? selectedCondominio);
typedef DocumentsOpenReportCallback =
    Future<void> Function(CondominioDocumentModel? selectedCondominio);
typedef DocumentsOpenJobsCallback = Future<void> Function();
typedef DocumentsRefreshDataCallback = Future<void> Function();
typedef DocumentsOpenSelectedCondominoDetailCallback =
    void Function(CondominoDocumentModel selectedCondomino, bool isSaving);
typedef DocumentsMobileMovimentoCallback =
    Future<void> Function(MovimentoModel movimento);
typedef DocumentsMobileTabellaCallback =
    Future<void> Function(
      CondominioDocumentModel? selectedCondominio,
      List<TabellaModel> tabelle,
      TabellaModel tabella,
    );

/// Selettore del condominio/anno attivo.
class DocumentsCondominioSelectorBar extends ConsumerWidget {
  const DocumentsCondominioSelectorBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataset = ref.watch(documentsRepositoryProvider);
    final selectedCondominio = ref.watch(selectedCondominioProvider);
    final ui = ref.read(documentsUiProvider.notifier);
    final selectedExercise = ref.watch(selectedManagedCondominioProvider);

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dataset.condomini.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final condominio = dataset.condomini[index];
          final selected = selectedCondominio?.id == condominio.id;
          final isClosed =
              selectedExercise?.id == condominio.id &&
              selectedExercise!.isClosed;
          return ChoiceChip(
            label: Text(
              '${condominio.label} / ${condominio.gestioneLabel} (${condominio.anno})${isClosed ? ' - chiuso' : ''}',
            ),
            selected: selected,
            onSelected: (_) => ui.selectCondominio(condominio.id),
          );
        },
      ),
    );
  }
}

/// Riepilogo sintetico del condominio attivo.
class DocumentsSummaryHeader extends ConsumerWidget {
  const DocumentsSummaryHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCondominio = ref.watch(selectedCondominioProvider);
    final condomini = ref.watch(condominiBySelectedCondominioProvider);
    final movimenti = ref.watch(movimentiBySelectedCondominioProvider);
    final documenti = ref.watch(documentiBySelectedCondominioProvider);
    final preventivo = ref.watch(selectedPreventivoSnapshotProvider);
    final morosita = ref.watch(selectedMorositaItemsProvider);
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);

    if (selectedCondominio == null) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        DocumentsStatChip(
          icon: Icons.account_balance_wallet_outlined,
          label:
              'Residuo condominio: ${selectedCondominio.residuo.toStringAsFixed(2)}',
        ),
        DocumentsStatChip(
          icon: Icons.people_outline,
          label: 'Posizioni: ${condomini.length}',
        ),
        DocumentsStatChip(
          icon: Icons.receipt_long_outlined,
          label: 'Movimenti: ${movimenti.length}',
        ),
        DocumentsStatChip(
          icon: Icons.folder_open_outlined,
          label: 'Documenti: ${documenti.length}',
        ),
        DocumentsStatChip(
          icon: Icons.analytics_outlined,
          label: 'Delta budget: ${preventivo.totaleDelta.toStringAsFixed(2)}',
        ),
        DocumentsStatChip(
          icon: Icons.warning_amber_outlined,
          label:
              'Morosi: ${morosita.where((item) => item.hasDebitoScaduto).length}',
        ),
        if (isReadOnly)
          const DocumentsStatChip(
            icon: Icons.lock_outline,
            label: 'Esercizio chiuso',
          ),
      ],
    );
  }
}

/// Barra azioni principale del modulo documenti.
class DocumentsActionsBar extends ConsumerWidget {
  const DocumentsActionsBar({
    super.key,
    required this.onConfigureRiparto,
    required this.onCreateTabella,
    required this.onCreateMovimento,
    required this.onOpenPreventivo,
    required this.onOpenMorosita,
    required this.onOpenArchivio,
    required this.onOpenReport,
    required this.onOpenJobs,
    required this.onRefresh,
  });

  final DocumentsConfigureRipartoCallback onConfigureRiparto;
  final Future<void> Function() onCreateTabella;
  final DocumentsCreateMovimentoCallback onCreateMovimento;
  final DocumentsOpenPreventivoCallback onOpenPreventivo;
  final DocumentsOpenMorositaCallback onOpenMorosita;
  final DocumentsOpenArchivioCallback onOpenArchivio;
  final DocumentsOpenReportCallback onOpenReport;
  final DocumentsOpenJobsCallback onOpenJobs;
  final DocumentsRefreshDataCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaving = ref.watch(documentsIsSavingProvider);
    final isLoading = ref.watch(documentsIsLoadingProvider);
    final selectedCondominio = ref.watch(selectedCondominioProvider);
    final tabelle = ref.watch(tabelleBySelectedCondominioProvider);
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);
    final isAdmin = ref.watch(homeIsAdminProvider);
    final canManage = isAdmin && !isReadOnly;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: (isSaving || selectedCondominio == null || !canManage)
              ? null
              : () => onConfigureRiparto(selectedCondominio, tabelle),
          icon: const Icon(Icons.settings_suggest_outlined),
          label: const Text('Configura riparto'),
        ),
        FilledButton.icon(
          onPressed: (isSaving || !canManage)
              ? null
              : () => onCreateMovimento(selectedCondominio),
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('Nuova spesa'),
        ),
        FilledButton.tonalIcon(
          onPressed: (isSaving || !canManage) ? null : onCreateTabella,
          icon: const Icon(Icons.table_chart_outlined),
          label: const Text('Nuova tabella'),
        ),
        OutlinedButton.icon(
          onPressed: (isSaving || selectedCondominio == null)
              ? null
              : () => onOpenPreventivo(selectedCondominio),
          icon: const Icon(Icons.analytics_outlined),
          label: const Text('Preventivo'),
        ),
        OutlinedButton.icon(
          onPressed: (isSaving || selectedCondominio == null)
              ? null
              : () => onOpenMorosita(selectedCondominio),
          icon: const Icon(Icons.warning_amber_outlined),
          label: const Text('Morosita'),
        ),
        OutlinedButton.icon(
          onPressed: (isSaving || selectedCondominio == null)
              ? null
              : () => onOpenArchivio(selectedCondominio),
          icon: const Icon(Icons.folder_outlined),
          label: const Text('Archivio'),
        ),
        OutlinedButton.icon(
          onPressed: (isSaving || selectedCondominio == null)
              ? null
              : () => onOpenReport(selectedCondominio),
          icon: const Icon(Icons.assessment_outlined),
          label: const Text('Report'),
        ),
        OutlinedButton.icon(
          onPressed: isSaving ? null : onOpenJobs,
          icon: const Icon(Icons.work_history_outlined),
          label: const Text('Coda job'),
        ),
        OutlinedButton.icon(
          onPressed: isLoading ? null : onRefresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Aggiorna'),
        ),
      ],
    );
  }
}

/// Layout mobile a tab del modulo documenti.
///
/// Legge direttamente lo stato Riverpod di selezioni, liste e filtro, così la
/// pagina principale non deve ripassare lo stesso stato ai sotto-widget.
class DocumentsMobileLayout extends ConsumerWidget {
  const DocumentsMobileLayout({
    super.key,
    required this.onOpenSelectedCondominoDetail,
    required this.onOpenMovimentoDetail,
    required this.onEditMovimento,
    required this.onDeleteMovimento,
    required this.onEditTabella,
    required this.onDeleteTabella,
  });

  final DocumentsOpenSelectedCondominoDetailCallback
  onOpenSelectedCondominoDetail;
  final DocumentsMobileMovimentoCallback onOpenMovimentoDetail;
  final DocumentsMobileMovimentoCallback onEditMovimento;
  final DocumentsMobileMovimentoCallback onDeleteMovimento;
  final DocumentsMobileTabellaCallback onEditTabella;
  final DocumentsMobileTabellaCallback onDeleteTabella;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCondominio = ref.watch(selectedCondominioProvider);
    final condomini = ref.watch(condominiBySelectedCondominioProvider);
    final selectedCondomino = ref.watch(selectedCondominoDocumentProvider);
    final movimenti = ref.watch(movimentiBySelectedCondominioProvider);
    final tabelle = ref.watch(tabelleBySelectedCondominioProvider);
    final search = ref.watch(
      documentsUiProvider.select((state) => state.searchMovimenti),
    );
    final isSaving = ref.watch(
      documentsDataProvider.select((state) => state.isSaving),
    );
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);
    final ui = ref.read(documentsUiProvider.notifier);

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
                  onPressed: () => onOpenSelectedCondominoDetail(
                    selectedCondomino,
                    isSaving,
                  ),
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
                      return DocumentsMobileCondominoTile(
                        selected: selectedCondomino?.id == item.id,
                        title: item.nominativo,
                        subtitle: 'Scala ${item.scala} - Int ${item.interno}',
                        residuo: item.residuo,
                        onTap: () => ui.selectCondomino(item.id),
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
                        child: DocumentsMovimentiSearchField(
                          value: search,
                          onChanged: ui.setSearchMovimenti,
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: movimenti.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final movimento = movimenti[index];
                            final individualLabel =
                                movimento.tipoRiparto ==
                                    MovimentoRipartoTipo.individuale
                                ? ' - su ${_individualAssigneeLabel(movimento)}'
                                : '';
                            return DocumentsMobileMovimentoTile(
                              title: movimento.descrizione,
                              subtitle:
                                  'Codice ${movimento.codiceSpesa} - ${movimento.tipoRiparto.label}$individualLabel',
                              importo: movimento.importo,
                              onTap: () => onOpenMovimentoDetail(movimento),
                              onEdit: isReadOnly
                                  ? null
                                  : () => onEditMovimento(movimento),
                              onDelete: isReadOnly
                                  ? null
                                  : () => onDeleteMovimento(movimento),
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
                      final tabella = tabelle[index];
                      return DocumentsMobileTabellaTile(
                        codice: tabella.codice,
                        descrizione: tabella.descrizione,
                        onEdit: isReadOnly
                            ? null
                            : () => onEditTabella(
                                selectedCondominio,
                                tabelle,
                                tabella,
                              ),
                        onDelete: isReadOnly
                            ? null
                            : () => onDeleteTabella(
                                selectedCondominio,
                                tabelle,
                                tabella,
                              ),
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
}

String _individualAssigneeLabel(MovimentoModel movimento) {
  if (movimento.ripartizioneCondomini.isEmpty) {
    return 'n/d';
  }
  return movimento.ripartizioneCondomini.first.nominativo.trim().isEmpty
      ? movimento.ripartizioneCondomini.first.idCondomino
      : movimento.ripartizioneCondomini.first.nominativo;
}
