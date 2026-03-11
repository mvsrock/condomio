import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/api_error.dart';
import '../../auth/application/keycloak_provider.dart';
import '../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../documents/data/documents_api_client.dart';
import '../../documents/domain/documento_download_model.dart';
import '../data/portal_api_client.dart';
import '../domain/portal_snapshot_model.dart';

class PortalState {
  const PortalState({
    required this.snapshot,
    required this.isLoading,
    required this.errorMessage,
  });

  factory PortalState.initial() {
    return const PortalState(
      snapshot: PortalSnapshotModel.empty(),
      isLoading: false,
      errorMessage: null,
    );
  }

  final PortalSnapshotModel snapshot;
  final bool isLoading;
  final String? errorMessage;

  PortalState copyWith({
    PortalSnapshotModel? snapshot,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PortalState(
      snapshot: snapshot ?? this.snapshot,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Stato applicativo del portale condomino.
///
/// Carica il read-model self-service dal backend e gestisce il download
/// documentale in sola lettura senza dipendere da flussi admin.
class PortalNotifier extends StateNotifier<PortalState> {
  PortalNotifier(this._ref, this._api, this._documentsApi)
    : super(PortalState.initial());

  final Ref _ref;
  final PortalApiClient _api;
  final DocumentsApiClient _documentsApi;

  String _requireAccessToken() {
    final token = _ref.read(keycloakServiceProvider).accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Sessione scaduta: token assente');
    }
    return token;
  }

  String _requireSelectedCondominioId() {
    final selected = _ref.read(selectedManagedCondominioProvider);
    if (selected == null) {
      throw Exception('Nessun esercizio selezionato');
    }
    return selected.id;
  }

  Future<void> loadForSelectedCondominio({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);
    }
    try {
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      final snapshot = await _api.fetchMySnapshot(
        accessToken: token,
        condominioId: condominioId,
      );
      state = state.copyWith(
        isLoading: false,
        snapshot: snapshot,
        clearErrorMessage: true,
      );
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[PORTAL][load] ${e.technicalMessage}');
      } else {
        debugPrint('[PORTAL][load] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  Future<DocumentoDownloadModel> downloadDocumento({
    required String documentoId,
  }) async {
    final token = _requireAccessToken();
    return _documentsApi.downloadDocumentoArchivio(
      accessToken: token,
      documentoId: documentoId,
    );
  }

  void clear() {
    state = PortalState.initial();
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }
}

final portalApiClientProvider = Provider<PortalApiClient>((ref) {
  return const PortalApiClient();
});

final portalNotifierProvider = StateNotifierProvider<PortalNotifier, PortalState>(
  (ref) {
    final portalApi = ref.watch(portalApiClientProvider);
    final documentsApi = const DocumentsApiClient();
    final notifier = PortalNotifier(ref, portalApi, documentsApi);

    if (ref.read(selectedManagedCondominioProvider) != null) {
      notifier.loadForSelectedCondominio();
    }

    ref.listen<String?>(
      selectedManagedCondominioProvider.select((value) => value?.id),
      (previous, next) {
        if (next == null) {
          notifier.clear();
          return;
        }
        if (previous != next) {
          notifier.loadForSelectedCondominio();
        }
      },
    );
    return notifier;
  },
);

final portalSnapshotProvider = Provider<PortalSnapshotModel>((ref) {
  return ref.watch(portalNotifierProvider.select((state) => state.snapshot));
});

final portalIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(portalNotifierProvider.select((state) => state.isLoading));
});

final portalErrorProvider = Provider<String?>((ref) {
  return ref.watch(portalNotifierProvider.select((state) => state.errorMessage));
});
