import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../platform/file_download.dart';
import '../../application/portal_notifier.dart';
import '../../domain/portal_snapshot_model.dart';

class PortalPage extends ConsumerStatefulWidget {
  const PortalPage({super.key});

  @override
  ConsumerState<PortalPage> createState() => _PortalPageState();
}

class _PortalPageState extends ConsumerState<PortalPage> {
  bool _isDownloading = false;

  String _money(double value) => 'EUR ${value.toStringAsFixed(2)}';

  String _date(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final yyyy = local.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _downloadDocumento(String documentoId) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final payload = await ref
          .read(portalNotifierProvider.notifier)
          .downloadDocumento(documentoId: documentoId);
      final saved = await saveBytesToFile(
        bytes: payload.bytes,
        fileName: payload.fileName,
        contentType: payload.contentType,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saved ? 'File salvato: ${payload.fileName}' : 'Download annullato'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore download documento: $e')));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(portalSnapshotProvider);
    final isLoading = ref.watch(portalIsLoadingProvider);
    final error = ref.watch(portalErrorProvider);
    final isWide = MediaQuery.of(context).size.width >= 1120;
    final totaleQuoteSpese = snapshot.movimenti.fold<double>(
      0,
      (sum, row) => sum + row.quotaCondomino,
    );

    if (isLoading && snapshot.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Portale Condomino',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  snapshot.isEmpty
                      ? 'Nessun dato disponibile per l\'esercizio selezionato.'
                      : '${snapshot.labelCondominio} - ${snapshot.gestioneLabel} ${snapshot.anno}',
                  style: const TextStyle(color: Color(0xFFE0F2FE)),
                ),
                if (!snapshot.isEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${snapshot.nominativo} - ruolo ${snapshot.appRole} - posizione ${snapshot.statoPosizione}',
                    style: const TextStyle(color: Color(0xFFCFFAFE)),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: isLoading
                          ? null
                          : () => ref
                                .read(portalNotifierProvider.notifier)
                                .loadForSelectedCondominio(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Aggiorna dati'),
                    ),
                    if (isLoading) const CircularProgressIndicator(),
                    if (_isDownloading) const CircularProgressIndicator(),
                  ],
                ),
              ],
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFFFEF2F2),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  error,
                  style: const TextStyle(color: Color(0xFF991B1B)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final columns = constraints.maxWidth < 760
                  ? 1
                  : (constraints.maxWidth < 1180 ? 2 : 4);
              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _PortalStatCard(
                    width: cardWidth,
                    title: 'Residuo personale',
                    value: _money(snapshot.residuoCondomino),
                    subtitle: 'Saldo iniziale ${_money(snapshot.saldoInizialeCondomino)}',
                    color: const Color(0xFF1D4ED8),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  _PortalStatCard(
                    width: cardWidth,
                    title: 'Scoperto rate',
                    value: _money(snapshot.scopertoRate),
                    subtitle:
                        'Rate ${_money(snapshot.totaleRate)} - Incassato ${_money(snapshot.totaleIncassatoRate)}',
                    color: const Color(0xFFB45309),
                    icon: Icons.event_busy_outlined,
                  ),
                  _PortalStatCard(
                    width: cardWidth,
                    title: 'Versamenti',
                    value: _money(snapshot.totaleVersamenti),
                    subtitle: '${snapshot.versamenti.length} registrazioni',
                    color: const Color(0xFF047857),
                    icon: Icons.payments_outlined,
                  ),
                  _PortalStatCard(
                    width: cardWidth,
                    title: 'Spese imputate',
                    value: _money(totaleQuoteSpese),
                    subtitle: '${snapshot.movimenti.length} movimenti',
                    color: const Color(0xFF7C3AED),
                    icon: Icons.receipt_long_outlined,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _RateSection(snapshot: snapshot, money: _money, date: _date),
                      const SizedBox(height: 12),
                      _VersamentiSection(
                        snapshot: snapshot,
                        money: _money,
                        date: _date,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _MovimentiSection(
                        snapshot: snapshot,
                        money: _money,
                        date: _date,
                      ),
                      const SizedBox(height: 12),
                      _DocumentiSection(
                        snapshot: snapshot,
                        date: _date,
                        onDownload: _downloadDocumento,
                      ),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _RateSection(snapshot: snapshot, money: _money, date: _date),
            const SizedBox(height: 12),
            _VersamentiSection(snapshot: snapshot, money: _money, date: _date),
            const SizedBox(height: 12),
            _MovimentiSection(snapshot: snapshot, money: _money, date: _date),
            const SizedBox(height: 12),
            _DocumentiSection(
              snapshot: snapshot,
              date: _date,
              onDownload: _downloadDocumento,
            ),
          ],
        ],
      ),
    );
  }
}

class _PortalStatCard extends StatelessWidget {
  const _PortalStatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _RateSection extends StatelessWidget {
  const _RateSection({
    required this.snapshot,
    required this.money,
    required this.date,
  });

  final PortalSnapshotModel snapshot;
  final String Function(double value) money;
  final String Function(DateTime? value) date;

  @override
  Widget build(BuildContext context) {
    if (snapshot.rate.isEmpty) {
      return const _SectionCard(
        title: 'Rate',
        child: Text('Nessuna rata disponibile.'),
      );
    }
    return _SectionCard(
      title: 'Rate',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Codice')),
            DataColumn(label: Text('Descrizione')),
            DataColumn(label: Text('Scadenza')),
            DataColumn(label: Text('Stato')),
            DataColumn(label: Text('Importo')),
            DataColumn(label: Text('Incassato')),
            DataColumn(label: Text('Scoperto')),
          ],
          rows: snapshot.rate
              .map(
                (row) => DataRow(
                  cells: [
                    DataCell(SelectableText(row.codice)),
                    DataCell(SelectableText(row.descrizione)),
                    DataCell(
                      SelectableText(date(DateTime.tryParse(row.scadenzaIso))),
                    ),
                    DataCell(SelectableText(row.stato)),
                    DataCell(SelectableText(money(row.importo))),
                    DataCell(SelectableText(money(row.incassato))),
                    DataCell(SelectableText(money(row.scoperto))),
                  ],
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _VersamentiSection extends StatelessWidget {
  const _VersamentiSection({
    required this.snapshot,
    required this.money,
    required this.date,
  });

  final PortalSnapshotModel snapshot;
  final String Function(double value) money;
  final String Function(DateTime? value) date;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Ultimi versamenti',
      child: snapshot.versamenti.isEmpty
          ? const Text('Nessun versamento registrato.')
          : Column(
              children: snapshot.versamenti
                  .map(
                    (row) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        row.descrizione.isEmpty ? 'Versamento' : row.descrizione,
                      ),
                      subtitle: Text(
                        '${date(row.date)}${row.rataId != null && row.rataId!.isNotEmpty ? ' - rata ${row.rataId}' : ''}',
                      ),
                      trailing: Text(money(row.importo)),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _MovimentiSection extends StatelessWidget {
  const _MovimentiSection({
    required this.snapshot,
    required this.money,
    required this.date,
  });

  final PortalSnapshotModel snapshot;
  final String Function(double value) money;
  final String Function(DateTime? value) date;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Spese imputate',
      child: snapshot.movimenti.isEmpty
          ? const Text('Nessuna spesa imputata.')
          : Column(
              children: snapshot.movimenti
                  .map(
                    (row) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${row.codiceSpesa} - ${row.descrizione}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${date(row.date)} - importo spesa ${money(row.importoTotale)}',
                      ),
                      trailing: Text(
                        money(row.quotaCondomino),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _DocumentiSection extends StatelessWidget {
  const _DocumentiSection({
    required this.snapshot,
    required this.date,
    required this.onDownload,
  });

  final PortalSnapshotModel snapshot;
  final String Function(DateTime? value) date;
  final Future<void> Function(String documentoId) onDownload;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Documenti recenti',
      child: snapshot.documentiRecenti.isEmpty
          ? const Text('Nessun documento disponibile.')
          : Column(
              children: snapshot.documentiRecenti
                  .map(
                    (row) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        row.titolo.isEmpty ? 'Documento' : row.titolo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${row.categoria} - ${date(row.createdAt)}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Scarica documento',
                        onPressed: () => onDownload(row.documentoId),
                        icon: const Icon(Icons.download_outlined),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

