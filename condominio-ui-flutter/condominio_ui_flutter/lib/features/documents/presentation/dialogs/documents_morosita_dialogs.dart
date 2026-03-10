import 'package:flutter/material.dart';

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

Future<void> showDocumentsMorositaDialog({
  required BuildContext context,
  required List<MorositaItemModel> items,
  required bool isSaving,
  required bool isReadOnly,
  required MorositaUpdateStatoCallback onUpdateStato,
  required MorositaAddSollecitoCallback onAddSollecito,
  required MorositaGenerateAutomaticCallback onGenerateAutomatic,
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
  });

  final List<MorositaItemModel> items;
  final bool isSaving;
  final bool isReadOnly;
  final MorositaUpdateStatoCallback onUpdateStato;
  final MorositaAddSollecitoCallback onAddSollecito;
  final MorositaGenerateAutomaticCallback onGenerateAutomatic;

  @override
  State<_DocumentsMorositaDialog> createState() =>
      _DocumentsMorositaDialogState();
}

class _DocumentsMorositaDialogState extends State<_DocumentsMorositaDialog> {
  bool _isWorking = false;

  Future<void> _changeStato(
    MorositaItemModel item,
    MorositaStatoUi stato,
  ) async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    try {
      await widget.onUpdateStato(item, stato);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stato aggiornato per ${item.nominativo}')),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sollecito registrato per ${item.nominativo}'),
            ),
          );
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
    final rows = widget.items;
    final totalScaduto = rows.fold<double>(
      0,
      (sum, item) => sum + item.debitoScaduto,
    );
    return AlertDialog(
      title: const Text('Morosita e solleciti'),
      content: SizedBox(
        width: 1120,
        child: SelectionArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Posizioni con debito scaduto: '
                '${rows.where((item) => item.hasDebitoScaduto).length}/${rows.length} '
                '- Totale scaduto ${totalScaduto.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 460,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 1100),
                    child: ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = rows[index];
                        return ListTile(
                          dense: true,
                          title: Text(item.nominativo),
                          subtitle: Text(
                            'Scaduto ${item.debitoScaduto.toStringAsFixed(2)} | '
                            '0-30 ${item.scaduto0_30.toStringAsFixed(2)} | '
                            '31-60 ${item.scaduto31_60.toStringAsFixed(2)} | '
                            '61-90 ${item.scaduto61_90.toStringAsFixed(2)} | '
                            '>90 ${item.scadutoOver90.toStringAsFixed(2)} | '
                            'Ritardo max ${item.massimoRitardoGiorni} gg',
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              DropdownButton<MorositaStatoUi>(
                                value: item.praticaStato,
                                onChanged: widget.isReadOnly || _isWorking
                                    ? null
                                    : (next) {
                                        if (next != null) {
                                          _changeStato(item, next);
                                        }
                                      },
                                items: MorositaStatoUi.values
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value.label),
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                              TextButton(
                                onPressed: widget.isReadOnly || _isWorking
                                    ? null
                                    : () => _openSollecitoForm(item),
                                child: const Text('Sollecita'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: widget.isReadOnly || _isWorking ? null : _runAutomatic,
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
