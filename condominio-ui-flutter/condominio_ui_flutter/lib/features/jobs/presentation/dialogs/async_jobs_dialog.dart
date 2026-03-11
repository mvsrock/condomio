import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../platform/file_download.dart';
import '../../application/async_jobs_notifier.dart';
import '../../domain/async_job_model.dart';

Future<void> showAsyncJobsDialog({
  required BuildContext context,
  bool onlySelectedExercise = true,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AsyncJobsDialog(onlySelectedExercise: onlySelectedExercise),
  );
}

/// Dialog monitor job asincroni:
/// - stato RUNNING/QUEUED/DONE/FAILED
/// - download risultato quando disponibile
/// - polling leggero mentre ci sono job non terminali
class AsyncJobsDialog extends ConsumerStatefulWidget {
  const AsyncJobsDialog({super.key, required this.onlySelectedExercise});

  final bool onlySelectedExercise;

  @override
  ConsumerState<AsyncJobsDialog> createState() => _AsyncJobsDialogState();
}

class _AsyncJobsDialogState extends ConsumerState<AsyncJobsDialog> {
  static const _pollInterval = Duration(seconds: 2);

  Timer? _pollTimer;
  bool _autoRefresh = true;
  final Set<String> _downloadingJobIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadJobs(showLoading: true);
      _startPolling();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollTick());
  }

  Future<void> _pollTick() async {
    if (!mounted || !_autoRefresh) return;
    final hasRunning = ref.read(asyncJobsHasRunningProvider);
    final isLoading = ref.read(asyncJobsIsLoadingProvider);
    if (!hasRunning || isLoading) return;
    await _loadJobs(showLoading: false);
  }

  Future<void> _loadJobs({required bool showLoading}) async {
    try {
      await ref
          .read(asyncJobsProvider.notifier)
          .loadJobs(showLoading: showLoading, limit: 80);
    } catch (_) {
      // Messaggio gia' nello stato provider.
    }
  }

  Future<void> _downloadResult(AsyncJobModel job) async {
    if (_downloadingJobIds.contains(job.id)) return;
    setState(() => _downloadingJobIds.add(job.id));
    try {
      final payload = await ref
          .read(asyncJobsProvider.notifier)
          .downloadResult(jobId: job.id);
      final saved = await saveBytesToFile(
        bytes: payload.bytes,
        fileName: payload.fileName,
        contentType: payload.contentType,
      );
      if (!mounted) return;
      final message = saved
          ? 'File salvato: ${payload.fileName}'
          : 'Download annullato';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore download: $e')));
    } finally {
      if (mounted) {
        setState(() => _downloadingJobIds.remove(job.id));
      }
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final yyyy = local.year.toString();
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    final sec = local.second.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min:$sec';
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8);
  }

  String _typeLabel(AsyncJobType type) {
    switch (type) {
      case AsyncJobType.reportExport:
        return 'Export report';
      case AsyncJobType.morositaAutoSolleciti:
        return 'Auto-solleciti';
      case AsyncJobType.unknown:
        return 'Tipo sconosciuto';
    }
  }

  IconData _typeIcon(AsyncJobType type) {
    switch (type) {
      case AsyncJobType.reportExport:
        return Icons.assessment_outlined;
      case AsyncJobType.morositaAutoSolleciti:
        return Icons.auto_fix_high_outlined;
      case AsyncJobType.unknown:
        return Icons.help_outline;
    }
  }

  Color _statusColor(BuildContext context, AsyncJobStatus status) {
    switch (status) {
      case AsyncJobStatus.queued:
        return const Color(0xFF9A3412);
      case AsyncJobStatus.running:
        return Theme.of(context).colorScheme.primary;
      case AsyncJobStatus.done:
        return const Color(0xFF166534);
      case AsyncJobStatus.failed:
        return const Color(0xFFB91C1C);
      case AsyncJobStatus.unknown:
        return const Color(0xFF475569);
    }
  }

  String _statusLabel(AsyncJobStatus status) {
    switch (status) {
      case AsyncJobStatus.queued:
        return 'In coda';
      case AsyncJobStatus.running:
        return 'In esecuzione';
      case AsyncJobStatus.done:
        return 'Completato';
      case AsyncJobStatus.failed:
        return 'Fallito';
      case AsyncJobStatus.unknown:
        return 'Sconosciuto';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(asyncJobsIsLoadingProvider);
    final errorMessage = ref.watch(asyncJobsErrorMessageProvider);
    final hasRunning = ref.watch(asyncJobsHasRunningProvider);
    final rows = widget.onlySelectedExercise
        ? ref.watch(asyncJobsBySelectedExerciseProvider)
        : ref.watch(asyncJobsItemsProvider);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.work_history_outlined),
          const SizedBox(width: 8),
          const Expanded(child: Text('Coda job')),
          if (hasRunning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Attivita in corso',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ),
        ],
      ),
      content: SizedBox(
        width: 900,
        height: 620,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _loadJobs(showLoading: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Aggiorna'),
                ),
                FilterChip(
                  label: const Text('Auto-refresh'),
                  selected: _autoRefresh,
                  onSelected: (value) => setState(() => _autoRefresh = value),
                ),
                if (widget.onlySelectedExercise)
                  const Chip(
                    avatar: Icon(Icons.filter_alt_outlined, size: 16),
                    label: Text('Filtro: esercizio attivo'),
                  )
                else
                  const Chip(
                    avatar: Icon(Icons.list_alt_outlined, size: 16),
                    label: Text('Mostra tutti i job utente'),
                  ),
                if (isLoading) const CircularProgressIndicator(),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Material(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFB91C1C)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          errorMessage,
                          style: const TextStyle(color: Color(0xFF7F1D1D)),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Chiudi errore',
                        onPressed: () =>
                            ref.read(asyncJobsProvider.notifier).clearError(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: rows.isEmpty
                  ? const Center(
                      child: Text(
                        'Nessun job presente per il filtro corrente.',
                      ),
                    )
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final job = rows[index];
                        final statusColor = _statusColor(context, job.status);
                        final canDownload =
                            job.type == AsyncJobType.reportExport &&
                            job.resultDownloadAvailable &&
                            job.status == AsyncJobStatus.done;
                        final isDownloading = _downloadingJobIds.contains(
                          job.id,
                        );
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Icon(
                                    _typeIcon(job.type),
                                    color: const Color(0xFF334E68),
                                  ),
                                  Text(
                                    '${_typeLabel(job.type)} #${_shortId(job.id)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: statusColor.withValues(
                                          alpha: 0.32,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      _statusLabel(job.status),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (canDownload)
                                    OutlinedButton.icon(
                                      onPressed: isDownloading
                                          ? null
                                          : () => _downloadResult(job),
                                      icon: isDownloading
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.download_outlined),
                                      label: const Text('Scarica'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  SelectableText(
                                    'Esercizio: ${job.idCondominio}',
                                  ),
                                  SelectableText(
                                    'Creato: ${_formatDateTime(job.createdAt)}',
                                  ),
                                  if (job.startedAt != null)
                                    SelectableText(
                                      'Avviato: ${_formatDateTime(job.startedAt)}',
                                    ),
                                  if (job.finishedAt != null)
                                    SelectableText(
                                      'Terminato: ${_formatDateTime(job.finishedAt)}',
                                    ),
                                ],
                              ),
                              if ((job.message ?? '').trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                SelectableText(
                                  'Messaggio: ${job.message!.trim()}',
                                ),
                              ],
                              if ((job.errorCode ?? '').trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                SelectableText(
                                  'Errore: ${job.errorCode!.trim()}',
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                              ],
                              if (job.type == AsyncJobType.reportExport &&
                                  (job.resultFileName ?? '')
                                      .trim()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 6),
                                SelectableText(
                                  'Output: ${job.resultFileName} (${job.resultSizeBytes ?? 0} bytes)',
                                ),
                              ],
                              if (job.type ==
                                      AsyncJobType.morositaAutoSolleciti &&
                                  job.resultCount != null) ...[
                                const SizedBox(height: 6),
                                SelectableText(
                                  'Solleciti creati: ${job.resultCount}',
                                ),
                              ],
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
}
