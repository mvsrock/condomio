import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../home/application/home_navigation_provider.dart';
import '../../application/documents_ui_notifier.dart';
import '../../application/documents_view_providers.dart';
import '../../data/documents_repository_provider.dart';
import '../../domain/condominio_document_model.dart';
import '../../domain/condomino_document_model.dart';
import '../../domain/movimento_model.dart';
import '../../domain/tabella_model.dart';
import 'documents_common_widgets.dart';

typedef DocumentsMovimentoCallback =
    Future<void> Function(MovimentoModel movimento);
typedef DocumentsCondominoSelectCallback = void Function(String? condominoId);
typedef DocumentsCondominoQuoteDialogCallback =
    Future<void> Function(
      CondominoDocumentModel selectedCondomino,
      List<CondominoDocumentModel> allCondomini,
      List<TabellaModel> tabelle,
    );
typedef DocumentsCondominoActionCallback =
    Future<void> Function(CondominoDocumentModel selectedCondomino);
typedef DocumentsVersamentoCallback =
    Future<void> Function(
      CondominoDocumentModel selectedCondomino,
      VersamentoModel versamento,
    );
typedef DocumentsRataCallback =
    Future<void> Function(
      CondominoDocumentModel selectedCondomino,
      RataModel rata,
    );
typedef DocumentsTabellaCallback =
    Future<void> Function(
      CondominioDocumentModel? selectedCondominio,
      List<TabellaModel> tabelle,
      TabellaModel tabella,
    );

/// Pannello elenco condomini. Legge in autonomia lista e selezione correnti.
class DocumentsCondominiPanel extends ConsumerWidget {
  const DocumentsCondominiPanel({
    super.key,
    required this.onSelect,
    this.shrinkListForParentScroll = false,
  });

  final DocumentsCondominoSelectCallback onSelect;
  final bool shrinkListForParentScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condomini = ref.watch(condominiBySelectedCondominioProvider);
    final selectedCondominoId = ref.watch(
      documentsUiProvider.select((state) => state.selectedCondominoId),
    );

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
                    subtitle: Text(
                      'Scala ${item.scala} - Int ${item.interno} - ${item.isActivePosition ? 'attivo' : 'cessato'}',
                    ),
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
                      subtitle: Text(
                        'Scala ${item.scala} - Int ${item.interno} - ${item.isActivePosition ? 'attivo' : 'cessato'}',
                      ),
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
}

/// Pannello elenco movimenti + filtro testuale.
class DocumentsMovimentiPanel extends ConsumerWidget {
  const DocumentsMovimentiPanel({
    super.key,
    required this.onOpenMovimentoDetail,
    required this.onEditMovimento,
    required this.onDeleteMovimento,
    this.shrinkListForParentScroll = false,
  });

  final DocumentsMovimentoCallback onOpenMovimentoDetail;
  final DocumentsMovimentoCallback onEditMovimento;
  final DocumentsMovimentoCallback onDeleteMovimento;
  final bool shrinkListForParentScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movimenti = ref.watch(movimentiBySelectedCondominioProvider);
    final search = ref.watch(
      documentsUiProvider.select((state) => state.searchMovimenti),
    );
    final ui = ref.read(documentsUiProvider.notifier);
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);
    final isAdmin = ref.watch(homeIsAdminProvider);
    final isMutationBlocked = isReadOnly || !isAdmin;

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
            DocumentsMovimentiSearchField(
              value: search,
              onChanged: ui.setSearchMovimenti,
            ),
            const SizedBox(height: 10),
            if (shrinkListForParentScroll)
              ListView.separated(
                itemCount: movimenti.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final movimento = movimenti[index];
                  final individualLabel =
                      movimento.tipoRiparto == MovimentoRipartoTipo.individuale
                      ? ' - su ${_individualAssigneeLabel(movimento)}'
                      : '';
                  return ListTile(
                    dense: true,
                    title: Text(movimento.descrizione),
                    subtitle: Text(
                      'Codice ${movimento.codiceSpesa} - ${movimento.tipoRiparto.label}$individualLabel',
                    ),
                    onTap: () => onOpenMovimentoDetail(movimento),
                    trailing: DocumentsListTileActionsMenu(
                      amountText: movimento.importo.toStringAsFixed(2),
                      onEdit: isMutationBlocked
                          ? null
                          : () => onEditMovimento(movimento),
                      onDelete: isMutationBlocked
                          ? null
                          : () => onDeleteMovimento(movimento),
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
                    final movimento = movimenti[index];
                    final individualLabel =
                        movimento.tipoRiparto ==
                            MovimentoRipartoTipo.individuale
                        ? ' - su ${_individualAssigneeLabel(movimento)}'
                        : '';
                    return ListTile(
                      dense: true,
                      title: Text(movimento.descrizione),
                      subtitle: Text(
                        'Codice ${movimento.codiceSpesa} - ${movimento.tipoRiparto.label}$individualLabel',
                      ),
                      onTap: () => onOpenMovimentoDetail(movimento),
                      trailing: DocumentsListTileActionsMenu(
                        amountText: movimento.importo.toStringAsFixed(2),
                        onEdit: isMutationBlocked
                            ? null
                            : () => onEditMovimento(movimento),
                        onDelete: isMutationBlocked
                            ? null
                            : () => onDeleteMovimento(movimento),
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

/// Pannello desktop che mostra dettaglio condomino e tabelle del condominio.
class DocumentsDetailPanel extends ConsumerWidget {
  const DocumentsDetailPanel({
    super.key,
    required this.onOpenQuoteDialog,
    required this.onAddVersamento,
    required this.onEditVersamento,
    required this.onDeleteVersamento,
    required this.onAddRata,
    required this.onEditRata,
    required this.onDeleteRata,
    required this.onEditTabella,
    required this.onDeleteTabella,
  });

  final DocumentsCondominoQuoteDialogCallback onOpenQuoteDialog;
  final DocumentsCondominoActionCallback onAddVersamento;
  final DocumentsVersamentoCallback onEditVersamento;
  final DocumentsVersamentoCallback onDeleteVersamento;
  final DocumentsCondominoActionCallback onAddRata;
  final DocumentsRataCallback onEditRata;
  final DocumentsRataCallback onDeleteRata;
  final DocumentsTabellaCallback onEditTabella;
  final DocumentsTabellaCallback onDeleteTabella;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCondominio = ref.watch(selectedCondominioProvider);
    final selectedCondomino = ref.watch(selectedCondominoDocumentProvider);
    final condomini = ref.watch(condominiBySelectedCondominioProvider);
    final tabelle = ref.watch(tabelleBySelectedCondominioProvider);
    final quoteSpese = ref.watch(selectedCondominoQuoteSpeseProvider);
    final quoteByCodice = ref.watch(selectedCondominoQuoteByCodiceProvider);
    final versamenti = ref.watch(selectedCondominoVersamentiProvider);
    final rate = selectedCondomino?.config.rate ?? const <RataModel>[];
    final isSaving = ref.watch(
      documentsDataProvider.select((state) => state.isSaving),
    );
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);
    final isAdmin = ref.watch(homeIsAdminProvider);
    final isMutationBlocked = isReadOnly || !isAdmin;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
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
              else
                _DocumentsCondominoDetailContent(
                  selectedCondomino: selectedCondomino,
                  quoteSpese: quoteSpese,
                  quoteByCodice: quoteByCodice,
                  versamenti: versamenti,
                  rate: rate,
                  isSaving: isSaving,
                  isReadOnly: isMutationBlocked,
                  isActivePosition: selectedCondomino.isActivePosition,
                  showQuoteButton: true,
                  onOpenQuoteDialog: isMutationBlocked
                      ? null
                      : () => onOpenQuoteDialog(
                          selectedCondomino,
                          condomini,
                          tabelle,
                        ),
                  onAddVersamento: () => onAddVersamento(selectedCondomino),
                  onEditVersamento: (versamento) =>
                      onEditVersamento(selectedCondomino, versamento),
                  onDeleteVersamento: (versamento) =>
                      onDeleteVersamento(selectedCondomino, versamento),
                  onAddRata: () => onAddRata(selectedCondomino),
                  onEditRata: (rata) => onEditRata(selectedCondomino, rata),
                  onDeleteRata: (rata) => onDeleteRata(selectedCondomino, rata),
                ),
              const Text('Tabelle condominio'),
              const SizedBox(height: 6),
              ListView.separated(
                itemCount: tabelle.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tabella = tabelle[index];
                  return ListTile(
                    dense: true,
                    title: Text(tabella.codice),
                    subtitle: Text(tabella.descrizione),
                    trailing: DocumentsListTileActionsMenu(
                      amountText: '',
                      showAmount: false,
                      onEdit: isMutationBlocked
                          ? null
                          : () => onEditTabella(
                              selectedCondominio,
                              tabelle,
                              tabella,
                            ),
                      onDelete: isMutationBlocked
                          ? null
                          : () => onDeleteTabella(
                              selectedCondominio,
                              tabelle,
                              tabella,
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Contenuto riusabile del dettaglio condomino usato sia nel pannello desktop
/// sia nel bottom sheet mobile.
class DocumentsCondominoDetailSheetContent extends ConsumerWidget {
  const DocumentsCondominoDetailSheetContent({
    super.key,
    required this.condomino,
    required this.isSaving,
    required this.onAddVersamento,
    required this.onEditVersamento,
    required this.onDeleteVersamento,
    required this.onAddRata,
    required this.onEditRata,
    required this.onDeleteRata,
  });

  final CondominoDocumentModel condomino;
  final bool isSaving;
  final DocumentsCondominoActionCallback onAddVersamento;
  final DocumentsVersamentoCallback onEditVersamento;
  final DocumentsVersamentoCallback onDeleteVersamento;
  final DocumentsCondominoActionCallback onAddRata;
  final DocumentsRataCallback onEditRata;
  final DocumentsRataCallback onDeleteRata;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteSpese = ref.watch(
      documentsCondominoQuoteSpeseProvider(condomino.id),
    );
    final quoteByCodice = ref.watch(
      documentsCondominoQuoteByCodiceProvider(condomino.id),
    );
    final versamenti = ref.watch(
      documentsCondominoVersamentiProvider(condomino.id),
    );
    final rate = condomino.config.rate;
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);
    final isAdmin = ref.watch(homeIsAdminProvider);
    final isMutationBlocked = isReadOnly || !isAdmin;

    return _DocumentsCondominoDetailContent(
      selectedCondomino: condomino,
      quoteSpese: quoteSpese,
      quoteByCodice: quoteByCodice,
      versamenti: versamenti,
      rate: rate,
      isSaving: isSaving,
      isReadOnly: isMutationBlocked,
      isActivePosition: condomino.isActivePosition,
      showQuoteButton: false,
      onAddVersamento: () => onAddVersamento(condomino),
      onEditVersamento: (versamento) => onEditVersamento(condomino, versamento),
      onDeleteVersamento: (versamento) =>
          onDeleteVersamento(condomino, versamento),
      onAddRata: () => onAddRata(condomino),
      onEditRata: (rata) => onEditRata(condomino, rata),
      onDeleteRata: (rata) => onDeleteRata(condomino, rata),
    );
  }
}

class _DocumentsCondominoDetailContent extends StatelessWidget {
  const _DocumentsCondominoDetailContent({
    required this.selectedCondomino,
    required this.quoteSpese,
    required this.quoteByCodice,
    required this.versamenti,
    required this.rate,
    required this.isSaving,
    required this.isReadOnly,
    required this.isActivePosition,
    required this.showQuoteButton,
    required this.onAddVersamento,
    required this.onEditVersamento,
    required this.onDeleteVersamento,
    required this.onAddRata,
    required this.onEditRata,
    required this.onDeleteRata,
    this.onOpenQuoteDialog,
  });

  final CondominoDocumentModel selectedCondomino;
  final List<DocumentsCondominoQuotaSpesaRow> quoteSpese;
  final List<DocumentsCondominoQuotaByCodiceRow> quoteByCodice;
  final List<VersamentoModel> versamenti;
  final List<RataModel> rate;
  final bool isSaving;
  final bool isReadOnly;
  final bool isActivePosition;
  final bool showQuoteButton;
  final Future<void> Function()? onOpenQuoteDialog;
  final Future<void> Function() onAddVersamento;
  final Future<void> Function(VersamentoModel versamento) onEditVersamento;
  final Future<void> Function(VersamentoModel versamento) onDeleteVersamento;
  final Future<void> Function() onAddRata;
  final Future<void> Function(RataModel rata) onEditRata;
  final Future<void> Function(RataModel rata) onDeleteRata;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD9E2EC)),
          ),
          child: Text(
            selectedCondomino.hasStableProfile
                ? 'Quote, versamenti e residuo mostrati qui appartengono solo all\'esercizio corrente. Il profilo anagrafico del condomino resta condiviso tra gli esercizi collegati.'
                : 'Quote, versamenti e residuo mostrati qui appartengono solo all\'esercizio corrente.',
            style: const TextStyle(
              color: Color(0xFF334E68),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Riparto per spesa',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        if (quoteSpese.isEmpty)
          const Text('Nessuna quota spesa disponibile')
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              itemCount: quoteSpese.length,
              shrinkWrap: true,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final quota = quoteSpese[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${quota.codiceSpesa} - ${quota.descrizione}'),
                  subtitle: Text(
                    '${_formatDate(quota.data)} - ${quota.tipoRiparto.label} '
                    '(${quota.incidenzaPercentuale.toStringAsFixed(2)}%)',
                  ),
                  trailing: Text(quota.importo.toStringAsFixed(2)),
                  onTap: () => _showQuotaWhyDialog(
                    context: context,
                    quota: quota,
                    condomino: selectedCondomino,
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 10),
        const Text(
          'Totale per codice spesa',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        if (quoteByCodice.isEmpty)
          const Text('Nessun totale disponibile')
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              itemCount: quoteByCodice.length,
              shrinkWrap: true,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final quota = quoteByCodice[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(quota.codiceSpesa),
                  trailing: Text(
                    quota.importo.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                );
              },
            ),
          ),
        if (showQuoteButton) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: (onOpenQuoteDialog == null || !isActivePosition)
                ? null
                : () => onOpenQuoteDialog!(),
            icon: const Icon(Icons.tune_outlined),
            label: const Text('Modifica quote'),
          ),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: (isSaving || isReadOnly || !isActivePosition)
              ? null
              : onAddRata,
          icon: const Icon(Icons.event_note_outlined),
          label: const Text('Aggiungi rata'),
        ),
        const SizedBox(height: 10),
        const Text('Rate', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        if (rate.isEmpty)
          const Text('Nessuna rata configurata')
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              itemCount: rate.length,
              shrinkWrap: true,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final rata = rate[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${rata.codice} - ${rata.descrizione}'),
                  subtitle: Text(
                    '${rata.tipo} | ${_formatDate(rata.scadenza ?? DateTime.now())} | ${rata.stato}',
                  ),
                  trailing: isReadOnly || !isActivePosition
                      ? Text(
                          '${rata.incassato.toStringAsFixed(2)} / ${rata.importo.toStringAsFixed(2)}',
                        )
                      : PopupMenuButton<DocumentsRowAction>(
                          onSelected: (value) {
                            if (value == DocumentsRowAction.edit) {
                              onEditRata(rata);
                            } else {
                              onDeleteRata(rata);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: DocumentsRowAction.edit,
                              child: Text('Modifica'),
                            ),
                            PopupMenuItem(
                              value: DocumentsRowAction.delete,
                              child: Text('Elimina'),
                            ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${rata.incassato.toStringAsFixed(2)} / ${rata.importo.toStringAsFixed(2)}',
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: (isSaving || isReadOnly || !isActivePosition)
              ? null
              : onAddVersamento,
          icon: const Icon(Icons.payments_outlined),
          label: const Text('Aggiungi versamento'),
        ),
        const SizedBox(height: 10),
        const Text(
          'Storico versamenti',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        if (versamenti.isEmpty)
          const Text('Nessun versamento registrato')
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              itemCount: versamenti.length,
              shrinkWrap: true,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final versamento = versamenti[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    versamento.descrizione.isEmpty
                        ? 'Versamento'
                        : versamento.descrizione,
                  ),
                  subtitle: Text(
                    '${_formatDate(versamento.date)} - '
                    '${versamento.importo.toStringAsFixed(2)}',
                  ),
                  trailing: (isReadOnly || !isActivePosition)
                      ? null
                      : PopupMenuButton<DocumentsRowAction>(
                          onSelected: (value) {
                            if (value == DocumentsRowAction.edit) {
                              onEditVersamento(versamento);
                            } else {
                              onDeleteVersamento(versamento);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: DocumentsRowAction.edit,
                              child: Text('Modifica'),
                            ),
                            PopupMenuItem(
                              value: DocumentsRowAction.delete,
                              child: Text('Elimina'),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
      ],
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

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  final yyyy = local.year.toString();
  return '$dd/$mm/$yyyy';
}

Future<void> _showQuotaWhyDialog({
  required BuildContext context,
  required DocumentsCondominoQuotaSpesaRow quota,
  required CondominoDocumentModel condomino,
}) {
  const movementColor = Color(0xFF1D4ED8);
  const tableColor = Color(0xFFB45309);
  const milliColor = Color(0xFF374151);
  const finalColor = Color(0xFF047857);
  final computedShares = <double>[];
  final detailWidgets = <Widget>[];

  for (final table in quota.ripartizioneTabelle) {
    TabellaConfigModel? cfg;
    for (final item in condomino.config.tabelle) {
      if (item.codiceTabella.trim().toLowerCase() ==
          table.codice.trim().toLowerCase()) {
        cfg = item;
        break;
      }
    }
    final tablePercent = quota.importoMovimento == 0
        ? 0
        : (table.importo / quota.importoMovimento) * 100;
    if (cfg == null || cfg.denominatore == 0) {
      detailWidgets.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD9E2EC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                table.codice,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  style: const TextStyle(color: Color(0xFF111827)),
                  children: [
                    const TextSpan(text: '1) Quota tabella: '),
                    TextSpan(
                      text:
                          '${table.importo.toStringAsFixed(2)} (${tablePercent.toStringAsFixed(2)}%)',
                      style: const TextStyle(
                        color: tableColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '2) Millesimi condomino: non presenti su questa tabella',
              ),
              const Text.rich(
                TextSpan(
                  style: TextStyle(color: Color(0xFF111827)),
                  children: [
                    TextSpan(text: '3) Quota condomino su tabella: '),
                    TextSpan(
                      text: '0.00',
                      style: TextStyle(
                        color: finalColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      continue;
    }
    final percent = (cfg.numeratore / cfg.denominatore) * 100;
    final share = table.importo * (cfg.numeratore / cfg.denominatore);
    computedShares.add(share);
    detailWidgets.add(
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD9E2EC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              table.codice,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                style: const TextStyle(color: Color(0xFF111827)),
                children: [
                  const TextSpan(text: '1) Quota tabella: '),
                  TextSpan(
                    text:
                        '${table.importo.toStringAsFixed(2)} (= ${quota.importoMovimento.toStringAsFixed(2)} x ${tablePercent.toStringAsFixed(2)}%)',
                    style: const TextStyle(
                      color: tableColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                style: const TextStyle(color: Color(0xFF111827)),
                children: [
                  const TextSpan(text: '2) Millesimi condomino: '),
                  TextSpan(
                    text:
                        '${cfg.numeratore.toStringAsFixed(2)}/${cfg.denominatore.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: milliColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text: ' (quota personale registrata su questa tabella)',
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                style: const TextStyle(color: Color(0xFF111827)),
                children: [
                  const TextSpan(text: '3) Quota condomino su tabella: '),
                  TextSpan(
                    text: table.importo.toStringAsFixed(2),
                    style: const TextStyle(
                      color: tableColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' x '),
                  TextSpan(
                    text: cfg.numeratore.toStringAsFixed(2),
                    style: const TextStyle(
                      color: milliColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' / '),
                  TextSpan(
                    text: cfg.denominatore.toStringAsFixed(2),
                    style: const TextStyle(
                      color: milliColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' = '),
                  TextSpan(
                    text:
                        '${share.toStringAsFixed(2)} (${percent.toStringAsFixed(2)}%)',
                    style: const TextStyle(
                      color: finalColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  final computedTotal = computedShares.fold<double>(
    0,
    (sum, value) => sum + value,
  );
  final computedRounded = double.parse(computedTotal.toStringAsFixed(2));
  final delta = quota.importo - computedRounded;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Perche questa quota'),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Spesa: ${quota.codiceSpesa} - ${quota.descrizione}'),
                const SizedBox(height: 8),
                Text('Tipo riparto: ${quota.tipoRiparto.label}'),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(color: Color(0xFF111827)),
                    children: [
                      const TextSpan(text: 'Importo movimento: '),
                      TextSpan(
                        text: quota.importoMovimento.toStringAsFixed(2),
                        style: const TextStyle(
                          color: movementColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(color: Color(0xFF111827)),
                    children: [
                      TextSpan(
                        text: 'Quota attribuita a ${condomino.nominativo}: ',
                      ),
                      TextSpan(
                        text: quota.importo.toStringAsFixed(2),
                        style: const TextStyle(
                          color: finalColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Incidenza: ${quota.incidenzaPercentuale.toStringAsFixed(2)}%',
                ),
                const SizedBox(height: 10),
                if (quota.tipoRiparto == MovimentoRipartoTipo.individuale)
                  const Text(
                    'Riparto individuale: quota assegnata direttamente al condomino in fase di registrazione.',
                  )
                else ...[
                  const Text(
                    'Legenda numeri:',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    const TextSpan(
                      style: TextStyle(color: Color(0xFF111827)),
                      children: [
                        TextSpan(text: '- '),
                        TextSpan(
                          text: 'Quota tabella',
                          style: TextStyle(
                            color: tableColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                              ': valore preso dalla ripartizione del movimento su quella tabella.',
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    const TextSpan(
                      style: TextStyle(color: Color(0xFF111827)),
                      children: [
                        TextSpan(text: '- '),
                        TextSpan(
                          text: 'Millesimi',
                          style: TextStyle(
                            color: milliColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                              ': quota personale del condomino registrata per quella tabella.',
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    const TextSpan(
                      style: TextStyle(color: Color(0xFF111827)),
                      children: [
                        TextSpan(text: '- '),
                        TextSpan(
                          text: 'Quota condomino',
                          style: TextStyle(
                            color: finalColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                              ': risultato della formula quota tabella x millesimi.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Dettaglio tabelle (base di calcolo):',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  if (detailWidgets.isEmpty)
                    const Text('Nessuna tabella disponibile nel movimento.')
                  else
                    ...detailWidgets,
                  const SizedBox(height: 8),
                  Text(
                    'Somma quote tabella calcolata: ${computedRounded.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: finalColor,
                    ),
                  ),
                  Text(
                    'Quota salvata nel movimento: ${quota.importo.toStringAsFixed(2)}'
                    '${delta.abs() <= 0.0001 ? '' : ' (delta arrotondamento ${delta.toStringAsFixed(2)})'}',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nota: la quota salvata nel movimento e il valore contabile definitivo usato nei residui.',
                    style: TextStyle(color: Color(0xFF52606D)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Chiudi'),
        ),
      ],
    ),
  );
}
