import 'dart:convert';
import 'dart:math' as math;

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:xml/xml.dart';

import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../home/application/home_navigation_provider.dart';
import '../../application/documents_ui_notifier.dart';
import '../../data/documents_repository_provider.dart';
import '../../domain/documento_download_model.dart';
import '../../domain/documento_archivio_model.dart';

Future<void> showDocumentsArchivioDialog({
  required BuildContext context,
  String? movimentoId,
  String? movimentoLabel,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => SelectionArea(
      child: _DocumentsArchivioDialog(
        movimentoId: movimentoId,
        movimentoLabel: movimentoLabel,
      ),
    ),
  );
}

class _DocumentsArchivioDialog extends ConsumerStatefulWidget {
  const _DocumentsArchivioDialog({
    required this.movimentoId,
    required this.movimentoLabel,
  });

  final String? movimentoId;
  final String? movimentoLabel;

  @override
  ConsumerState<_DocumentsArchivioDialog> createState() =>
      _DocumentsArchivioDialogState();
}

class _DocumentsArchivioDialogState
    extends ConsumerState<_DocumentsArchivioDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  DocumentoCategoria? _categoria;
  bool _includeAllVersions = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshServerSide() async {
    await ref
        .read(documentsDataProvider.notifier)
        .reloadDocumentiArchivio(includeAllVersions: _includeAllVersions);
  }

  Future<void> _uploadNewDocument() async {
    final picked = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossibile leggere il file selezionato. Riprova con un altro file.',
          ),
        ),
      );
      return;
    }
    if (!mounted) return;

    final metadata = await _showMetadataDialog(
      context: context,
      fileName: file.name,
      movimentoIdLocked: widget.movimentoId,
    );
    if (!mounted) return;
    if (metadata == null) return;

    try {
      await ref
          .read(documentsDataProvider.notifier)
          .uploadDocumentoArchivio(
            draft: DocumentoArchivioUploadDraft(
              categoria: metadata.categoria,
              fileName: file.name,
              bytes: bytes,
              contentType: file.extension == null
                  ? null
                  : _guessContentTypeFromExt(file.extension!),
              titolo: metadata.titolo,
              descrizione: metadata.descrizione,
              movimentoId: metadata.movimentoId,
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento caricato in archivio')),
      );
      await _refreshServerSide();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore upload: $e')));
    }
  }

  Future<void> _uploadNewVersion(DocumentoArchivioModel row) async {
    final picked = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) return;

    try {
      await ref
          .read(documentsDataProvider.notifier)
          .uploadNuovaVersioneDocumento(
            documentoId: row.id,
            fileName: file.name,
            bytes: bytes,
            contentType: file.extension == null
                ? null
                : _guessContentTypeFromExt(file.extension!),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nuova versione caricata')));
      await _refreshServerSide();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore versione: $e')));
    }
  }

  Future<void> _deleteDocument(DocumentoArchivioModel row) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina documento'),
        content: Text('Confermi eliminazione di "${row.titolo}"?'),
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
    if (confirm != true) return;

    try {
      await ref
          .read(documentsDataProvider.notifier)
          .deleteDocumentoArchivio(documentoId: row.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Documento eliminato')));
      await _refreshServerSide();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore eliminazione: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final allRows = ref.watch(documentiBySelectedCondominioProvider);
    final movimenti = ref.watch(movimentiBySelectedCondominioProvider);
    final isSaving = ref.watch(documentsIsSavingProvider);
    final isAdmin = ref.watch(homeIsAdminProvider);
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);
    final canManage = isAdmin && !isReadOnly;
    final movimentoLabelById = {
      for (final m in movimenti) m.id: '${m.codiceSpesa} - ${m.descrizione}',
    };

    final rows = allRows
        .where((item) {
          if (widget.movimentoId != null &&
              item.movimentoId != widget.movimentoId) {
            return false;
          }
          if (_categoria != null && item.categoria != _categoria) return false;
          final q = _searchCtrl.text.trim().toLowerCase();
          if (q.isEmpty) return true;
          return item.titolo.toLowerCase().contains(q) ||
              item.originalFileName.toLowerCase().contains(q) ||
              (item.descrizione ?? '').toLowerCase().contains(q);
        })
        .toList(growable: false);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.folder_open_outlined),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.movimentoId == null
                  ? 'Archivio documenti esercizio'
                  : 'Allegati movimento',
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 980,
        height: 620,
        child: Column(
          children: [
            if (widget.movimentoLabel != null &&
                widget.movimentoLabel!.trim().isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Movimento: ${widget.movimentoLabel}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Cerca per titolo, descrizione, nome file',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _refreshServerSide(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<DocumentoCategoria?>(
                  value: _categoria,
                  hint: const Text('Categoria'),
                  items: [
                    const DropdownMenuItem<DocumentoCategoria?>(
                      value: null,
                      child: Text('Tutte'),
                    ),
                    ...DocumentoCategoria.values.map(
                      (item) => DropdownMenuItem<DocumentoCategoria?>(
                        value: item,
                        child: Text(item.label),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _categoria = value),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Tutte le versioni'),
                  selected: _includeAllVersions,
                  onSelected: (value) async {
                    setState(() => _includeAllVersions = value);
                    await _refreshServerSide();
                  },
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: isSaving ? null : _refreshServerSide,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Aggiorna'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (canManage)
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: isSaving ? null : _uploadNewDocument,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Carica documento'),
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: rows.isEmpty
                  ? const Center(
                      child: Text(
                        'Nessun documento disponibile con i filtri attivi.',
                      ),
                    )
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        final subtitleParts = <String>[
                          row.originalFileName,
                          _formatSize(row.sizeBytes),
                          'v${row.versionNumber}',
                          _formatDateTime(row.createdAt),
                        ];
                        if (row.movimentoId != null) {
                          subtitleParts.add('movimento collegato');
                        }
                        return ListTile(
                          leading: const Icon(Icons.insert_drive_file_outlined),
                          title: Text(
                            row.titolo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subtitleParts.join(' • '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (row.movimentoId != null)
                                Text(
                                  'Collegato a: ${movimentoLabelById[row.movimentoId!] ?? row.movimentoId!}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if ((row.descrizione ?? '').trim().isNotEmpty)
                                Text(
                                  row.descrizione!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Anteprima',
                                onPressed: () => _openPreview(row),
                                icon: const Icon(Icons.preview_outlined),
                              ),
                              Chip(
                                label: Text(row.categoria.label),
                                visualDensity: VisualDensity.compact,
                              ),
                              if (canManage)
                                PopupMenuButton<String>(
                                  onSelected: (action) {
                                    if (action == 'newVersion') {
                                      _uploadNewVersion(row);
                                    } else if (action == 'delete') {
                                      _deleteDocument(row);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'newVersion',
                                      child: Text('Nuova versione'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Elimina'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }

  Future<void> _openPreview(DocumentoArchivioModel row) async {
    try {
      final payload = await ref
          .read(documentsDataProvider.notifier)
          .downloadDocumentoArchivio(documentoId: row.id);
      if (!mounted) return;
      await _showPreviewDialog(payload);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore preview: $e')));
    }
  }

  Future<void> _showPreviewDialog(DocumentoDownloadModel payload) {
    final contentType = payload.contentType.toLowerCase();
    final fileName = payload.fileName.toLowerCase();
    final isPdf = contentType.contains('pdf');
    final isImage = contentType.startsWith('image/');
    final isExcel =
        contentType.contains('spreadsheetml') ||
        contentType.contains('ms-excel') ||
        contentType.contains('macroenabled.12') ||
        fileName.endsWith('.xlsx') ||
        fileName.endsWith('.xls') ||
        fileName.endsWith('.xlsm') ||
        fileName.endsWith('.xltx') ||
        fileName.endsWith('.xltm');
    final isTextLike =
        contentType.startsWith('text/') ||
        contentType.contains('json') ||
        contentType.contains('xml') ||
        contentType.contains('csv');

    Widget previewBody;
    if (isPdf) {
      previewBody = PdfPreview(
        build: (_) async => payload.bytes,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: false,
        allowSharing: false,
      );
    } else if (isImage) {
      previewBody = InteractiveViewer(
        child: Center(child: Image.memory(payload.bytes, fit: BoxFit.contain)),
      );
    } else if (isExcel) {
      previewBody = _ExcelPreviewPane(
        bytes: payload.bytes,
        fileName: payload.fileName,
      );
    } else if (isTextLike) {
      final text = utf8.decode(payload.bytes, allowMalformed: true);
      previewBody = SingleChildScrollView(
        child: SelectionArea(child: Text(text)),
      );
    } else {
      previewBody = Center(
        child: Text(
          'Anteprima non disponibile per questo formato.\nTipo: ${payload.contentType}',
          textAlign: TextAlign.center,
        ),
      );
    }

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => SelectionArea(
        child: AlertDialog(
          title: Text('Anteprima - ${payload.fileName}'),
          content: SizedBox(width: 920, height: 680, child: previewBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExcelPreviewPane extends StatefulWidget {
  const _ExcelPreviewPane({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;

  @override
  State<_ExcelPreviewPane> createState() => _ExcelPreviewPaneState();
}

class _ExcelPreviewPaneState extends State<_ExcelPreviewPane> {
  static const int _maxPreviewRows = 250;
  static const int _maxPreviewCols = 35;

  final ScrollController _verticalScrollCtrl = ScrollController();
  final ScrollController _horizontalScrollCtrl = ScrollController();

  Excel? _workbook;
  List<String> _sheetNames = const [];
  String? _selectedSheetName;
  String? _loadError;
  String? _technicalDetails;
  bool _usedStylesCompat = false;

  @override
  void initState() {
    super.initState();
    _decodeWorkbook();
  }

  @override
  void dispose() {
    _verticalScrollCtrl.dispose();
    _horizontalScrollCtrl.dispose();
    super.dispose();
  }

  void _decodeWorkbook() {
    final lowerName = widget.fileName.toLowerCase();
    if (lowerName.endsWith('.xls')) {
      _loadError =
          'Il formato .xls (Excel legacy 97-2003) non e supportato in anteprima.\n'
          'Apri/scarica il file o convertilo in .xlsx.';
      _technicalDetails =
          'signature=${_detectFileSignature(widget.bytes).name}; first8=${_firstBytesHex(widget.bytes)}';
      return;
    }
    final signature = _detectFileSignature(widget.bytes);
    if (signature == _FileSignature.oleCompound) {
      _loadError =
          'Il file .xlsx sembra in formato cifrato/legacy non leggibile in anteprima.\n'
          'Apri/scarica il file o salvalo come .xlsx non protetto.';
      _technicalDetails =
          'signature=${signature.name}; first8=${_firstBytesHex(widget.bytes)}';
      return;
    }
    if (signature == _FileSignature.unknown) {
      _loadError =
          'Il contenuto del file non risulta un Excel .xlsx valido.\n'
          'Verifica il file originale o ricaricalo.';
      _technicalDetails =
          'signature=${signature.name}; first8=${_firstBytesHex(widget.bytes)}';
      return;
    }
    try {
      final decodeResult = _decodeWorkbookWithCompat(widget.bytes);
      final workbook = decodeResult.workbook;
      _usedStylesCompat = decodeResult.usedStylesCompat;
      final names = workbook.tables.keys.toList(growable: false);
      if (names.isEmpty) {
        _loadError = 'File Excel senza fogli leggibili.';
        return;
      }
      _workbook = workbook;
      _sheetNames = names;
      _selectedSheetName = names.first;
    } catch (e, st) {
      debugPrint('[DOCUMENTS][excelPreview] decode error: $e');
      debugPrint('[DOCUMENTS][excelPreview] stack: $st');
      _loadError =
          'Anteprima Excel non disponibile per questo file.\n'
          'Possibile file protetto/password, struttura non supportata o file corrotto.';
      _technicalDetails =
          'errorType=${e.runtimeType}; error=$e; first8=${_firstBytesHex(widget.bytes)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(_loadError!, textAlign: TextAlign.center),
              if ((_technicalDetails ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                SelectableText(
                  _technicalDetails!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF52606D),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(
                      ClipboardData(text: '${_loadError!}\n$_technicalDetails'),
                    );
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Dettaglio errore copiato')),
                    );
                  },
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('Copia dettaglio'),
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (_workbook == null ||
        _selectedSheetName == null ||
        !_workbook!.tables.containsKey(_selectedSheetName)) {
      return const Center(child: CircularProgressIndicator());
    }

    final sheet = _workbook!.tables[_selectedSheetName]!;
    final originalRows = sheet.rows;
    if (originalRows.isEmpty) {
      return Center(child: Text('Foglio "$_selectedSheetName" vuoto.'));
    }

    final previewRows = originalRows
        .take(_maxPreviewRows)
        .toList(growable: false);
    final computedCols = previewRows.fold<int>(
      0,
      (maxCols, row) => row.length > maxCols ? row.length : maxCols,
    );
    final previewCols = math.min(_maxPreviewCols, math.max(computedCols, 1));
    final hasTrimmedRows = originalRows.length > _maxPreviewRows;
    final hasTrimmedCols = computedCols > _maxPreviewCols;

    final firstRow = previewRows.first;
    final hasHeaderRow = firstRow.any(
      (cell) => _excelCellToText(cell?.value).trim().isNotEmpty,
    );
    final startDataIndex = hasHeaderRow ? 1 : 0;
    final visibleDataRows = previewRows
        .skip(startDataIndex)
        .toList(growable: false);

    final headers = List<String>.generate(previewCols, (index) {
      if (hasHeaderRow && index < firstRow.length) {
        final label = _excelCellToText(firstRow[index]?.value).trim();
        if (label.isNotEmpty) return label;
      }
      return 'Col ${_excelColumnLabel(index)}';
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: _selectedSheetName,
              items: _sheetNames
                  .map(
                    (name) => DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedSheetName = value);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasTrimmedRows || hasTrimmedCols)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Anteprima limitata a $_maxPreviewRows righe e $_maxPreviewCols colonne.',
              style: const TextStyle(color: Color(0xFF52606D)),
            ),
          ),
        if (_usedStylesCompat)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Compatibilita stili applicata per leggere il file (numFmt custom non standard).',
              style: TextStyle(color: Color(0xFF52606D), fontSize: 12),
            ),
          ),
        Expanded(
          child: Scrollbar(
            controller: _horizontalScrollCtrl,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollCtrl,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: headers.length * 170 + 78,
                ),
                child: Scrollbar(
                  controller: _verticalScrollCtrl,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalScrollCtrl,
                    child: DataTable(
                      showCheckboxColumn: false,
                      columnSpacing: 16,
                      horizontalMargin: 10,
                      dataRowMinHeight: 42,
                      dataRowMaxHeight: 62,
                      headingRowHeight: 46,
                      columns: <DataColumn>[
                        const DataColumn(
                          label: Text(
                            '#',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        ...headers.map(
                          (header) => DataColumn(
                            label: SizedBox(
                              width: 170,
                              child: Text(
                                header,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: List.generate(visibleDataRows.length, (index) {
                        final row = visibleDataRows[index];
                        final rowNumber = index + startDataIndex + 1;
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Text(
                                '$rowNumber',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            ...List.generate(previewCols, (columnIndex) {
                              final cellText = columnIndex < row.length
                                  ? _excelCellToText(row[columnIndex]?.value)
                                  : '';
                              return DataCell(
                                SizedBox(
                                  width: 170,
                                  child: SelectableText(
                                    cellText,
                                    maxLines: 2,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _excelCellToText(CellValue? value) {
  switch (value) {
    case null:
      return '';
    case TextCellValue():
      return value.value.toString().trim();
    case IntCellValue():
      return value.value.toString();
    case DoubleCellValue():
      final fixed = value.value.toStringAsFixed(6);
      return fixed
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    case BoolCellValue():
      return value.value ? 'TRUE' : 'FALSE';
    case FormulaCellValue():
      return value.formula;
    case DateCellValue():
      return _formatDateParts(value.day, value.month, value.year);
    case DateTimeCellValue():
      final datePart = _formatDateParts(value.day, value.month, value.year);
      final timePart = _formatTimeParts(value.hour, value.minute, value.second);
      return '$datePart $timePart';
    case TimeCellValue():
      return _formatTimeParts(value.hour, value.minute, value.second);
  }
}

String _excelColumnLabel(int index) {
  var n = index + 1;
  var label = '';
  while (n > 0) {
    final remainder = (n - 1) % 26;
    label = String.fromCharCode(65 + remainder) + label;
    n = (n - 1) ~/ 26;
  }
  return label;
}

String _formatDateParts(int day, int month, int year) {
  final dd = day.toString().padLeft(2, '0');
  final mm = month.toString().padLeft(2, '0');
  return '$dd/$mm/$year';
}

String _formatTimeParts(int hour, int minute, int second) {
  final hh = hour.toString().padLeft(2, '0');
  final mm = minute.toString().padLeft(2, '0');
  final ss = second.toString().padLeft(2, '0');
  return '$hh:$mm:$ss';
}

enum _FileSignature { zipOpenXml, oleCompound, unknown }

_FileSignature _detectFileSignature(Uint8List bytes) {
  if (bytes.length < 8) return _FileSignature.unknown;

  // ZIP magic: PK..
  if (bytes[0] == 0x50 && bytes[1] == 0x4B) {
    return _FileSignature.zipOpenXml;
  }

  // OLE CF magic (legacy Office binary, tipico .xls): D0 CF 11 E0 A1 B1 1A E1
  if (bytes[0] == 0xD0 &&
      bytes[1] == 0xCF &&
      bytes[2] == 0x11 &&
      bytes[3] == 0xE0 &&
      bytes[4] == 0xA1 &&
      bytes[5] == 0xB1 &&
      bytes[6] == 0x1A &&
      bytes[7] == 0xE1) {
    return _FileSignature.oleCompound;
  }

  return _FileSignature.unknown;
}

String _firstBytesHex(Uint8List bytes, {int max = 8}) {
  final length = math.min(bytes.length, max);
  final out = <String>[];
  for (var i = 0; i < length; i++) {
    out.add(bytes[i].toRadixString(16).padLeft(2, '0').toUpperCase());
  }
  return out.join(' ');
}

class _WorkbookDecodeResult {
  const _WorkbookDecodeResult({
    required this.workbook,
    required this.usedStylesCompat,
  });

  final Excel workbook;
  final bool usedStylesCompat;
}

_WorkbookDecodeResult _decodeWorkbookWithCompat(Uint8List bytes) {
  try {
    return _WorkbookDecodeResult(
      workbook: Excel.decodeBytes(bytes),
      usedStylesCompat: false,
    );
  } catch (e) {
    final message = e.toString();
    final hasNumFmtCompatIssue =
        message.contains('custom numFmtId starts at 164') ||
        message.contains('missing numFmt for');
    if (!hasNumFmtCompatIssue) rethrow;

    final normalized = _normalizeXlsxStylesInvalidCustomNumFmt(bytes);
    if (normalized == null) rethrow;
    return _WorkbookDecodeResult(
      workbook: Excel.decodeBytes(normalized),
      usedStylesCompat: true,
    );
  }
}

Uint8List? _normalizeXlsxStylesInvalidCustomNumFmt(Uint8List bytes) {
  try {
    final archive = ZipDecoder().decodeBytes(bytes, verify: false);
    ArchiveFile? stylesFile;
    for (final file in archive.files) {
      if (file.name == 'xl/styles.xml') {
        stylesFile = file;
        break;
      }
    }
    if (stylesFile == null) return null;

    final rawContent = stylesFile.content;
    if (rawContent is! List<int>) return null;
    final originalStylesXml = utf8.decode(rawContent, allowMalformed: true);
    final normalizedStylesXml = _normalizeStylesNumFmtForExcelPackage(
      originalStylesXml,
    );
    if (normalizedStylesXml == null ||
        normalizedStylesXml == originalStylesXml) {
      return null;
    }

    final patchedArchive = Archive()..comment = archive.comment;
    for (final file in archive.files) {
      final isStyles = identical(file, stylesFile);
      final fileBytes = isStyles
          ? utf8.encode(normalizedStylesXml)
          : (file.content is List<int>
                ? List<int>.from(file.content as List<int>)
                : null);
      if (fileBytes == null) return null;

      final newFile = ArchiveFile(file.name, fileBytes.length, fileBytes)
        ..comment = file.comment
        ..mode = file.mode
        ..ownerId = file.ownerId
        ..groupId = file.groupId
        ..lastModTime = file.lastModTime
        ..isFile = file.isFile
        ..isSymbolicLink = file.isSymbolicLink
        ..nameOfLinkedFile = file.nameOfLinkedFile
        ..compress = file.compress
        ..crc32 = file.crc32;
      patchedArchive.addFile(newFile);
    }

    final encoded = ZipEncoder().encode(patchedArchive);
    if (encoded == null) return null;
    return Uint8List.fromList(encoded);
  } catch (_) {
    return null;
  }
}

const Set<int> _excelPackageBuiltInNumFmtIds = <int>{
  0,
  1,
  2,
  3,
  4,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  37,
  38,
  39,
  40,
  45,
  46,
  47,
  48,
  49,
};

String? _normalizeStylesNumFmtForExcelPackage(String stylesXml) {
  try {
    final document = XmlDocument.parse(stylesXml);
    final numFmtNodes = document
        .findAllElements('numFmt')
        .toList(growable: false);
    final remappedCustomIds = <int, int>{};
    var changed = false;
    var nextCustomId = 164;

    for (final node in numFmtNodes) {
      final id = int.tryParse(node.getAttribute('numFmtId') ?? '');
      if (id != null && id >= 164 && id >= nextCustomId) {
        nextCustomId = id + 1;
      }
    }

    for (final node in numFmtNodes) {
      final attr = node.getAttribute('numFmtId');
      final id = int.tryParse(attr ?? '');
      if (id != null && id < 164) {
        final mapped = remappedCustomIds.putIfAbsent(id, () => nextCustomId++);
        node.setAttribute('numFmtId', '$mapped');
        changed = true;
      }
    }

    final customIds = <int>{};
    for (final node in numFmtNodes) {
      final id = int.tryParse(node.getAttribute('numFmtId') ?? '');
      if (id != null && id >= 164) {
        customIds.add(id);
      }
    }

    XmlElement? numFmtsElement;
    for (final node in document.findAllElements('numFmts')) {
      numFmtsElement = node;
      break;
    }
    if (numFmtsElement != null) {
      final count = numFmtsElement.findElements('numFmt').length;
      final countString = '$count';
      if (numFmtsElement.getAttribute('count') != countString) {
        numFmtsElement.setAttribute('count', countString);
        changed = true;
      }
    }

    // La libreria excel ha un sottoinsieme dei builtin: rimappiamo quelli non
    // supportati per evitare assert in parsing stile.
    for (final xf in document.findAllElements('xf')) {
      final currentId = int.tryParse(xf.getAttribute('numFmtId') ?? '');
      if (currentId == null) continue;

      if (remappedCustomIds.containsKey(currentId)) {
        xf.setAttribute('numFmtId', '${remappedCustomIds[currentId]}');
        changed = true;
        continue;
      }

      if (currentId < 164 &&
          !_excelPackageBuiltInNumFmtIds.contains(currentId)) {
        final fallback = currentId == 44 ? 4 : 0;
        xf.setAttribute('numFmtId', '$fallback');
        changed = true;
        continue;
      }

      if (currentId >= 164 && !customIds.contains(currentId)) {
        xf.setAttribute('numFmtId', '0');
        changed = true;
      }
    }
    return changed ? document.toXmlString(pretty: false) : null;
  } catch (_) {
    return null;
  }
}

class _DocumentoMetadataResult {
  const _DocumentoMetadataResult({
    required this.categoria,
    required this.titolo,
    required this.descrizione,
    required this.movimentoId,
  });

  final DocumentoCategoria categoria;
  final String titolo;
  final String? descrizione;
  final String? movimentoId;
}

Future<_DocumentoMetadataResult?> _showMetadataDialog({
  required BuildContext context,
  required String fileName,
  required String? movimentoIdLocked,
}) async {
  return showDialog<_DocumentoMetadataResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => SelectionArea(
      child: _DocumentoMetadataDialog(
        fileName: fileName,
        movimentoIdLocked: movimentoIdLocked,
      ),
    ),
  );
}

class _DocumentoMetadataDialog extends ConsumerStatefulWidget {
  const _DocumentoMetadataDialog({
    required this.fileName,
    required this.movimentoIdLocked,
  });

  final String fileName;
  final String? movimentoIdLocked;

  @override
  ConsumerState<_DocumentoMetadataDialog> createState() =>
      _DocumentoMetadataDialogState();
}

class _DocumentoMetadataDialogState
    extends ConsumerState<_DocumentoMetadataDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  DocumentoCategoria _categoria = DocumentoCategoria.altro;
  String? _movimentoId;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.fileName);
    _descCtrl = TextEditingController();
    _movimentoId = widget.movimentoIdLocked;
    if (widget.movimentoIdLocked != null) {
      _categoria = DocumentoCategoria.movimento;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movimenti = ref.watch(movimentiBySelectedCondominioProvider);
    final movementItems = movimenti
        .map(
          (m) => DropdownMenuItem<String?>(
            value: m.id,
            child: Text('${m.codiceSpesa} - ${m.descrizione}'),
          ),
        )
        .toList(growable: false);

    return AlertDialog(
      title: const Text('Metadati documento'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Titolo',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<DocumentoCategoria>(
              initialValue: _categoria,
              isDense: true,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: DocumentoCategoria.values
                  .map(
                    (item) => DropdownMenuItem<DocumentoCategoria>(
                      value: item,
                      child: Text(item.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _categoria = value);
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String?>(
              initialValue: _movimentoId,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'Collega a movimento (opzionale)',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Nessun collegamento'),
                ),
                ...movementItems,
              ],
              onChanged: widget.movimentoIdLocked != null
                  ? null
                  : (value) => setState(() => _movimentoId = value),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Descrizione',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleCtrl.text.trim();
            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inserisci un titolo documento')),
              );
              return;
            }
            Navigator.of(context).pop(
              _DocumentoMetadataResult(
                categoria: _categoria,
                titolo: title,
                descrizione: _descCtrl.text.trim().isEmpty
                    ? null
                    : _descCtrl.text.trim(),
                movimentoId: _movimentoId,
              ),
            );
          },
          child: const Text('Conferma'),
        ),
      ],
    );
  }
}

String _guessContentTypeFromExt(String ext) {
  switch (ext.trim().toLowerCase()) {
    case 'pdf':
      return 'application/pdf';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'webp':
      return 'image/webp';
    case 'txt':
      return 'text/plain';
    case 'csv':
      return 'text/csv';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    default:
      return 'application/octet-stream';
  }
}

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _formatDateTime(DateTime date) {
  final local = date.toLocal();
  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  final yyyy = local.year.toString();
  final hh = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  return '$dd/$mm/$yyyy $hh:$min';
}
