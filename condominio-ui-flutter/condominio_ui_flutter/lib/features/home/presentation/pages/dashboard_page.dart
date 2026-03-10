import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../documents/data/documents_repository_provider.dart';
import '../../../registry/application/condomini_notifier.dart';
import '../../application/dashboard_view_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  String _formatEuro(double value) {
    return value.toStringAsFixed(2);
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final yyyy = local.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedManagedCondominioProvider);
    final kpi = ref.watch(dashboardKpiProvider);
    final recentMovimenti = ref.watch(dashboardRecentMovimentiProvider);
    final recentVersamenti = ref.watch(dashboardRecentVersamentiProvider);
    final recentSolleciti = ref.watch(dashboardRecentSollecitiProvider);
    final isLoading = ref.watch(dashboardDataLoadingProvider);
    final isWide = MediaQuery.of(context).size.width >= 1120;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD9E2EC)),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  selected == null
                      ? 'Nessun esercizio selezionato'
                      : '${selected.label} - ${selected.gestioneLabel} - esercizio ${selected.anno}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Chip(
                  label: Text(
                    selected == null
                        ? 'Contesto assente'
                        : (selected.isClosed
                              ? 'Esercizio chiuso'
                              : 'Esercizio aperto'),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => context.go('/select-condominio'),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Cambia esercizio'),
                ),
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          await Future.wait([
                            ref
                                .read(condominiProvider.notifier)
                                .loadForSelectedCondominio(showLoading: false),
                            ref
                                .read(documentsDataProvider.notifier)
                                .loadForSelectedCondominio(showLoading: false),
                          ]);
                        },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Aggiorna dati'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _KpiCard(
                title: 'Residuo condominio',
                value: _formatEuro(kpi.residuoCondominio),
                subtitle: 'Saldo esercizio corrente',
                color: const Color(0xFF155E75),
                icon: Icons.account_balance_wallet_outlined,
              ),
              _KpiCard(
                title: 'Budget delta',
                value: _formatEuro(kpi.deltaBudget),
                subtitle:
                    'Preventivo ${_formatEuro(kpi.totalePreventivo)} - Consuntivo ${_formatEuro(kpi.totaleConsuntivo)}',
                color: const Color(0xFF7C2D12),
                icon: Icons.analytics_outlined,
              ),
              _KpiCard(
                title: 'Morosita scaduta',
                value: _formatEuro(kpi.debitoScadutoTotale),
                subtitle:
                    '${kpi.morosiTotali} morosi | sollecitati ${kpi.praticheSollecitato} | legale ${kpi.praticheLegale}',
                color: const Color(0xFF9A3412),
                icon: Icons.warning_amber_outlined,
              ),
              _KpiCard(
                title: 'Scadenze rate',
                value:
                    '7gg ${kpi.rateScadenza7} - 15gg ${kpi.rateScadenza15} - 30gg ${kpi.rateScadenza30}',
                subtitle: '${kpi.posizioniTotali} posizioni esercizio',
                color: const Color(0xFF1D4ED8),
                icon: Icons.event_note_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ActivityPanel(
                    title: 'Ultime spese',
                    icon: Icons.receipt_long_outlined,
                    items: recentMovimenti
                        .map(
                          (row) => _ActivityRow(
                            title: '${row.codiceSpesa} - ${row.descrizione}',
                            subtitle: _formatDate(row.date),
                            trailing: _formatEuro(row.importo),
                          ),
                        )
                        .toList(growable: false),
                    onOpen: () => context.go('/home/documents'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActivityPanel(
                    title: 'Ultimi versamenti',
                    icon: Icons.payments_outlined,
                    items: recentVersamenti
                        .map(
                          (row) => _ActivityRow(
                            title: row.nominativo,
                            subtitle:
                                '${row.descrizione} - ${_formatDate(row.date)}',
                            trailing: _formatEuro(row.importo),
                          ),
                        )
                        .toList(growable: false),
                    onOpen: () => context.go('/home/documents'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActivityPanel(
                    title: 'Ultimi solleciti',
                    icon: Icons.mark_email_unread_outlined,
                    items: recentSolleciti
                        .map(
                          (row) => _ActivityRow(
                            title: row.nominativo,
                            subtitle:
                                '${row.titolo} - ${row.canale} - ${_formatDate(row.createdAt)}${row.automatico ? ' (auto)' : ''}',
                            trailing: '',
                          ),
                        )
                        .toList(growable: false),
                    onOpen: () => context.go('/home/documents'),
                  ),
                ),
              ],
            )
          else ...[
            _ActivityPanel(
              title: 'Ultime spese',
              icon: Icons.receipt_long_outlined,
              items: recentMovimenti
                  .map(
                    (row) => _ActivityRow(
                      title: '${row.codiceSpesa} - ${row.descrizione}',
                      subtitle: _formatDate(row.date),
                      trailing: _formatEuro(row.importo),
                    ),
                  )
                  .toList(growable: false),
              onOpen: () => context.go('/home/documents'),
            ),
            const SizedBox(height: 12),
            _ActivityPanel(
              title: 'Ultimi versamenti',
              icon: Icons.payments_outlined,
              items: recentVersamenti
                  .map(
                    (row) => _ActivityRow(
                      title: row.nominativo,
                      subtitle: '${row.descrizione} - ${_formatDate(row.date)}',
                      trailing: _formatEuro(row.importo),
                    ),
                  )
                  .toList(growable: false),
              onOpen: () => context.go('/home/documents'),
            ),
            const SizedBox(height: 12),
            _ActivityPanel(
              title: 'Ultimi solleciti',
              icon: Icons.mark_email_unread_outlined,
              items: recentSolleciti
                  .map(
                    (row) => _ActivityRow(
                      title: row.nominativo,
                      subtitle:
                          '${row.titolo} - ${row.canale} - ${_formatDate(row.createdAt)}${row.automatico ? ' (auto)' : ''}',
                      trailing: '',
                    ),
                  )
                  .toList(growable: false),
              onOpen: () => context.go('/home/documents'),
            ),
          ],
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go('/home/documents'),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Nuova spesa'),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.go('/home/documents'),
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('Budget e consuntivo'),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.go('/home/documents'),
                    icon: const Icon(Icons.warning_amber_outlined),
                    label: const Text('Morosita e solleciti'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/home/anagrafica'),
                    icon: const Icon(Icons.badge_outlined),
                    label: const Text('Anagrafica e subentri'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 19),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF243B53),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF627D98), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityRow {
  const _ActivityRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({
    required this.title,
    required this.icon,
    required this.items,
    required this.onOpen,
  });

  final String title;
  final IconData icon;
  final List<_ActivityRow> items;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF334E68)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(onPressed: onOpen, child: const Text('Apri')),
              ],
            ),
            const SizedBox(height: 4),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Nessun dato recente'),
              )
            else
              ...items.map(
                (row) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    row.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    row.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: row.trailing.isEmpty ? null : Text(row.trailing),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
