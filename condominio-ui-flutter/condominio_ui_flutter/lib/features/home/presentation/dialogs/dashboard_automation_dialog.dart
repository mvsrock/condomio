import 'package:flutter/material.dart';

import '../../../documents/data/documents_repository_provider.dart';
import '../../../jobs/domain/async_job_model.dart';

typedef QueueAutomaticSollecitiJob =
    Future<AsyncJobModel> Function(int minDaysOverdue);
typedef QueueReminderScadenzeJob =
    Future<AsyncJobModel> Function(int maxDaysAhead);
typedef ApplyRatePlanBulkCallback =
    Future<void> Function(List<RatePlanTemplateDraft> templates);

Future<void> showDashboardAutomationDialog({
  required BuildContext context,
  required QueueAutomaticSollecitiJob onQueueAutomaticSolleciti,
  required QueueReminderScadenzeJob onQueueReminderScadenze,
  required ApplyRatePlanBulkCallback onApplyRatePlan,
  required VoidCallback onOpenJobs,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DashboardAutomationDialog(
      onQueueAutomaticSolleciti: onQueueAutomaticSolleciti,
      onQueueReminderScadenze: onQueueReminderScadenze,
      onApplyRatePlan: onApplyRatePlan,
      onOpenJobs: onOpenJobs,
    ),
  );
}

class _DashboardAutomationDialog extends StatefulWidget {
  const _DashboardAutomationDialog({
    required this.onQueueAutomaticSolleciti,
    required this.onQueueReminderScadenze,
    required this.onApplyRatePlan,
    required this.onOpenJobs,
  });

  final QueueAutomaticSollecitiJob onQueueAutomaticSolleciti;
  final QueueReminderScadenzeJob onQueueReminderScadenze;
  final ApplyRatePlanBulkCallback onApplyRatePlan;
  final VoidCallback onOpenJobs;

  @override
  State<_DashboardAutomationDialog> createState() =>
      _DashboardAutomationDialogState();
}

class _DashboardAutomationDialogState
    extends State<_DashboardAutomationDialog> {
  bool _isWorking = false;
  final TextEditingController _sollecitiDaysCtrl = TextEditingController(
    text: '15',
  );
  final TextEditingController _reminderDaysCtrl = TextEditingController(
    text: '7',
  );
  final TextEditingController _csvCtrl = TextEditingController();
  List<_RatePlanCsvRow> _previewRows = const [];

  @override
  void dispose() {
    _sollecitiDaysCtrl.dispose();
    _reminderDaysCtrl.dispose();
    _csvCtrl.dispose();
    super.dispose();
  }

  Future<void> _queueSolleciti() async {
    if (_isWorking) return;
    final days = int.tryParse(_sollecitiDaysCtrl.text.trim()) ?? 0;
    setState(() => _isWorking = true);
    try {
      final job = await widget.onQueueAutomaticSolleciti(days);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auto-solleciti accodati (job #${_shortId(job.id)}).'),
          action: SnackBarAction(
            label: 'Coda job',
            onPressed: widget.onOpenJobs,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore auto-solleciti: $e')));
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _queueReminderScadenze() async {
    if (_isWorking) return;
    final days = int.tryParse(_reminderDaysCtrl.text.trim()) ?? 0;
    setState(() => _isWorking = true);
    try {
      final job = await widget.onQueueReminderScadenze(days);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reminder scadenze accodati (job #${_shortId(job.id)}).',
          ),
          action: SnackBarAction(
            label: 'Coda job',
            onPressed: widget.onOpenJobs,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore reminder: $e')));
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  void _loadCsvExample() {
    _csvCtrl.text = '''
codice;descrizione;tipo;scadenza;importoTotale
RATA-01;Rata gennaio;ORDINARIA;2026-01-31;1200
RATA-02;Rata febbraio;ORDINARIA;2026-02-28;1200
RATA-03;Rata straordinaria;STRAORDINARIA;2026-03-15;600
''';
  }

  void _previewCsv() {
    try {
      final rows = _parseCsv(_csvCtrl.text);
      setState(() => _previewRows = rows);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV valido: ${rows.length} righe pronte')),
      );
    } catch (e) {
      setState(() => _previewRows = const []);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV non valido: $e')));
    }
  }

  Future<void> _applyRatePlan() async {
    if (_isWorking) return;
    if (_previewRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prima valida il CSV da importare.')),
      );
      return;
    }
    setState(() => _isWorking = true);
    try {
      final templates = _previewRows
          .map(
            (row) => RatePlanTemplateDraft(
              codice: row.codice,
              descrizione: row.descrizione,
              tipo: row.tipo,
              scadenza: row.scadenza,
              importoTotale: row.importoTotale,
            ),
          )
          .toList(growable: false);
      await widget.onApplyRatePlan(templates);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Piano rate applicato su posizioni attive (${templates.length} template).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore applicazione piano: $e')));
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  List<_RatePlanCsvRow> _parseCsv(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      throw Exception('Incolla il contenuto CSV.');
    }
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (lines.isEmpty) {
      throw Exception('CSV vuoto.');
    }

    final delimiter = lines.first.contains(';') ? ';' : ',';
    final rows = <_RatePlanCsvRow>[];
    for (var i = 0; i < lines.length; i++) {
      final parts = lines[i]
          .split(delimiter)
          .map((p) => p.trim())
          .toList(growable: false);
      if (parts.length < 5) {
        throw Exception('Riga ${i + 1}: servono 5 colonne.');
      }
      if (i == 0 && parts[0].toLowerCase() == 'codice') {
        continue;
      }
      final codice = parts[0];
      final descrizione = parts[1];
      final tipo = _parseTipo(parts[2]);
      final scadenza = _parseDate(parts[3], rowNumber: i + 1);
      final importoTotale = _parseAmount(parts[4], rowNumber: i + 1);
      if (codice.isEmpty) {
        throw Exception('Riga ${i + 1}: codice mancante.');
      }
      rows.add(
        _RatePlanCsvRow(
          codice: codice,
          descrizione: descrizione,
          tipo: tipo,
          scadenza: scadenza,
          importoTotale: importoTotale,
        ),
      );
    }
    if (rows.isEmpty) {
      throw Exception('Nessuna riga utile trovata nel CSV.');
    }
    return rows;
  }

  String _parseTipo(String raw) {
    final value = raw.trim().toUpperCase();
    if (value == 'STRAORDINARIA') return 'STRAORDINARIA';
    return 'ORDINARIA';
  }

  DateTime _parseDate(String raw, {required int rowNumber}) {
    final value = raw.trim();
    if (value.isEmpty) {
      throw Exception('Riga $rowNumber: data scadenza mancante.');
    }
    final iso = DateTime.tryParse(value);
    if (iso != null) {
      return DateTime.utc(iso.year, iso.month, iso.day);
    }
    final slash = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$').firstMatch(value);
    if (slash != null) {
      final day = int.parse(slash.group(1)!);
      final month = int.parse(slash.group(2)!);
      final year = int.parse(slash.group(3)!);
      return DateTime.utc(year, month, day);
    }
    final dash = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(value);
    if (dash != null) {
      final day = int.parse(dash.group(1)!);
      final month = int.parse(dash.group(2)!);
      final year = int.parse(dash.group(3)!);
      return DateTime.utc(year, month, day);
    }
    throw Exception('Riga $rowNumber: data non valida ($value).');
  }

  double _parseAmount(String raw, {required int rowNumber}) {
    var value = raw.trim().replaceAll(' ', '');
    if (value.isEmpty) {
      throw Exception('Riga $rowNumber: importo totale mancante.');
    }
    if (value.contains(',') && value.contains('.')) {
      value = value.replaceAll('.', '').replaceAll(',', '.');
    } else if (value.contains(',') && !value.contains('.')) {
      value = value.replaceAll(',', '.');
    }
    final parsed = double.tryParse(value);
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      throw Exception('Riga $rowNumber: importo non valido ($raw).');
    }
    return parsed;
  }

  String _shortId(String value) {
    if (value.length <= 8) return value;
    return value.substring(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Automazioni e azioni massive'),
      content: SizedBox(
        width: 980,
        height: 700,
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
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Reminder e solleciti automatici',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: _reminderDaysCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Reminder gg',
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _isWorking ? null : _queueReminderScadenze,
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text('Accoda reminder'),
                  ),
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: _sollecitiDaysCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Solleciti gg',
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _isWorking ? null : _queueSolleciti,
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Accoda auto-solleciti'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isWorking ? null : widget.onOpenJobs,
                    icon: const Icon(Icons.work_history_outlined),
                    label: const Text('Apri coda job'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Import guidato piano rate (azioni massive)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'CSV atteso: codice;descrizione;tipo;scadenza;importoTotale',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _csvCtrl,
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Incolla qui il contenuto CSV...',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _isWorking ? null : _loadCsvExample,
                              icon: const Icon(Icons.tips_and_updates_outlined),
                              label: const Text('Carica esempio'),
                            ),
                            FilledButton.icon(
                              onPressed: _isWorking ? null : _previewCsv,
                              icon: const Icon(Icons.visibility_outlined),
                              label: const Text('Valida e anteprima'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _isWorking ? null : _applyRatePlan,
                              icon: const Icon(
                                Icons.playlist_add_check_circle_outlined,
                              ),
                              label: const Text('Applica piano rate'),
                            ),
                            if (_isWorking)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 420,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anteprima (${_previewRows.length} righe)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _previewRows.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Nessuna riga in anteprima.\nValida prima il CSV.',
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: _previewRows.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final row = _previewRows[index];
                                        return ListTile(
                                          dense: true,
                                          title: Text(row.codice),
                                          subtitle: Text(
                                            '${row.tipo} | ${row.scadenza.toIso8601String().substring(0, 10)}',
                                          ),
                                          trailing: Text(
                                            row.importoTotale.toStringAsFixed(
                                              2,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isWorking ? null : () => Navigator.of(context).pop(),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }
}

class _RatePlanCsvRow {
  const _RatePlanCsvRow({
    required this.codice,
    required this.descrizione,
    required this.tipo,
    required this.scadenza,
    required this.importoTotale,
  });

  final String codice;
  final String descrizione;
  final String tipo;
  final DateTime scadenza;
  final double importoTotale;
}
