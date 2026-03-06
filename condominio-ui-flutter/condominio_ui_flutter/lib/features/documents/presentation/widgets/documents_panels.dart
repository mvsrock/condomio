import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../application/documents_ui_notifier.dart';
import '../../application/documents_view_providers.dart';
import '../../data/documents_repository_provider.dart';
import '../../domain/condominio_document_model.dart';
import '../../domain/condomino_document_model.dart';
import '../../domain/movimento_model.dart';
import '../../domain/tabella_model.dart';
import 'documents_common_widgets.dart';

typedef DocumentsMovimentoCallback = Future<void> Function(
  MovimentoModel movimento,
);
typedef DocumentsCondominoSelectCallback = void Function(String? condominoId);
typedef DocumentsCondominoQuoteDialogCallback = Future<void> Function(
  CondominoDocumentModel selectedCondomino,
  List<CondominoDocumentModel> allCondomini,
  List<TabellaModel> tabelle,
);
typedef DocumentsCondominoActionCallback = Future<void> Function(
  CondominoDocumentModel selectedCondomino,
);
typedef DocumentsVersamentoCallback = Future<void> Function(
  CondominoDocumentModel selectedCondomino,
  VersamentoModel versamento,
);
typedef DocumentsTabellaCallback = Future<void> Function(
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
                  return ListTile(
                    dense: true,
                    title: Text(movimento.descrizione),
                    subtitle: Text('Codice ${movimento.codiceSpesa}'),
                    onTap: () => onOpenMovimentoDetail(movimento),
                    trailing: DocumentsListTileActionsMenu(
                      amountText: movimento.importo.toStringAsFixed(2),
                      onEdit: isReadOnly
                          ? null
                          : () => onEditMovimento(movimento),
                      onDelete: isReadOnly
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
                    return ListTile(
                      dense: true,
                      title: Text(movimento.descrizione),
                      subtitle: Text('Codice ${movimento.codiceSpesa}'),
                      onTap: () => onOpenMovimentoDetail(movimento),
                      trailing: DocumentsListTileActionsMenu(
                        amountText: movimento.importo.toStringAsFixed(2),
                        onEdit: isReadOnly
                            ? null
                            : () => onEditMovimento(movimento),
                        onDelete: isReadOnly
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
    required this.onEditTabella,
    required this.onDeleteTabella,
  });

  final DocumentsCondominoQuoteDialogCallback onOpenQuoteDialog;
  final DocumentsCondominoActionCallback onAddVersamento;
  final DocumentsVersamentoCallback onEditVersamento;
  final DocumentsVersamentoCallback onDeleteVersamento;
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
    final isSaving = ref.watch(
      documentsDataProvider.select((state) => state.isSaving),
    );
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);

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
                  isSaving: isSaving,
                  isReadOnly: isReadOnly,
                  showQuoteButton: true,
                  onOpenQuoteDialog: isReadOnly
                      ? null
                      : () => onOpenQuoteDialog(
                          selectedCondomino,
                          condomini,
                          tabelle,
                        ),
                  onAddVersamento: () => onAddVersamento(selectedCondomino),
                  onEditVersamento: (versamento) => onEditVersamento(
                    selectedCondomino,
                    versamento,
                  ),
                  onDeleteVersamento: (versamento) => onDeleteVersamento(
                    selectedCondomino,
                    versamento,
                  ),
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
  });

  final CondominoDocumentModel condomino;
  final bool isSaving;
  final DocumentsCondominoActionCallback onAddVersamento;
  final DocumentsVersamentoCallback onEditVersamento;
  final DocumentsVersamentoCallback onDeleteVersamento;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteSpese = ref.watch(
      documentsCondominoQuoteSpeseProvider(condomino.id),
    );
    final quoteByCodice = ref.watch(
      documentsCondominoQuoteByCodiceProvider(condomino.id),
    );
    final versamenti = ref.watch(documentsCondominoVersamentiProvider(condomino.id));
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);

    return _DocumentsCondominoDetailContent(
      selectedCondomino: condomino,
      quoteSpese: quoteSpese,
      quoteByCodice: quoteByCodice,
      versamenti: versamenti,
      isSaving: isSaving,
      isReadOnly: isReadOnly,
      showQuoteButton: false,
      onAddVersamento: () => onAddVersamento(condomino),
      onEditVersamento: (versamento) => onEditVersamento(condomino, versamento),
      onDeleteVersamento: (versamento) => onDeleteVersamento(
        condomino,
        versamento,
      ),
    );
  }
}

class _DocumentsCondominoDetailContent extends StatelessWidget {
  const _DocumentsCondominoDetailContent({
    required this.selectedCondomino,
    required this.quoteSpese,
    required this.quoteByCodice,
    required this.versamenti,
    required this.isSaving,
    required this.isReadOnly,
    required this.showQuoteButton,
    required this.onAddVersamento,
    required this.onEditVersamento,
    required this.onDeleteVersamento,
    this.onOpenQuoteDialog,
  });

  final CondominoDocumentModel selectedCondomino;
  final List<DocumentsCondominoQuotaSpesaRow> quoteSpese;
  final List<DocumentsCondominoQuotaByCodiceRow> quoteByCodice;
  final List<VersamentoModel> versamenti;
  final bool isSaving;
  final bool isReadOnly;
  final bool showQuoteButton;
  final Future<void> Function()? onOpenQuoteDialog;
  final Future<void> Function() onAddVersamento;
  final Future<void> Function(VersamentoModel versamento) onEditVersamento;
  final Future<void> Function(VersamentoModel versamento) onDeleteVersamento;

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
                  subtitle: Text(_formatDate(quota.data)),
                  trailing: Text(quota.importo.toStringAsFixed(2)),
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
            onPressed: onOpenQuoteDialog == null ? null : () => onOpenQuoteDialog!(),
            icon: const Icon(Icons.tune_outlined),
            label: const Text('Modifica quote'),
          ),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: (isSaving || isReadOnly) ? null : onAddVersamento,
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
                  trailing: isReadOnly
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

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  final yyyy = local.year.toString();
  return '$dd/$mm/$yyyy';
}
