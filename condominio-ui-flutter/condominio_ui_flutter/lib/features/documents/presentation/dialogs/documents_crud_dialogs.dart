import 'package:flutter/material.dart';

import '../../domain/condomino_document_model.dart';
import '../../domain/movimento_model.dart';

/// Payload form tabella usato dai dialog create/edit.
class DocumentsTabellaFormResult {
  const DocumentsTabellaFormResult({
    required this.codice,
    required this.descrizione,
  });

  final String codice;
  final String descrizione;
}

/// Payload form movimento usato dai dialog create/edit spesa.
class DocumentsMovimentoFormResult {
  const DocumentsMovimentoFormResult({
    required this.codiceSpesa,
    required this.tipoRiparto,
    required this.descrizione,
    required this.importo,
    required this.ripartizioneCondomini,
  });

  final String codiceSpesa;
  final MovimentoRipartoTipo tipoRiparto;
  final String descrizione;
  final double importo;
  final List<DocumentsMovimentoRipartoCondominoForm> ripartizioneCondomini;
}

/// Riga input per spesa individuale (importo diretto per condomino).
class DocumentsMovimentoRipartoCondominoForm {
  const DocumentsMovimentoRipartoCondominoForm({
    required this.idCondomino,
    required this.nominativo,
    required this.importo,
  });

  final String idCondomino;
  final String nominativo;
  final double importo;
}

/// Payload form versamento usato dai dialog create/edit.
class DocumentsVersamentoFormResult {
  const DocumentsVersamentoFormResult({
    required this.descrizione,
    required this.importo,
    required this.rataId,
  });

  final String descrizione;
  final double importo;
  final String? rataId;
}

/// Payload form rata (ciclo rate/incassi).
class DocumentsRataFormResult {
  const DocumentsRataFormResult({
    required this.codice,
    required this.descrizione,
    required this.tipo,
    required this.scadenza,
    required this.importo,
  });

  final String codice;
  final String descrizione;
  final String tipo;
  final DateTime scadenza;
  final double importo;
}

/// Azione scelta quando si tenta di eliminare una tabella ancora in uso.
enum DocumentsLinkedTabellaAction { cancel, openConfig, autoCleanup }

Future<DocumentsTabellaFormResult?> showDocumentsTabellaFormDialog({
  required BuildContext context,
  required String title,
  required String confirmLabel,
  String initialCodice = '',
  String initialDescrizione = '',
}) async {
  final formKey = GlobalKey<FormState>();
  final codiceCtrl = TextEditingController(text: initialCodice);
  final descrizioneCtrl = TextEditingController(text: initialDescrizione);

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: codiceCtrl,
              decoration: const InputDecoration(labelText: 'Codice'),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descrizioneCtrl,
              decoration: const InputDecoration(labelText: 'Descrizione'),
              validator: _requiredValidator,
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
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  if (ok != true) return null;
  return DocumentsTabellaFormResult(
    codice: codiceCtrl.text.trim(),
    descrizione: descrizioneCtrl.text.trim(),
  );
}

Future<DocumentsMovimentoFormResult?> showDocumentsMovimentoFormDialog({
  required BuildContext context,
  required String title,
  required String confirmLabel,
  required List<String> spesaCodes,
  required List<CondominoDocumentModel> condomini,
  String initialCodiceSpesa = '',
  String initialDescrizione = '',
  double? initialImporto,
  MovimentoRipartoTipo initialTipoRiparto = MovimentoRipartoTipo.condominiale,
  List<DocumentsMovimentoRipartoCondominoForm> initialRipartizioneCondomini =
      const [],
  bool lockToAvailableCodes = false,
}) async {
  final formKey = GlobalKey<FormState>();
  final codiceCtrl = TextEditingController(text: initialCodiceSpesa);
  final descrizioneCtrl = TextEditingController(text: initialDescrizione);
  final importoCtrl = TextEditingController(
    text: initialImporto == null ? '' : initialImporto.toStringAsFixed(2),
  );
  MovimentoRipartoTipo tipoRiparto = initialTipoRiparto;
  String? ripartoError;
  String? selectedCondominoId = initialRipartizioneCondomini.isNotEmpty
      ? initialRipartizioneCondomini.first.idCondomino
      : null;

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (lockToAvailableCodes)
                  DropdownButtonFormField<String>(
                    initialValue: codiceCtrl.text.isEmpty ? null : codiceCtrl.text,
                    decoration: const InputDecoration(labelText: 'Codice spesa'),
                    items: spesaCodes
                        .map(
                          (codice) => DropdownMenuItem<String>(
                            value: codice,
                            child: Text(codice),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => codiceCtrl.text = value ?? '',
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Seleziona codice spesa'
                        : null,
                  )
                else
                  TextFormField(
                    controller: codiceCtrl,
                    decoration: const InputDecoration(labelText: 'Codice spesa'),
                    validator: _requiredValidator,
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MovimentoRipartoTipo>(
                  initialValue: tipoRiparto,
                  decoration: const InputDecoration(labelText: 'Tipo riparto'),
                  items: MovimentoRipartoTipo.values
                      .map(
                        (tipo) => DropdownMenuItem<MovimentoRipartoTipo>(
                          value: tipo,
                          child: Text(tipo.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      tipoRiparto = value;
                      ripartoError = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descrizioneCtrl,
                  decoration: const InputDecoration(labelText: 'Descrizione'),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: importoCtrl,
                  decoration: const InputDecoration(labelText: 'Importo'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _positiveDecimalValidator,
                ),
                if (tipoRiparto == MovimentoRipartoTipo.individuale) ...[
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Assegna la spesa a un solo condomino',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCondominoId,
                    decoration: const InputDecoration(
                      labelText: 'Condomino destinatario',
                    ),
                    items: condomini
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.nominativo),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      setState(() {
                        selectedCondominoId = value;
                        ripartoError = null;
                      });
                    },
                  ),
                  if (ripartoError != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        ripartoError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ],
            ),
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
              if (tipoRiparto == MovimentoRipartoTipo.individuale) {
                if (condomini.isEmpty) {
                  setState(() {
                    ripartoError = 'Nessun condomino disponibile.';
                  });
                  return;
                }
                if (selectedCondominoId == null || selectedCondominoId!.isEmpty) {
                  setState(() {
                    ripartoError = 'Seleziona un condomino.';
                  });
                  return;
                }
              }
              Navigator.of(context).pop(true);
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    ),
  );
  if (ok != true) return null;
  final importo = double.parse(importoCtrl.text.trim().replaceAll(',', '.'));
  final ripartizioneCondomini = tipoRiparto == MovimentoRipartoTipo.individuale
      ? (() {
          if (condomini.isEmpty) return const <DocumentsMovimentoRipartoCondominoForm>[];
          final selected = condomini.firstWhere(
            (c) => c.id == selectedCondominoId,
            orElse: () => condomini.first,
          );
          return <DocumentsMovimentoRipartoCondominoForm>[
            DocumentsMovimentoRipartoCondominoForm(
              idCondomino: selected.id,
              nominativo: selected.nominativo,
              importo: importo,
            ),
          ];
        })()
      : const <DocumentsMovimentoRipartoCondominoForm>[];
  return DocumentsMovimentoFormResult(
    codiceSpesa: codiceCtrl.text.trim(),
    tipoRiparto: tipoRiparto,
    descrizione: descrizioneCtrl.text.trim(),
    importo: importo,
    ripartizioneCondomini: ripartizioneCondomini,
  );
}

Future<DocumentsVersamentoFormResult?> showDocumentsVersamentoFormDialog({
  required BuildContext context,
  required String title,
  required String confirmLabel,
  List<DropdownMenuItem<String?>> rataItems = const [],
  String? initialRataId,
  String initialDescrizione = '',
  double? initialImporto,
}) async {
  final formKey = GlobalKey<FormState>();
  final descrizioneCtrl = TextEditingController(text: initialDescrizione);
  final importoCtrl = TextEditingController(
    text: initialImporto == null ? '' : initialImporto.toStringAsFixed(2),
  );
  String? selectedRataId = initialRataId;

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: descrizioneCtrl,
              decoration: const InputDecoration(labelText: 'Descrizione'),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: importoCtrl,
              decoration: const InputDecoration(labelText: 'Importo'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _positiveDecimalValidator,
            ),
            if (rataItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: selectedRataId,
                decoration: const InputDecoration(labelText: 'Rata (opzionale)'),
                items: rataItems,
                onChanged: (value) => selectedRataId = value,
              ),
            ],
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
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  if (ok != true) return null;
  return DocumentsVersamentoFormResult(
    descrizione: descrizioneCtrl.text.trim(),
    importo: double.parse(importoCtrl.text.trim().replaceAll(',', '.')),
    rataId: selectedRataId,
  );
}

Future<DocumentsRataFormResult?> showDocumentsRataFormDialog({
  required BuildContext context,
  required String title,
  required String confirmLabel,
  String initialCodice = '',
  String initialDescrizione = '',
  String initialTipo = 'ORDINARIA',
  DateTime? initialScadenza,
  double? initialImporto,
}) async {
  final formKey = GlobalKey<FormState>();
  final codiceCtrl = TextEditingController(text: initialCodice);
  final descrizioneCtrl = TextEditingController(text: initialDescrizione);
  final importoCtrl = TextEditingController(
    text: initialImporto == null ? '' : initialImporto.toStringAsFixed(2),
  );
  DateTime selectedDate = (initialScadenza ?? DateTime.now()).toLocal();
  String tipo = initialTipo;

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codiceCtrl,
                  decoration: const InputDecoration(labelText: 'Codice rata'),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descrizioneCtrl,
                  decoration: const InputDecoration(labelText: 'Descrizione'),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(value: 'ORDINARIA', child: Text('Ordinaria')),
                    DropdownMenuItem(value: 'STRAORDINARIA', child: Text('Straordinaria')),
                  ],
                  onChanged: (value) => tipo = value ?? 'ORDINARIA',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: importoCtrl,
                  decoration: const InputDecoration(labelText: 'Importo'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _positiveDecimalValidator,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Scadenza: ${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: const Text('Seleziona'),
                    ),
                  ],
                ),
              ],
            ),
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
            child: Text(confirmLabel),
          ),
        ],
      ),
    ),
  );
  if (ok != true) return null;
  return DocumentsRataFormResult(
    codice: codiceCtrl.text.trim(),
    descrizione: descrizioneCtrl.text.trim(),
    tipo: tipo,
    scadenza: DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).toUtc(),
    importo: double.parse(importoCtrl.text.trim().replaceAll(',', '.')),
  );
}

Future<bool> showDocumentsDeleteMovimentoDialog({
  required BuildContext context,
  required String descrizione,
}) async {
  return await _showDeleteConfirmDialog(
        context: context,
        title: 'Elimina spesa',
        content: 'Confermi eliminazione "$descrizione"?',
      ) ??
      false;
}

Future<bool> showDocumentsDeleteVersamentoDialog({
  required BuildContext context,
  required String descrizione,
  required double importo,
}) async {
  return await _showDeleteConfirmDialog(
        context: context,
        title: 'Elimina versamento',
        content:
            'Confermi eliminazione di "$descrizione" (${importo.toStringAsFixed(2)})?',
      ) ??
      false;
}

Future<bool> showDocumentsDeleteRataDialog({
  required BuildContext context,
  required String codice,
}) async {
  return await _showDeleteConfirmDialog(
        context: context,
        title: 'Elimina rata',
        content: 'Confermi eliminazione rata "$codice"?',
      ) ??
      false;
}

Future<bool> showDocumentsRenameTabellaInUseDialog({
  required BuildContext context,
  required String codiceTabella,
  required List<String> linkedCodes,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rinomina tabella in uso'),
          content: Text(
            'La tabella "$codiceTabella" e\' referenziata in:\n'
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
      ) ??
      false;
}

Future<DocumentsLinkedTabellaAction?> showDocumentsLinkedTabellaDialog({
  required BuildContext context,
  required String codiceTabella,
  required List<String> linkedCodes,
}) {
  return showDialog<DocumentsLinkedTabellaAction>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Tabella in uso'),
      content: Text(
        'La tabella "$codiceTabella" e\' usata nelle configurazioni spesa:\n'
        '${linkedCodes.join(', ')}\n\n'
        'Rimuovila prima da "Configura riparto".',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(DocumentsLinkedTabellaAction.cancel),
          child: const Text('Chiudi'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(DocumentsLinkedTabellaAction.autoCleanup),
          child: const Text('Rimuovi automaticamente'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(DocumentsLinkedTabellaAction.openConfig),
          child: const Text('Apri Configura riparto'),
        ),
      ],
    ),
  );
}

Future<bool> showDocumentsDeleteTabellaDialog({
  required BuildContext context,
  required String codiceTabella,
}) async {
  return await _showDeleteConfirmDialog(
        context: context,
        title: 'Elimina tabella',
        content:
            'Confermi eliminazione tabella "$codiceTabella"?\n'
            'Attenzione: le configurazioni spesa che la usano andranno aggiornate.',
      ) ??
      false;
}

Future<bool?> _showDeleteConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
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
}

String? _requiredValidator(String? value) {
  return (value == null || value.trim().isEmpty) ? 'Obbligatorio' : null;
}

String? _positiveDecimalValidator(String? value) {
  final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
  if (parsed == null || parsed <= 0) {
    return 'Importo non valido';
  }
  return null;
}
