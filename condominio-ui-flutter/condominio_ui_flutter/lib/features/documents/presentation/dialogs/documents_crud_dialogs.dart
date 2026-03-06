import 'package:flutter/material.dart';

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
    required this.descrizione,
    required this.importo,
  });

  final String codiceSpesa;
  final String descrizione;
  final double importo;
}

/// Payload form versamento usato dai dialog create/edit.
class DocumentsVersamentoFormResult {
  const DocumentsVersamentoFormResult({
    required this.descrizione,
    required this.importo,
  });

  final String descrizione;
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
  String initialCodiceSpesa = '',
  String initialDescrizione = '',
  double? initialImporto,
  bool lockToAvailableCodes = false,
}) async {
  final formKey = GlobalKey<FormState>();
  final codiceCtrl = TextEditingController(text: initialCodiceSpesa);
  final descrizioneCtrl = TextEditingController(text: initialDescrizione);
  final importoCtrl = TextEditingController(
    text: initialImporto == null ? '' : initialImporto.toStringAsFixed(2),
  );

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
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
  return DocumentsMovimentoFormResult(
    codiceSpesa: codiceCtrl.text.trim(),
    descrizione: descrizioneCtrl.text.trim(),
    importo: double.parse(importoCtrl.text.trim().replaceAll(',', '.')),
  );
}

Future<DocumentsVersamentoFormResult?> showDocumentsVersamentoFormDialog({
  required BuildContext context,
  required String title,
  required String confirmLabel,
  String initialDescrizione = '',
  double? initialImporto,
}) async {
  final formKey = GlobalKey<FormState>();
  final descrizioneCtrl = TextEditingController(text: initialDescrizione);
  final importoCtrl = TextEditingController(
    text: initialImporto == null ? '' : initialImporto.toStringAsFixed(2),
  );

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
