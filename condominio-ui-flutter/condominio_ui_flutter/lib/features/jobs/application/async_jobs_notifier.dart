import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/api_error.dart';
import '../../auth/application/keycloak_provider.dart';
import '../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../documents/domain/documento_download_model.dart';
import '../data/async_job_api_client.dart';
import '../domain/async_job_model.dart';

class AsyncJobsState {
  const AsyncJobsState({
    required this.items,
    required this.isLoading,
    required this.isQueueing,
    required this.errorMessage,
  });

  factory AsyncJobsState.initial() {
    return const AsyncJobsState(
      items: [],
      isLoading: false,
      isQueueing: false,
      errorMessage: null,
    );
  }

  final List<AsyncJobModel> items;
  final bool isLoading;
  final bool isQueueing;
  final String? errorMessage;

  AsyncJobsState copyWith({
    List<AsyncJobModel>? items,
    bool? isLoading,
    bool? isQueueing,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AsyncJobsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isQueueing: isQueueing ?? this.isQueueing,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier dei job asincroni (Fase 8, punto 1).
///
/// Responsabilita':
/// - accodare operazioni pesanti (report export, auto-solleciti)
/// - leggere stato coda job del richiedente corrente
/// - scaricare il risultato quando il job e' completato
class AsyncJobsNotifier extends StateNotifier<AsyncJobsState> {
  AsyncJobsNotifier(this._ref, this._api) : super(AsyncJobsState.initial());

  final Ref _ref;
  final AsyncJobApiClient _api;

  String _requireAccessToken() {
    final token = _ref.read(keycloakServiceProvider).accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Sessione scaduta: token assente');
    }
    return token;
  }

  String _requireSelectedCondominioId() {
    final selected = _ref.read(selectedManagedCondominioProvider);
    if (selected == null || selected.id.trim().isEmpty) {
      throw Exception('Nessun esercizio selezionato');
    }
    return selected.id;
  }

  Future<void> loadJobs({int limit = 50, bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);
    }
    try {
      final token = _requireAccessToken();
      final rows = await _api.listJobs(accessToken: token, limit: limit);
      state = state.copyWith(items: rows, isLoading: false);
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[ASYNC_JOBS][loadJobs] ${e.technicalMessage}');
      } else {
        debugPrint('[ASYNC_JOBS][loadJobs] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isLoading: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<AsyncJobModel> queueReportExport({
    required AsyncReportFormat format,
    String? condominioId,
    String? condominoId,
  }) async {
    state = state.copyWith(isQueueing: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      final exerciseId =
          _normalize(condominioId) ?? _requireSelectedCondominioId();
      final job = await _api.queueReportExport(
        accessToken: token,
        condominioId: exerciseId,
        format: format,
        condominoId: _normalize(condominoId),
      );
      _upsertJob(job);
      state = state.copyWith(isQueueing: false);
      return job;
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[ASYNC_JOBS][queueReportExport] ${e.technicalMessage}');
      } else {
        debugPrint('[ASYNC_JOBS][queueReportExport] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isQueueing: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<AsyncJobModel> queueAutomaticSolleciti({
    required int minDaysOverdue,
    String? condominioId,
  }) async {
    state = state.copyWith(isQueueing: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      final exerciseId =
          _normalize(condominioId) ?? _requireSelectedCondominioId();
      final job = await _api.queueAutomaticSolleciti(
        accessToken: token,
        condominioId: exerciseId,
        minDaysOverdue: minDaysOverdue,
      );
      _upsertJob(job);
      state = state.copyWith(isQueueing: false);
      return job;
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint(
          '[ASYNC_JOBS][queueAutomaticSolleciti] ${e.technicalMessage}',
        );
      } else {
        debugPrint('[ASYNC_JOBS][queueAutomaticSolleciti] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isQueueing: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<AsyncJobModel> queueUpcomingReminders({
    required int maxDaysAhead,
    String? condominioId,
  }) async {
    state = state.copyWith(isQueueing: true, clearErrorMessage: true);
    try {
      final token = _requireAccessToken();
      final exerciseId =
          _normalize(condominioId) ?? _requireSelectedCondominioId();
      final job = await _api.queueUpcomingReminders(
        accessToken: token,
        condominioId: exerciseId,
        maxDaysAhead: maxDaysAhead,
      );
      _upsertJob(job);
      state = state.copyWith(isQueueing: false);
      return job;
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint(
          '[ASYNC_JOBS][queueUpcomingReminders] ${e.technicalMessage}',
        );
      } else {
        debugPrint('[ASYNC_JOBS][queueUpcomingReminders] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isQueueing: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<DocumentoDownloadModel> downloadResult({required String jobId}) async {
    try {
      final token = _requireAccessToken();
      return await _api.downloadResult(accessToken: token, jobId: jobId);
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[ASYNC_JOBS][downloadResult] ${e.technicalMessage}');
      } else {
        debugPrint('[ASYNC_JOBS][downloadResult] $e');
      }
      debugPrint('$st');
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  void _upsertJob(AsyncJobModel job) {
    final next = <AsyncJobModel>[job];
    for (final existing in state.items) {
      if (existing.id == job.id) continue;
      next.add(existing);
    }
    state = state.copyWith(items: next);
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final out = value.trim();
    return out.isEmpty ? null : out;
  }
}

final asyncJobApiClientProvider = Provider<AsyncJobApiClient>((ref) {
  return const AsyncJobApiClient();
});

final asyncJobsProvider =
    StateNotifierProvider<AsyncJobsNotifier, AsyncJobsState>((ref) {
      final api = ref.watch(asyncJobApiClientProvider);
      return AsyncJobsNotifier(ref, api);
    });

final asyncJobsItemsProvider = Provider<List<AsyncJobModel>>((ref) {
  return ref.watch(asyncJobsProvider.select((state) => state.items));
});

/// Coda job filtrata per esercizio attivo.
final asyncJobsBySelectedExerciseProvider = Provider<List<AsyncJobModel>>((
  ref,
) {
  final selectedExerciseId = ref.watch(
    selectedManagedCondominioProvider.select((value) => value?.id),
  );
  final rows = ref.watch(asyncJobsItemsProvider);
  if (selectedExerciseId == null || selectedExerciseId.trim().isEmpty) {
    return rows;
  }
  return rows
      .where((item) => item.idCondominio.trim() == selectedExerciseId.trim())
      .toList(growable: false);
});

final asyncJobsHasRunningProvider = Provider<bool>((ref) {
  return ref.watch(
    asyncJobsItemsProvider.select(
      (rows) => rows.any(
        (item) =>
            item.status == AsyncJobStatus.queued ||
            item.status == AsyncJobStatus.running,
      ),
    ),
  );
});

final asyncJobsIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(asyncJobsProvider.select((state) => state.isLoading));
});

final asyncJobsIsQueueingProvider = Provider<bool>((ref) {
  return ref.watch(asyncJobsProvider.select((state) => state.isQueueing));
});

final asyncJobsErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(asyncJobsProvider.select((state) => state.errorMessage));
});
