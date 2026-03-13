import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../documents/data/documents_repository_provider.dart';
import '../../../jobs/application/async_jobs_notifier.dart';
import '../../../jobs/presentation/dialogs/async_jobs_dialog.dart';
import '../../../registry/application/condomini_notifier.dart';
import '../../application/dashboard_view_providers.dart';
import '../../application/home_navigation_provider.dart';
import '../dialogs/dashboard_automation_dialog.dart';

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
    final alerts = ref.watch(dashboardAlertsProvider);
    final isLoading = ref.watch(dashboardDataLoadingProvider);
    final isAdmin = ref.watch(homeIsAdminProvider);
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final headerWidth = constraints.maxWidth;
                final stackActionsBelow = headerWidth < 980;
                final iconOnlyRefresh = headerWidth < 560;

                Future<void> refreshData() async {
                  await Future.wait([
                    ref
                        .read(condominiProvider.notifier)
                        .loadForSelectedCondominio(showLoading: false),
                    ref
                        .read(documentsDataProvider.notifier)
                        .loadForSelectedCondominio(showLoading: false),
                  ]);
                }

                final statusChip = Chip(
                  label: Text(
                    selected == null
                        ? 'Contesto assente'
                        : (selected.isClosed
                              ? 'Esercizio chiuso'
                              : 'Esercizio aperto'),
                  ),
                );

                final controls = Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    statusChip,
                    if (iconOnlyRefresh)
                      Tooltip(
                        message: 'Aggiorna dati',
                        child: OutlinedButton(
                          onPressed: isLoading ? null : refreshData,
                          child: const Icon(Icons.refresh),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : refreshData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Aggiorna dati'),
                      ),
                  ],
                );

                if (stackActionsBelow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 10),
                      controls,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        selected == null
                            ? 'Nessun esercizio selezionato'
                            : '${selected.label} - ${selected.gestioneLabel} - esercizio ${selected.anno}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    controls,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final columns = _kpiColumnsForWidth(constraints.maxWidth);
              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _KpiCard(
                    width: cardWidth,
                    title: 'Residuo condominio',
                    value: _formatEuro(kpi.residuoCondominio),
                    subtitle: 'Saldo esercizio corrente',
                    color: const Color(0xFF155E75),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  _KpiCard(
                    width: cardWidth,
                    title: 'Budget delta',
                    value: _formatEuro(kpi.deltaBudget),
                    subtitle:
                        'Preventivo ${_formatEuro(kpi.totalePreventivo)} - Consuntivo ${_formatEuro(kpi.totaleConsuntivo)}',
                    color: const Color(0xFF7C2D12),
                    icon: Icons.analytics_outlined,
                  ),
                  _KpiCard(
                    width: cardWidth,
                    title: 'Morosita scaduta',
                    value: _formatEuro(kpi.debitoScadutoTotale),
                    subtitle:
                        '${kpi.morosiTotali} morosi | sollecitati ${kpi.praticheSollecitato} | legale ${kpi.praticheLegale}',
                    color: const Color(0xFF9A3412),
                    icon: Icons.warning_amber_outlined,
                  ),
                  _KpiCard(
                    width: cardWidth,
                    title: 'Scadenze rate',
                    value:
                        '7gg ${kpi.rateScadenza7} - 15gg ${kpi.rateScadenza15} - 30gg ${kpi.rateScadenza30}',
                    subtitle: '${kpi.posizioniTotali} posizioni esercizio',
                    color: const Color(0xFF1D4ED8),
                    icon: Icons.event_note_outlined,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _AlertsPanel(alerts: alerts),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 8.0;
                  final columns = _actionColumnsForWidth(constraints.maxWidth);
                  final buttonWidth =
                      (constraints.maxWidth - spacing * (columns - 1)) /
                      columns;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: buttonWidth,
                        child: FilledButton.icon(
                          onPressed: () => context.go('/home/documents'),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Nuova spesa'),
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: FilledButton.icon(
                          onPressed: () => context.go('/home/documents'),
                          icon: const Icon(Icons.analytics_outlined),
                          label: const Text('Budget e consuntivo'),
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: FilledButton.icon(
                          onPressed: () => context.go('/home/documents'),
                          icon: const Icon(Icons.warning_amber_outlined),
                          label: const Text('Morosita e solleciti'),
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/home/anagrafica'),
                          icon: const Icon(Icons.badge_outlined),
                          label: const Text('Anagrafica e subentri'),
                        ),
                      ),
                      if (isAdmin)
                        SizedBox(
                          width: buttonWidth,
                          child: FilledButton.tonalIcon(
                            onPressed: selected == null || selected.isClosed
                                ? null
                                : () => showDashboardAutomationDialog(
                                    context: context,
                                    onQueueAutomaticSolleciti: (minDays) {
                                      return ref
                                          .read(asyncJobsProvider.notifier)
                                          .queueAutomaticSolleciti(
                                            condominioId: selected.id,
                                            minDaysOverdue: minDays,
                                          );
                                    },
                                    onQueueReminderScadenze: (maxDaysAhead) {
                                      return ref
                                          .read(asyncJobsProvider.notifier)
                                          .queueUpcomingReminders(
                                            condominioId: selected.id,
                                            maxDaysAhead: maxDaysAhead,
                                          );
                                    },
                                    onApplyRatePlan: (templates) {
                                      return ref
                                          .read(documentsDataProvider.notifier)
                                          .applyRatePlan(templates: templates);
                                    },
                                    onOpenJobs: () {
                                      showAsyncJobsDialog(
                                        context: context,
                                        onlySelectedExercise: true,
                                      );
                                    },
                                  ),
                            icon: const Icon(Icons.auto_awesome_outlined),
                            label: const Text('Automazioni'),
                          ),
                        ),
                      if (isAdmin)
                        SizedBox(
                          width: buttonWidth,
                          child: OutlinedButton.icon(
                            onPressed: () => showAsyncJobsDialog(
                              context: context,
                              onlySelectedExercise: true,
                            ),
                            icon: const Icon(Icons.work_history_outlined),
                            label: const Text('Coda job'),
                          ),
                        ),
                    ],
                  );
                },
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

int _kpiColumnsForWidth(double width) {
  if (width < 620) return 1;
  if (width < 1080) return 2;
  if (width < 1440) return 3;
  return 4;
}

class _AlertsPanel extends StatelessWidget {
  const _AlertsPanel({required this.alerts});

  final List<DashboardAlertItem> alerts;

  Color _severityColor(DashboardAlertSeverity severity) {
    switch (severity) {
      case DashboardAlertSeverity.critical:
        return const Color(0xFFB91C1C);
      case DashboardAlertSeverity.warning:
        return const Color(0xFF9A3412);
      case DashboardAlertSeverity.info:
        return const Color(0xFF1D4ED8);
    }
  }

  IconData _severityIcon(DashboardAlertSeverity severity) {
    switch (severity) {
      case DashboardAlertSeverity.critical:
        return Icons.error_outline;
      case DashboardAlertSeverity.warning:
        return Icons.warning_amber_outlined;
      case DashboardAlertSeverity.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notification_important_outlined, size: 18),
                SizedBox(width: 8),
                Text(
                  'Alert scadenze e morosita',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...alerts.map((alert) {
              final color = _severityColor(alert.severity);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.24)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_severityIcon(alert.severity), size: 18, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(alert.message),
                          const SizedBox(height: 2),
                          Text(
                            alert.actionHint,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

int _actionColumnsForWidth(double width) {
  if (width < 760) return 1;
  if (width < 1180) return 2;
  return 4;
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
