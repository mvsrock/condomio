import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/documents_repository_provider.dart';
import '../domain/condominio_document_model.dart';
import '../domain/condomino_document_model.dart';
import '../domain/documento_archivio_model.dart';
import '../domain/morosita_item_model.dart';
import '../domain/movimento_model.dart';
import '../domain/preventivo_snapshot_model.dart';
import '../domain/tabella_model.dart';

/// Stato UI modulo Documenti.
///
/// Tiene solo selezioni/filtri della pagina.
class DocumentsUiState {
  const DocumentsUiState({
    required this.selectedCondominioId,
    required this.selectedCondominoId,
    required this.searchMovimenti,
  });

  factory DocumentsUiState.initial() {
    return const DocumentsUiState(
      selectedCondominioId: null,
      selectedCondominoId: null,
      searchMovimenti: '',
    );
  }

  final String? selectedCondominioId;
  final String? selectedCondominoId;
  final String searchMovimenti;

  DocumentsUiState copyWith({
    String? selectedCondominioId,
    bool clearSelectedCondominioId = false,
    String? selectedCondominoId,
    bool clearSelectedCondominoId = false,
    String? searchMovimenti,
  }) {
    return DocumentsUiState(
      selectedCondominioId: clearSelectedCondominioId
          ? null
          : (selectedCondominioId ?? this.selectedCondominioId),
      selectedCondominoId: clearSelectedCondominoId
          ? null
          : (selectedCondominoId ?? this.selectedCondominoId),
      searchMovimenti: searchMovimenti ?? this.searchMovimenti,
    );
  }
}

class DocumentsUiNotifier extends StateNotifier<DocumentsUiState> {
  DocumentsUiNotifier() : super(DocumentsUiState.initial());

  void selectCondominio(String id) {
    state = state.copyWith(
      selectedCondominioId: id,
      clearSelectedCondominoId: true,
    );
  }

  void selectCondomino(String? id) {
    state = id == null
        ? state.copyWith(clearSelectedCondominoId: true)
        : state.copyWith(selectedCondominoId: id);
  }

  void setSearchMovimenti(String value) {
    state = state.copyWith(searchMovimenti: value);
  }
}

final documentsUiProvider =
    StateNotifierProvider<DocumentsUiNotifier, DocumentsUiState>(
      (ref) => DocumentsUiNotifier(),
    );

/// Condominio selezionato.
final selectedCondominioProvider = Provider<CondominioDocumentModel?>((ref) {
  final dataset = ref.watch(documentsRepositoryProvider);
  final selectedId = ref.watch(
    documentsUiProvider.select((s) => s.selectedCondominioId),
  );
  if (selectedId == null) {
    return dataset.condomini.isEmpty ? null : dataset.condomini.first;
  }
  for (final c in dataset.condomini) {
    if (c.id == selectedId) return c;
  }
  return dataset.condomini.isEmpty ? null : dataset.condomini.first;
});

/// Condomini appartenenti al condominio selezionato.
final condominiBySelectedCondominioProvider =
    Provider<List<CondominoDocumentModel>>((ref) {
      final dataset = ref.watch(documentsRepositoryProvider);
      final selectedCondominio = ref.watch(selectedCondominioProvider);
      if (selectedCondominio == null) return const [];
      final result = dataset.condominiAnagrafica
          .where((c) => c.idCondominio == selectedCondominio.id)
          .toList(growable: false);
      result.sort((left, right) {
        if (left.isActivePosition != right.isActivePosition) {
          return left.isActivePosition ? -1 : 1;
        }
        return left.nominativo.compareTo(right.nominativo);
      });
      return result;
    });

/// Tabelle appartenenti al condominio selezionato.
final tabelleBySelectedCondominioProvider = Provider<List<TabellaModel>>((ref) {
  final dataset = ref.watch(documentsRepositoryProvider);
  final selectedCondominio = ref.watch(selectedCondominioProvider);
  if (selectedCondominio == null) return const [];
  return dataset.tabelle
      .where((t) => t.idCondominio == selectedCondominio.id)
      .toList(growable: false);
});

/// Movimenti filtrati per condominio + ricerca testuale.
final movimentiBySelectedCondominioProvider = Provider<List<MovimentoModel>>((
  ref,
) {
  final dataset = ref.watch(documentsRepositoryProvider);
  final selectedCondominio = ref.watch(selectedCondominioProvider);
  final query = ref.watch(
    documentsUiProvider.select((s) => s.searchMovimenti.toLowerCase().trim()),
  );
  if (selectedCondominio == null) return const [];

  return dataset.movimenti
      .where((m) {
        if (m.idCondominio != selectedCondominio.id) return false;
        if (query.isEmpty) return true;
        return m.descrizione.toLowerCase().contains(query) ||
            m.codiceSpesa.toLowerCase().contains(query);
      })
      .toList(growable: false);
});

/// Condomino selezionato nel pannello anagrafica.
final selectedCondominoDocumentProvider = Provider<CondominoDocumentModel?>((
  ref,
) {
  final list = ref.watch(condominiBySelectedCondominioProvider);
  final selectedId = ref.watch(
    documentsUiProvider.select((s) => s.selectedCondominoId),
  );
  if (list.isEmpty) return null;
  if (selectedId == null) return list.first;
  for (final c in list) {
    if (c.id == selectedId) return c;
  }
  return list.first;
});

/// Snapshot preventivo/consuntivo dell'esercizio selezionato.
final selectedPreventivoSnapshotProvider = Provider<PreventivoSnapshotModel>((
  ref,
) {
  final dataset = ref.watch(documentsRepositoryProvider);
  final selectedCondominio = ref.watch(selectedCondominioProvider);
  if (selectedCondominio == null) {
    return const PreventivoSnapshotModel.empty();
  }
  final snapshot = dataset.preventivoSnapshot;
  if (snapshot.idCondominio == selectedCondominio.id || snapshot.isEmpty) {
    return snapshot;
  }
  return const PreventivoSnapshotModel.empty();
});

/// Vista morosita' dell'esercizio selezionato.
final selectedMorositaItemsProvider = Provider<List<MorositaItemModel>>((ref) {
  final dataset = ref.watch(documentsRepositoryProvider);
  final selectedCondominio = ref.watch(selectedCondominioProvider);
  if (selectedCondominio == null) return const [];
  return dataset.morositaItems
      .where((item) => item.idCondominio == selectedCondominio.id)
      .toList(growable: false);
});

/// Storico solleciti indicizzato per condomino (esercizio selezionato).
final selectedSollecitiByCondominoProvider =
    Provider<Map<String, List<SollecitoModel>>>((ref) {
      final condomini = ref.watch(condominiBySelectedCondominioProvider);
      final out = <String, List<SollecitoModel>>{};
      for (final item in condomini) {
        out[item.id] = item.solleciti;
      }
      return out;
    });

/// Archivio documentale dell'esercizio selezionato.
final documentiBySelectedCondominioProvider =
    Provider<List<DocumentoArchivioModel>>((ref) {
      final dataset = ref.watch(documentsRepositoryProvider);
      final selectedCondominio = ref.watch(selectedCondominioProvider);
      if (selectedCondominio == null) return const [];
      final rows = dataset.documentiArchivio
          .where((item) => item.idCondominio == selectedCondominio.id)
          .toList(growable: false);
      rows.sort((left, right) => right.createdAt.compareTo(left.createdAt));
      return rows;
    });

/// Documenti archivio legati a un movimento specifico.
final documentiByMovimentoProvider =
    Provider.family<List<DocumentoArchivioModel>, String>((ref, movimentoId) {
      final all = ref.watch(documentiBySelectedCondominioProvider);
      return all
          .where((item) => item.movimentoId == movimentoId)
          .toList(growable: false);
    });
