import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/api_error.dart';
import '../../auth/application/keycloak_provider.dart';
import '../../condominio_selection/application/managed_condominio_notifier.dart';
import '../domain/condominio_document_model.dart';
import '../domain/condomino_document_model.dart';
import '../domain/movimento_model.dart';
import '../domain/tabella_model.dart';
import 'documents_api_client.dart';

/// Dataset reale del modulo documenti (letto da backend `core`).
class DocumentsDataset {
  const DocumentsDataset({
    required this.condomini,
    required this.condominiAnagrafica,
    required this.movimenti,
    required this.tabelle,
  });

  const DocumentsDataset.empty()
    : condomini = const [],
      condominiAnagrafica = const [],
      movimenti = const [],
      tabelle = const [];

  final List<CondominioDocumentModel> condomini;
  final List<CondominoDocumentModel> condominiAnagrafica;
  final List<MovimentoModel> movimenti;
  final List<TabellaModel> tabelle;
}

class DocumentsDataState {
  const DocumentsDataState({
    required this.dataset,
    required this.isLoading,
    required this.isSaving,
    required this.errorMessage,
  });

  factory DocumentsDataState.initial() {
    return const DocumentsDataState(
      dataset: DocumentsDataset.empty(),
      isLoading: false,
      isSaving: false,
      errorMessage: null,
    );
  }

  final DocumentsDataset dataset;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  DocumentsDataState copyWith({
    DocumentsDataset? dataset,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DocumentsDataState(
      dataset: dataset ?? this.dataset,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class DocumentsDataNotifier extends StateNotifier<DocumentsDataState> {
  DocumentsDataNotifier(this._ref, this._api)
    : super(DocumentsDataState.initial());

  final Ref _ref;
  final DocumentsApiClient _api;

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
      throw Exception('Nessun condominio selezionato');
    }
    return selected.id;
  }

  void _ensureSelectedExerciseWritable() {
    final selected = _ref.read(selectedManagedCondominioProvider);
    if (selected == null) {
      throw Exception('Nessun condominio selezionato');
    }
    if (selected.isClosed) {
      throw Exception(
        'Esercizio chiuso: operazione documentale non consentita in modalita sola lettura.',
      );
    }
  }

  Future<void> _refreshAllForSelectedCondominio() async {
    final token = _requireAccessToken();
    final condominioId = _requireSelectedCondominioId();

    final condominio = await _api.fetchCondominioById(
      accessToken: token,
      condominioId: condominioId,
    );
    final condomini = await _api.fetchCondomini(
      accessToken: token,
      condominioId: condominioId,
    );
    final tabelle = await _api.fetchTabelle(
      accessToken: token,
      condominioId: condominioId,
    );
    final movimenti = await _api.fetchMovimenti(
      accessToken: token,
      condominioId: condominioId,
    );

    state = state.copyWith(
      dataset: DocumentsDataset(
        condomini: [condominio],
        condominiAnagrafica: condomini,
        movimenti: movimenti,
        tabelle: tabelle,
      ),
    );
  }

  Future<void> _refreshCondominioAndMovimenti() async {
    final token = _requireAccessToken();
    final condominioId = _requireSelectedCondominioId();

    final condominio = await _api.fetchCondominioById(
      accessToken: token,
      condominioId: condominioId,
    );
    final movimenti = await _api.fetchMovimenti(
      accessToken: token,
      condominioId: condominioId,
    );

    state = state.copyWith(
      dataset: DocumentsDataset(
        condomini: [condominio],
        condominiAnagrafica: state.dataset.condominiAnagrafica,
        movimenti: movimenti,
        tabelle: state.dataset.tabelle,
      ),
    );
  }

  Future<void> _refreshCondominioCondominiMovimenti() async {
    final token = _requireAccessToken();
    final condominioId = _requireSelectedCondominioId();

    final condominio = await _api.fetchCondominioById(
      accessToken: token,
      condominioId: condominioId,
    );
    final condomini = await _api.fetchCondomini(
      accessToken: token,
      condominioId: condominioId,
    );
    final movimenti = await _api.fetchMovimenti(
      accessToken: token,
      condominioId: condominioId,
    );

    state = state.copyWith(
      dataset: DocumentsDataset(
        condomini: [condominio],
        condominiAnagrafica: condomini,
        movimenti: movimenti,
        tabelle: state.dataset.tabelle,
      ),
    );
  }

  Future<void> _refreshCondominioTabelleCondomini() async {
    final token = _requireAccessToken();
    final condominioId = _requireSelectedCondominioId();

    final condominio = await _api.fetchCondominioById(
      accessToken: token,
      condominioId: condominioId,
    );
    final tabelle = await _api.fetchTabelle(
      accessToken: token,
      condominioId: condominioId,
    );
    final condomini = await _api.fetchCondomini(
      accessToken: token,
      condominioId: condominioId,
    );

    state = state.copyWith(
      dataset: DocumentsDataset(
        condomini: [condominio],
        condominiAnagrafica: condomini,
        movimenti: state.dataset.movimenti,
        tabelle: tabelle,
      ),
    );
  }

  Future<void> _refreshCondominiAndMovimenti() async {
    final token = _requireAccessToken();
    final condominioId = _requireSelectedCondominioId();

    final condomini = await _api.fetchCondomini(
      accessToken: token,
      condominioId: condominioId,
    );
    final movimenti = await _api.fetchMovimenti(
      accessToken: token,
      condominioId: condominioId,
    );

    state = state.copyWith(
      dataset: DocumentsDataset(
        condomini: state.dataset.condomini,
        condominiAnagrafica: condomini,
        movimenti: movimenti,
        tabelle: state.dataset.tabelle,
      ),
    );
  }

  Future<void> loadForSelectedCondominio() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await _refreshAllForSelectedCondominio();
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][load] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][load] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  Future<void> createTabella({
    required String codice,
    required String descrizione,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      await _api.createTabella(
        accessToken: token,
        condominioId: condominioId,
        codice: codice,
        descrizione: descrizione,
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioTabelleCondomini();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][createTabella] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][createTabella] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> createMovimento({
    required String codiceSpesa,
    required String descrizione,
    required double importo,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      await _api.createMovimento(
        accessToken: token,
        condominioId: condominioId,
        codiceSpesa: codiceSpesa,
        descrizione: descrizione,
        importo: importo,
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioCondominiMovimenti();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][createMovimento] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][createMovimento] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> updateMovimento({
    required String movimentoId,
    required String codiceSpesa,
    required String descrizione,
    required double importo,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      await _api.updateMovimento(
        accessToken: token,
        movimentoId: movimentoId,
        codiceSpesa: codiceSpesa,
        descrizione: descrizione,
        importo: importo,
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioCondominiMovimenti();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][updateMovimento] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][updateMovimento] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> deleteMovimento({
    required String movimentoId,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      await _api.deleteMovimento(
        accessToken: token,
        movimentoId: movimentoId,
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioCondominiMovimenti();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][deleteMovimento] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][deleteMovimento] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> updateTabella({
    required String tabellaId,
    required String codice,
    required String descrizione,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      await _api.updateTabella(
        accessToken: token,
        tabellaId: tabellaId,
        codice: codice,
        descrizione: descrizione,
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioTabelleCondomini();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][updateTabella] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][updateTabella] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> deleteTabella({
    required String tabellaId,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      await _api.deleteTabella(
        accessToken: token,
        tabellaId: tabellaId,
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioTabelleCondomini();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][deleteTabella] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][deleteTabella] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> cleanupDeleteTabella({
    required String tabellaId,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      await _api.cleanupDeleteTabella(
        accessToken: token,
        tabellaId: tabellaId,
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioTabelleCondomini();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][cleanupDeleteTabella] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][cleanupDeleteTabella] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> updateConfigurazioniSpesa({
    required List<CondominioConfigurazioneDraft> configurazioni,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      await _api.patchCondominioConfigurazioniSpesa(
        accessToken: token,
        condominioId: condominioId,
        configurazioniSpesa: configurazioni.map((c) => c.toJson()).toList(),
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioAndMovimenti();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][updateConfigurazioniSpesa] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][updateConfigurazioniSpesa] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> updateCondominoQuoteTabelle({
    required String condominoId,
    required List<CondominoTabellaQuotaDraft> quote,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      await _api.patchCondominoQuoteTabelle(
        accessToken: token,
        condominoId: condominoId,
        tabelle: quote.map((q) => q.toJson()).toList(growable: false),
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominiAndMovimenti();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][updateCondominoQuoteTabelle] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][updateCondominoQuoteTabelle] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> addCondominoVersamento({
    required String condominoId,
    required CondominoVersamentoDraft versamento,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      await _api.addCondominoVersamento(
        accessToken: token,
        condominoId: condominoId,
        versamento: versamento.toJson(),
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioCondominiMovimenti();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][addCondominoVersamento] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][addCondominoVersamento] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> updateCondominoVersamento({
    required String condominoId,
    required String versamentoId,
    required CondominoVersamentoDraft versamento,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      await _api.updateCondominoVersamento(
        accessToken: token,
        condominoId: condominoId,
        versamentoId: versamentoId,
        versamento: versamento.toJson(),
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioCondominiMovimenti();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][updateCondominoVersamento] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][updateCondominoVersamento] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  Future<void> deleteCondominoVersamento({
    required String condominoId,
    required String versamentoId,
  }) async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      await _api.deleteCondominoVersamento(
        accessToken: token,
        condominoId: condominoId,
        versamentoId: versamentoId,
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioCondominiMovimenti();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][deleteCondominoVersamento] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][deleteCondominoVersamento] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  /// Rebuild storico completo (movimenti + residui) per il condominio selezionato.
  Future<void> rebuildStoricoCondominio() async {
    state = state.copyWith(isSaving: true, clearErrorMessage: true);
    try {
      _ensureSelectedExerciseWritable();
      final token = _requireAccessToken();
      final condominioId = _requireSelectedCondominioId();
      await _api.rebuildStoricoCondominio(
        accessToken: token,
        condominioId: condominioId,
      );
      state = state.copyWith(isSaving: false);
      await _refreshCondominioCondominiMovimenti();
    } catch (e, st) {
      if (e is ApiError) {
        debugPrint('[DOCUMENTS][rebuildStoricoCondominio] ${e.technicalMessage}');
      } else {
        debugPrint('[DOCUMENTS][rebuildStoricoCondominio] $e');
      }
      debugPrint('$st');
      state = state.copyWith(isSaving: false, errorMessage: '$e');
      rethrow;
    }
  }

  void clear() {
    state = DocumentsDataState.initial();
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }
}

final documentsApiClientProvider = Provider<DocumentsApiClient>((ref) {
  return const DocumentsApiClient();
});

final documentsDataProvider =
    StateNotifierProvider<DocumentsDataNotifier, DocumentsDataState>((ref) {
      final api = ref.watch(documentsApiClientProvider);
      final notifier = DocumentsDataNotifier(ref, api);
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
    });

final documentsRepositoryProvider = Provider<DocumentsDataset>((ref) {
  return ref.watch(documentsDataProvider.select((state) => state.dataset));
});

class CondominioConfigurazioneDraft {
  const CondominioConfigurazioneDraft({
    required this.codice,
    required this.tabelle,
  });

  final String codice;
  final List<CondominioTabellaPercentualeDraft> tabelle;

  Map<String, dynamic> toJson() {
    return {
      'codice': codice,
      'tabelle': tabelle.map((t) => t.toJson()).toList(),
    };
  }
}

class CondominioTabellaPercentualeDraft {
  const CondominioTabellaPercentualeDraft({
    required this.codice,
    required this.descrizione,
    required this.percentuale,
  });

  final String codice;
  final String descrizione;
  final int percentuale;

  Map<String, dynamic> toJson() {
    return {
      'codice': codice,
      'descrizione': descrizione,
      'percentuale': percentuale,
    };
  }
}

class CondominoTabellaQuotaDraft {
  const CondominoTabellaQuotaDraft({
    required this.codice,
    required this.descrizione,
    required this.numeratore,
    required this.denominatore,
  });

  final String codice;
  final String descrizione;
  final double numeratore;
  final double denominatore;

  Map<String, dynamic> toJson() {
    return {
      'tabella': {
        'codice': codice,
        'descrizione': descrizione,
      },
      'numeratore': numeratore,
      'denominatore': denominatore,
    };
  }
}

class CondominoVersamentoDraft {
  const CondominoVersamentoDraft({
    this.id,
    required this.descrizione,
    required this.importo,
    required this.date,
    required this.insertedAt,
  });

  final String? id;
  final String descrizione;
  final double importo;
  final DateTime date;
  final DateTime insertedAt;

  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'descrizione': descrizione,
      'importo': importo,
      'date': date.toUtc().toIso8601String(),
      'insertedAt': insertedAt.toUtc().toIso8601String(),
      'ripartizioneTabelle': const <Map<String, dynamic>>[],
    };
  }
}
