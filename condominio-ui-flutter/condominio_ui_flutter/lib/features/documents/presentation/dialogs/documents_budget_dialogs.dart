import 'package:flutter/material.dart';

import '../../domain/preventivo_snapshot_model.dart';

class DocumentsPreventivoRowDraft {
  const DocumentsPreventivoRowDraft({
    required this.codiceSpesa,
    required this.codiceTabella,
    required this.descrizioneTabella,
    required this.preventivo,
  });

  final String codiceSpesa;
  final String codiceTabella;
  final String descrizioneTabella;
  final double preventivo;
}

class DocumentsPreventivoSaveResult {
  const DocumentsPreventivoSaveResult({required this.rows});

  final List<DocumentsPreventivoRowDraft> rows;
}

Future<DocumentsPreventivoSaveResult?> showDocumentsPreventivoDialog({
  required BuildContext context,
  required PreventivoSnapshotModel snapshot,
  required bool isReadOnly,
}) {
  return showDialog<DocumentsPreventivoSaveResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) =>
        _DocumentsPreventivoDialog(snapshot: snapshot, isReadOnly: isReadOnly),
  );
}

class _DocumentsPreventivoDialog extends StatefulWidget {
  const _DocumentsPreventivoDialog({
    required this.snapshot,
    required this.isReadOnly,
  });

  final PreventivoSnapshotModel snapshot;
  final bool isReadOnly;

  @override
  State<_DocumentsPreventivoDialog> createState() =>
      _DocumentsPreventivoDialogState();
}

class _DocumentsPreventivoDialogState
    extends State<_DocumentsPreventivoDialog> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.snapshot.rows
        .map(
          (row) =>
              TextEditingController(text: row.preventivo.toStringAsFixed(2)),
        )
        .toList(growable: false);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double _parseOrZero(String raw) {
    return double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
  }

  List<DocumentsPreventivoRowDraft>? _buildRowsOrShowError() {
    final rows = <DocumentsPreventivoRowDraft>[];
    for (var i = 0; i < widget.snapshot.rows.length; i++) {
      final model = widget.snapshot.rows[i];
      final value = _parseOrZero(_controllers[i].text);
      if (value < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Il preventivo non puo essere negativo'),
          ),
        );
        return null;
      }
      rows.add(
        DocumentsPreventivoRowDraft(
          codiceSpesa: model.codiceSpesa,
          codiceTabella: model.codiceTabella,
          descrizioneTabella: model.descrizioneTabella,
          preventivo: value,
        ),
      );
    }
    return rows;
  }

  double _totalPreventivoEditing() {
    var total = 0.0;
    for (final controller in _controllers) {
      total += _parseOrZero(controller.text);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.snapshot.rows;
    final consuntivo = widget.snapshot.totaleConsuntivo;
    final currentPreventivo = _totalPreventivoEditing();
    final delta = consuntivo - currentPreventivo;

    return AlertDialog(
      title: const Text('Preventivo e consuntivo'),
      content: SizedBox(
        width: 980,
        child: SelectionArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      'Preventivo ${currentPreventivo.toStringAsFixed(2)}',
                    ),
                  ),
                  Chip(
                    label: Text('Consuntivo ${consuntivo.toStringAsFixed(2)}'),
                  ),
                  Chip(label: Text('Delta ${delta.toStringAsFixed(2)}')),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Imposta il preventivo per ogni coppia codice spesa/tabella. '
                'Il consuntivo viene calcolato automaticamente dai movimenti.',
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 420,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 920),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Codice spesa')),
                          DataColumn(label: Text('Tabella')),
                          DataColumn(label: Text('Descrizione')),
                          DataColumn(label: Text('Preventivo')),
                          DataColumn(label: Text('Consuntivo')),
                          DataColumn(label: Text('Delta')),
                        ],
                        rows: [
                          for (var i = 0; i < rows.length; i++)
                            DataRow(
                              cells: [
                                DataCell(Text(rows[i].codiceSpesa)),
                                DataCell(Text(rows[i].codiceTabella)),
                                DataCell(Text(rows[i].descrizioneTabella)),
                                DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: _controllers[i],
                                      enabled: !widget.isReadOnly,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(rows[i].consuntivo.toStringAsFixed(2)),
                                ),
                                DataCell(
                                  Text(rows[i].delta.toStringAsFixed(2)),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Chiudi'),
        ),
        FilledButton(
          onPressed: widget.isReadOnly
              ? null
              : () {
                  final payload = _buildRowsOrShowError();
                  if (payload == null) return;
                  Navigator.of(
                    context,
                  ).pop(DocumentsPreventivoSaveResult(rows: payload));
                },
          child: const Text('Salva preventivo'),
        ),
      ],
    );
  }
}
