import 'package:flutter/material.dart';

import '../../domain/condomino_document_model.dart';
import '../../domain/morosita_item_model.dart';

typedef MorositaUpdateStatoCallback =
    Future<void> Function(MorositaItemModel item, MorositaStatoUi stato);
typedef MorositaAddSollecitoCallback =
    Future<void> Function(
      MorositaItemModel item,
      String canale,
      String titolo,
      String? note,
    );
typedef MorositaGenerateAutomaticCallback = Future<int> Function(int minDays);
typedef MorositaReloadItemsCallback =
    Future<List<MorositaItemModel>> Function();
typedef MorositaSollecitiMapReader =
    Map<String, List<SollecitoModel>> Function();

Future<void> showDocumentsMorositaDialog({
  required BuildContext context,
  required List<MorositaItemModel> items,
  required bool isSaving,
  required bool isReadOnly,
  required MorositaUpdateStatoCallback onUpdateStato,
  required MorositaAddSollecitoCallback onAddSollecito,
  required MorositaGenerateAutomaticCallback onGenerateAutomatic,
  required MorositaReloadItemsCallback onReloadItems,
  required MorositaSollecitiMapReader readSollecitiMap,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _DocumentsMorositaDialog(
      items: items,
      isSaving: isSaving,
      isReadOnly: isReadOnly,
      onUpdateStato: onUpdateStato,
      onAddSollecito: onAddSollecito,
      onGenerateAutomatic: onGenerateAutomatic,
      onReloadItems: onReloadItems,
      readSollecitiMap: readSollecitiMap,
    ),
  );
}

class _DocumentsMorositaDialog extends StatefulWidget {
  const _DocumentsMorositaDialog({
    required this.items,
    required this.isSaving,
    required this.isReadOnly,
    required this.onUpdateStato,
    required this.onAddSollecito,
    required this.onGenerateAutomatic,
    required this.onReloadItems,
    required this.readSollecitiMap,
  });

  final List<MorositaItemModel> items;
  final bool isSaving;
  final bool isReadOnly;
  final MorositaUpdateStatoCallback onUpdateStato;
  final MorositaAddSollecitoCallback onAddSollecito;
  final MorositaGenerateAutomaticCallback onGenerateAutomatic;
  final MorositaReloadItemsCallback onReloadItems;
  final MorositaSollecitiMapReader readSollecitiMap;

  @override
  State<_DocumentsMorositaDialog> createState() =>
      _DocumentsMorositaDialogState();
}

class _DocumentsMorositaDialogState extends State<_DocumentsMorositaDialog> {
  bool _isWorking = false;
  late List<MorositaItemModel> _rows;
  late Map<String, List<SollecitoModel>> _sollecitiMap;
  final Set<String> _expandedHistory = <String>{};

  @override
  void initState() {
    super.initState();
    _rows = List<MorositaItemModel>.from(widget.items, growable: false);
    _sollecitiMap = widget.readSollecitiMap();
  }

  @override
  void didUpdateWidget(covariant _DocumentsMorositaDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.items, widget.items)) {
      _rows = List<MorositaItemModel>.from(widget.items, growable: false);
    }
    _sollecitiMap = widget.readSollecitiMap();
  }

  String _money(double value) => 'EUR ${value.toStringAsFixed(2)}';

  Color _statusColor(BuildContext context, MorositaStatoUi stato) {
    switch (stato) {
      case MorositaStatoUi.sollecitato:
        return Colors.orange.shade700;
      case MorositaStatoUi.legale:
        return Colors.red.shade700;
      case MorositaStatoUi.inBonis:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _statusChip(BuildContext context, MorositaStatoUi stato) {
    final color = _statusColor(context, stato);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        stato.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _reloadRows() async {
    final latest = await widget.onReloadItems();
    if (!mounted) return;
    setState(() {
      _rows = List<MorositaItemModel>.from(latest, growable: false);
      _sollecitiMap = widget.readSollecitiMap();
    });
  }

  String _formatSollecitoDate(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final yyyy = local.year.toString();
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }

  Future<void> _changeStato(
    MorositaItemModel item,
    MorositaStatoUi stato,
  ) async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    try {
      await widget.onUpdateStato(item, stato);
      await _reloadRows();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stato aggiornato per ${item.nominativo}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore aggiornamento stato: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _openSollecitoForm(MorositaItemModel item) async {
    final canaleCtrl = TextEditingController(text: 'email');
    final titoloCtrl = TextEditingController(text: 'Sollecito pagamento');
    final noteCtrl = TextEditingController();
    try {
      final submit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Nuovo sollecito - ${item.nominativo}'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: canaleCtrl,
                  decoration: const InputDecoration(labelText: 'Canale'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titoloCtrl,
                  decoration: const InputDecoration(labelText: 'Titolo'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Note'),
                  minLines: 2,
                  maxLines: 4,
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
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Invia'),
            ),
          ],
        ),
      );
      if (submit != true || _isWorking) return;
      setState(() => _isWorking = true);
      try {
        await widget.onAddSollecito(
          item,
          canaleCtrl.text.trim(),
          titoloCtrl.text.trim(),
          noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        );
        if (item.praticaStato != MorositaStatoUi.legale) {
          await widget.onUpdateStato(item, MorositaStatoUi.sollecitato);
        }
        await _reloadRows();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sollecito registrato per ${item.nominativo}'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Errore invio sollecito: $e')));
        }
      } finally {
        if (mounted) setState(() => _isWorking = false);
      }
    } finally {
      canaleCtrl.dispose();
      titoloCtrl.dispose();
      noteCtrl.dispose();
    }
  }

  Future<void> _runAutomatic() async {
    if (_isWorking) return;
    final minDaysCtrl = TextEditingController(text: '15');
    try {
      final submit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Solleciti automatici'),
          content: SizedBox(
            width: 340,
            child: TextField(
              controller: minDaysCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giorni minimi di ritardo',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Genera'),
            ),
          ],
        ),
      );
      if (submit != true) return;
      final minDays = int.tryParse(minDaysCtrl.text.trim()) ?? 0;
      setState(() => _isWorking = true);
      try {
        final count = await widget.onGenerateAutomatic(minDays);
        await _reloadRows();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Solleciti automatici creati: $count')),
          );
        }
      } finally {
        if (mounted) setState(() => _isWorking = false);
      }
    } finally {
      minDaysCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final overdueCount = rows.where((item) => item.hasDebitoScaduto).length;
    final totalScaduto = rows.fold<double>(
      0,
      (sum, item) => sum + item.debitoScaduto,
    );
    final totalSolleciti = rows.fold<int>(
      0,
      (sum, item) => sum + item.numeroSolleciti,
    );
    final viewportWidth = MediaQuery.of(context).size.width;
    final dialogWidth = viewportWidth > 1280 ? 1120.0 : viewportWidth * 0.95;
    final canEdit = !widget.isReadOnly && !_isWorking;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.gavel_rounded),
          const SizedBox(width: 8),
          const Expanded(child: Text('Morosita e solleciti')),
          if (_isWorking)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MorositaSummaryCard(
                  label: 'Posizioni in mora',
                  value: '$overdueCount / ${rows.length}',
                  icon: Icons.people_alt_outlined,
                ),
                _MorositaSummaryCard(
                  label: 'Totale scaduto',
                  value: _money(totalScaduto),
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange.shade800,
                ),
                _MorositaSummaryCard(
                  label: 'Solleciti registrati',
                  value: '$totalSolleciti',
                  icon: Icons.mark_email_read_outlined,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Nota: "Registra sollecito" aggiunge una voce allo storico e imposta '
              'lo stato a "Sollecitato" (se non e gia "Legale").',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 470,
              child: rows.isEmpty
                  ? const Center(child: Text('Nessuna posizione disponibile'))
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = rows[index];
                        final statusColor = _statusColor(
                          context,
                          item.praticaStato,
                        );
                        final history =
                            _sollecitiMap[item.condominoId] ??
                            const <SollecitoModel>[];
                        final isExpanded = _expandedHistory.contains(
                          item.condominoId,
                        );
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.nominativo,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          _statusChip(
                                            context,
                                            item.praticaStato,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Debito scaduto',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          _money(item.debitoScaduto),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _MorositaMetricBadge(
                                      label: '0-30 gg',
                                      value: _money(item.scaduto0_30),
                                    ),
                                    _MorositaMetricBadge(
                                      label: '31-60 gg',
                                      value: _money(item.scaduto31_60),
                                    ),
                                    _MorositaMetricBadge(
                                      label: '61-90 gg',
                                      value: _money(item.scaduto61_90),
                                    ),
                                    _MorositaMetricBadge(
                                      label: '>90 gg',
                                      value: _money(item.scadutoOver90),
                                    ),
                                    _MorositaMetricBadge(
                                      label: 'Ritardo max',
                                      value: '${item.massimoRitardoGiorni} gg',
                                    ),
                                    _MorositaMetricBadge(
                                      label: 'Solleciti',
                                      value: '${history.length}',
                                    ),
                                  ],
                                ),
                                if (item.ultimoSollecitoAt != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ultimo sollecito: ${item.ultimoSollecitoAt!.toLocal()}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedHistory.remove(
                                          item.condominoId,
                                        );
                                      } else {
                                        _expandedHistory.add(item.condominoId);
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    isExpanded
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                  ),
                                  label: Text(
                                    'Storico solleciti (${history.length})',
                                  ),
                                ),
                                if (isExpanded) ...[
                                  const SizedBox(height: 8),
                                  if (history.isEmpty)
                                    Text(
                                      'Nessun sollecito registrato.',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 12,
                                      ),
                                    )
                                  else
                                    ...history.reversed.map(
                                      (sollecito) => Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    sollecito.titolo,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: sollecito.automatico
                                                        ? Colors.blue.shade50
                                                        : Colors.green.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    sollecito.automatico
                                                        ? 'Automatico'
                                                        : 'Manuale',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          sollecito.automatico
                                                          ? Colors.blue.shade800
                                                          : Colors
                                                                .green
                                                                .shade800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Canale: ${sollecito.canale} - '
                                              '${_formatSollecitoDate(sollecito.createdAt)}',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if ((sollecito.note ?? '')
                                                .trim()
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Note: ${sollecito.note!.trim()}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade800,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 240,
                                      ),
                                      child:
                                          DropdownButtonFormField<
                                            MorositaStatoUi
                                          >(
                                            initialValue: item.praticaStato,
                                            decoration: const InputDecoration(
                                              labelText: 'Stato pratica',
                                              isDense: true,
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: canEdit
                                                ? (next) {
                                                    if (next != null) {
                                                      _changeStato(item, next);
                                                    }
                                                  }
                                                : null,
                                            items: MorositaStatoUi.values
                                                .map(
                                                  (value) => DropdownMenuItem(
                                                    value: value,
                                                    child: Text(value.label),
                                                  ),
                                                )
                                                .toList(growable: false),
                                          ),
                                    ),
                                    FilledButton.icon(
                                      onPressed: canEdit
                                          ? () => _openSollecitoForm(item)
                                          : null,
                                      icon: const Icon(
                                        Icons.notification_add_outlined,
                                      ),
                                      label: const Text('Registra sollecito'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: canEdit ? _runAutomatic : null,
          icon: const Icon(Icons.auto_fix_high),
          label: const Text('Auto-solleciti'),
        ),
        TextButton(
          onPressed: _isWorking ? null : () => Navigator.of(context).pop(),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }
}

class _MorositaSummaryCard extends StatelessWidget {
  const _MorositaSummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      constraints: const BoxConstraints(minWidth: 220),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
                Text(
                  value,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MorositaMetricBadge extends StatelessWidget {
  const _MorositaMetricBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
