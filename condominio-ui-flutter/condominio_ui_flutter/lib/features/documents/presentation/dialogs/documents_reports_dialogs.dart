import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../platform/file_download.dart';
import '../../application/documents_ui_notifier.dart';
import '../../data/documents_repository_provider.dart';
import '../../domain/morosita_item_model.dart';
import '../../domain/report_snapshot_model.dart';

Future<void> showDocumentsReportsDialog({required BuildContext context}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const SelectionArea(child: _DocumentsReportsDialog()),
  );
}

class _DocumentsReportsDialog extends ConsumerStatefulWidget {
  const _DocumentsReportsDialog();

  @override
  ConsumerState<_DocumentsReportsDialog> createState() =>
      _DocumentsReportsDialogState();
}

class _DocumentsReportsDialogState extends ConsumerState<_DocumentsReportsDialog> {
  bool _isLoading = false;
  bool _isExporting = false;
  String? _selectedCondominoId;
  ReportSnapshotModel _snapshot = const ReportSnapshotModel.empty();

  @override
  void initState() {
    super.initState();
    // Se in pagina e' gia' selezionato un condomino, usa lo stesso filtro
    // nel report per mantenere coerenza tra:
    // - "Dettaglio + Tabelle" movimento
    // - modale report
    // - export PDF/XLSX.
    _selectedCondominoId = ref.read(
      documentsUiProvider.select((s) => s.selectedCondominoId),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await ref
          .read(documentsDataProvider.notifier)
          .fetchReportSnapshot(condominoId: _selectedCondominoId);
      if (!mounted) return;
      setState(() => _snapshot = snapshot);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore caricamento report: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _download(ReportExportFormat format) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final payload = await ref
          .read(documentsDataProvider.notifier)
          .downloadReportExport(
            format: format,
            condominoId: _selectedCondominoId,
          );
      final saved = await saveBytesToFile(
        bytes: payload.bytes,
        fileName: payload.fileName,
        contentType: payload.contentType,
      );
      if (!mounted) return;
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download annullato')),
        );
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File salvato: ${payload.fileName}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore export: $e')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  String _money(double value) => 'EUR ${value.toStringAsFixed(2)}';

  String _date(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final yyyy = local.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    final condomini = ref.watch(condominiBySelectedCondominioProvider);
    final quotaGroups = _buildQuotaGroups(
      _snapshot.quotaCondominoTabelle,
    );
    return AlertDialog(
      title: const Text('Report professionali'),
      content: SizedBox(
        width: 1120,
        height: 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 340,
                  child: DropdownButtonFormField<String?>(
                    isDense: true,
                    initialValue: _selectedCondominoId,
                    decoration: const InputDecoration(
                      labelText: 'Estratto conto posizione',
                    ),
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tutti i condomini'),
                      ),
                      ...condomini.map(
                        (row) => DropdownMenuItem<String?>(
                          value: row.id,
                          child: Text(row.nominativo),
                        ),
                      ),
                    ],
                    onChanged: _isLoading
                        ? null
                        : (value) async {
                            setState(() => _selectedCondominoId = value);
                            await _reload();
                          },
                  ),
                ),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _reload,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Aggiorna report'),
                ),
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : () => _download(ReportExportFormat.xlsx),
                  icon: const Icon(Icons.table_view_outlined),
                  label: const Text('Export XLSX'),
                ),
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : () => _download(ReportExportFormat.pdf),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Export PDF'),
                ),
                if (_isLoading || _isExporting) const CircularProgressIndicator(),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _snapshot.isEmpty
                  ? const Center(child: Text('Nessun dato report disponibile.'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedCondominoId == null) ...[
                            const _SectionCard(
                              title: 'Nota filtro condomino',
                              child: Text(
                                'Seleziona un condomino dal filtro in alto per vedere anche il dettaglio quota per tabella (es. 20 + 50 = 70) e riportarlo negli export.',
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          _SectionCard(
                            title: 'Situazione contabile',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _MetricChip(
                                  label: 'Saldo iniziale',
                                  value: _money(
                                    _snapshot
                                        .situazioneContabile
                                        .saldoInizialeCondominio,
                                  ),
                                ),
                                _MetricChip(
                                  label: 'Residuo condominio',
                                  value: _money(
                                    _snapshot.situazioneContabile.residuoCondominio,
                                  ),
                                ),
                                _MetricChip(
                                  label: 'Totale spese',
                                  value: _money(
                                    _snapshot
                                        .situazioneContabile
                                        .totaleSpeseRegistrate,
                                  ),
                                ),
                                _MetricChip(
                                  label: 'Totale versamenti',
                                  value: _money(
                                    _snapshot
                                        .situazioneContabile
                                        .totaleVersamenti,
                                  ),
                                ),
                                _MetricChip(
                                  label: 'Rate emesse',
                                  value: _money(
                                    _snapshot
                                        .situazioneContabile
                                        .totaleRateEmesse,
                                  ),
                                ),
                                _MetricChip(
                                  label: 'Rate incassate',
                                  value: _money(
                                    _snapshot
                                        .situazioneContabile
                                        .totaleRateIncassate,
                                  ),
                                ),
                                _MetricChip(
                                  label: 'Scoperto rate',
                                  value: _money(
                                    _snapshot
                                        .situazioneContabile
                                        .totaleScopertoRate,
                                  ),
                                ),
                                _MetricChip(
                                  label: 'Posizioni attive',
                                  value:
                                      '${_snapshot.situazioneContabile.posizioniAttive}',
                                ),
                                _MetricChip(
                                  label: 'Posizioni cessate',
                                  value:
                                      '${_snapshot.situazioneContabile.posizioniCessate}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            title:
                                'Consuntivo (preventivo vs consuntivo)',
                            child: _HorizontalTable(
                              columns: const [
                                'Spesa',
                                'Tabella',
                                'Descrizione',
                                'Preventivo',
                                'Consuntivo',
                                'Delta',
                              ],
                              rows: _snapshot.consuntivoRows
                                  .map(
                                    (row) => [
                                      row.codiceSpesa,
                                      row.codiceTabella,
                                      row.descrizioneTabella,
                                      _money(row.preventivo),
                                      _money(row.consuntivo),
                                      _money(row.delta),
                                    ],
                                  )
                                  .toList(growable: false),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            title: 'Riparto per tabella',
                            child: _HorizontalTable(
                              columns: const [
                                'Spesa',
                                'Tabella',
                                'Descrizione',
                                'Importo',
                              ],
                              rows: _snapshot.ripartoPerTabella
                                  .map(
                                    (row) => [
                                      row.codiceSpesa,
                                      row.codiceTabella,
                                      row.descrizioneTabella,
                                      _money(row.importoTotale),
                                    ],
                                  )
                                  .toList(growable: false),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            title: 'Morosita',
                            child: _HorizontalTable(
                              columns: const [
                                'Condomino',
                                'Stato',
                                'Debito totale',
                                'Debito scaduto',
                                'Solleciti',
                              ],
                              rows: _snapshot.morositaItems
                                  .map(
                                    (row) => [
                                      row.nominativo,
                                      row.praticaStato.label,
                                      _money(row.debitoTotale),
                                      _money(row.debitoScaduto),
                                      '${row.numeroSolleciti}',
                                    ],
                                  )
                                  .toList(growable: false),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            title: 'Estratti conto posizione',
                            child: _HorizontalTable(
                              columns: const [
                                'Condomino',
                                'Stato',
                                'Saldo iniziale',
                                'Residuo',
                                'Totale rate',
                                'Incassato rate',
                                'Scoperto rate',
                                'Versamenti',
                              ],
                              rows: _snapshot.estrattiConto
                                  .map(
                                    (row) => [
                                      row.nominativo,
                                      row.statoPosizione,
                                      _money(row.saldoIniziale),
                                      _money(row.residuo),
                                      _money(row.totaleRate),
                                      _money(row.totaleIncassatoRate),
                                      _money(row.scopertoRate),
                                      _money(row.totaleVersamenti),
                                    ],
                                  )
                                  .toList(growable: false),
                            ),
                          ),
                          if (_selectedCondominoId != null &&
                              _snapshot.quotaCondominoTabelle.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _SectionCard(
                              title: 'Dettaglio quota condomino per tabella',
                              child: _QuotaGroupsView(
                                groups: quotaGroups,
                                moneyFormatter: _money,
                                dateFormatter: _date,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SectionCard(
                              title: 'Totale per codice spesa (condomino selezionato)',
                              child: _HorizontalTable(
                                columns: const ['Codice spesa', 'Totale quota'],
                                rows: _totaleByCodiceRows(
                                  _snapshot.quotaCondominoTabelle,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading || _isExporting
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }

  List<List<String>> _totaleByCodiceRows(
    List<ReportQuotaCondominoTabellaRowModel> rows,
  ) {
    final totals = <String, double>{};
    final seenByMovimento = <String, double>{};
    for (final row in rows) {
      final keyMov = row.movimentoId.trim();
      final code = row.codiceSpesa.trim();
      if (code.isEmpty) continue;
      // Il totale per codice deve usare la quota movimento, una sola volta
      // per movimento (evita doppio conteggio con piu tabelle).
      if (keyMov.isNotEmpty && seenByMovimento.containsKey(keyMov)) continue;
      if (keyMov.isNotEmpty) {
        seenByMovimento[keyMov] = row.quotaCondominoMovimento;
      }
      totals[code] = (totals[code] ?? 0) + row.quotaCondominoMovimento;
    }
    final entries = totals.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map((e) => <String>[e.key, _money(e.value)])
        .toList(growable: false);
  }

  /// Raggruppa le righe tabellari per singolo movimento/spesa, assegnando
  /// un riferimento leggibile (M001, M002, ...) per evidenziare a colpo
  /// d'occhio che piu' righe appartengono alla stessa spesa.
  List<_QuotaMovimentoGroup> _buildQuotaGroups(
    List<ReportQuotaCondominoTabellaRowModel> rows,
  ) {
    final grouped = <String, List<ReportQuotaCondominoTabellaRowModel>>{};
    var fallbackCounter = 0;
    for (final row in rows) {
      final movimentoId = row.movimentoId.trim();
      final key = movimentoId.isNotEmpty
          ? movimentoId
          : 'fallback_${row.codiceSpesa}_${row.dataMovimento?.millisecondsSinceEpoch ?? 0}_${fallbackCounter++}';
      (grouped[key] ??= <ReportQuotaCondominoTabellaRowModel>[]).add(row);
    }

    final out = <_QuotaMovimentoGroup>[];
    var index = 1;
    grouped.forEach((key, values) {
      if (values.isEmpty) return;
      final first = values.first;
      final importoSpesa = values.fold<double>(
        0,
        (sum, row) => sum + row.importoTabella,
      );
      final quotaTabellaTotale = values.fold<double>(
        0,
        (sum, row) => sum + row.quotaCondominoTabella,
      );
      out.add(
        _QuotaMovimentoGroup(
          reference: 'M${index.toString().padLeft(3, '0')}',
          dataMovimento: first.dataMovimento,
          codiceSpesa: first.codiceSpesa,
          descrizioneMovimento: first.descrizioneMovimento,
          importoSpesa: _round2(importoSpesa),
          quotaCondominoMovimento: _round2(first.quotaCondominoMovimento),
          quotaCondominoTabellaTotale: _round2(quotaTabellaTotale),
          rows: values,
        ),
      );
      index++;
    });
    return out;
  }

  double _round2(double value) => (value * 100).roundToDouble() / 100;
}

class _QuotaMovimentoGroup {
  const _QuotaMovimentoGroup({
    required this.reference,
    required this.dataMovimento,
    required this.codiceSpesa,
    required this.descrizioneMovimento,
    required this.importoSpesa,
    required this.quotaCondominoMovimento,
    required this.quotaCondominoTabellaTotale,
    required this.rows,
  });

  final String reference;
  final DateTime? dataMovimento;
  final String codiceSpesa;
  final String descrizioneMovimento;
  final double importoSpesa;
  final double quotaCondominoMovimento;
  final double quotaCondominoTabellaTotale;
  final List<ReportQuotaCondominoTabellaRowModel> rows;

  bool get isBalanced =>
      (quotaCondominoTabellaTotale - quotaCondominoMovimento).abs() < 0.01;
}

class _QuotaGroupsView extends StatelessWidget {
  const _QuotaGroupsView({
    required this.groups,
    required this.moneyFormatter,
    required this.dateFormatter,
  });

  final List<_QuotaMovimentoGroup> groups;
  final String Function(double value) moneyFormatter;
  final String Function(DateTime? value) dateFormatter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.asMap().entries.map((entry) {
        final idx = entry.key;
        final group = entry.value;
        final bg = idx.isEven
            ? const Color(0xFFF8FAFC)
            : const Color(0xFFFFFFFF);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text('Rif. spesa ${group.reference}'),
                  ),
                  Text(
                    dateFormatter(group.dataMovimento),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SelectableText(
                    group.codiceSpesa,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (group.descrizioneMovimento.trim().isNotEmpty)
                    SelectableText(group.descrizioneMovimento),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  SelectableText(
                    'Importo spesa: ${moneyFormatter(group.importoSpesa)}',
                  ),
                  SelectableText(
                    'Quota condomino: ${moneyFormatter(group.quotaCondominoMovimento)}',
                  ),
                  SelectableText(
                    group.isBalanced
                        ? 'Quadratura: OK'
                        : 'Quadratura: differenza ${moneyFormatter((group.quotaCondominoTabellaTotale - group.quotaCondominoMovimento).abs())}',
                    style: TextStyle(
                      color: group.isBalanced
                          ? const Color(0xFF15803D)
                          : const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _HorizontalTable(
                columns: const [
                  'Tabella',
                  'Quota tabella',
                  'Millesimi',
                  'Quota condomino tabella',
                ],
                rows: group.rows
                    .map(
                      (row) => [
                        row.codiceTabella,
                        moneyFormatter(row.importoTabella),
                        '${row.numeratore.toStringAsFixed(2)}/${row.denominatore.toStringAsFixed(2)}',
                        moneyFormatter(row.quotaCondominoTabella),
                      ],
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD9E2EC)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HorizontalTable extends StatelessWidget {
  const _HorizontalTable({required this.columns, required this.rows});

  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns
            .map((label) => DataColumn(label: Text(label)))
            .toList(growable: false),
        rows: rows
            .map(
              (row) => DataRow(
                cells: row
                    .map((value) => DataCell(SelectableText(value)))
                    .toList(growable: false),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
