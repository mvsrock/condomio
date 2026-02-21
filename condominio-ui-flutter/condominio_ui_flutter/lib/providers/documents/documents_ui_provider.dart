import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/documents/condominio_document_model.dart';
import '../../models/documents/condomino_document_model.dart';
import '../../models/documents/movimento_model.dart';
import '../../models/documents/tabella_model.dart';
import 'documents_repository_provider.dart';

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
    StateNotifierProvider.autoDispose<DocumentsUiNotifier, DocumentsUiState>(
      (ref) => DocumentsUiNotifier(),
    );

/// Condominio selezionato.
final selectedCondominioProvider = Provider.autoDispose<CondominioDocumentModel?>((ref) {
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
    Provider.autoDispose<List<CondominoDocumentModel>>((ref) {
      final dataset = ref.watch(documentsRepositoryProvider);
      final selectedCondominio = ref.watch(selectedCondominioProvider);
      if (selectedCondominio == null) return const [];
      return dataset.condominiAnagrafica
          .where((c) => c.idCondominio == selectedCondominio.id)
          .toList(growable: false);
    });

/// Tabelle appartenenti al condominio selezionato.
final tabelleBySelectedCondominioProvider =
    Provider.autoDispose<List<TabellaModel>>((ref) {
      final dataset = ref.watch(documentsRepositoryProvider);
      final selectedCondominio = ref.watch(selectedCondominioProvider);
      if (selectedCondominio == null) return const [];
      return dataset.tabelle
          .where((t) => t.idCondominio == selectedCondominio.id)
          .toList(growable: false);
    });

/// Movimenti filtrati per condominio + ricerca testuale.
final movimentiBySelectedCondominioProvider =
    Provider.autoDispose<List<MovimentoModel>>((ref) {
      final dataset = ref.watch(documentsRepositoryProvider);
      final selectedCondominio = ref.watch(selectedCondominioProvider);
      final query = ref.watch(
        documentsUiProvider.select((s) => s.searchMovimenti.toLowerCase().trim()),
      );
      if (selectedCondominio == null) return const [];

      return dataset.movimenti.where((m) {
        if (m.idCondominio != selectedCondominio.id) return false;
        if (query.isEmpty) return true;
        return m.descrizione.toLowerCase().contains(query) ||
            m.codiceSpesa.toLowerCase().contains(query);
      }).toList(growable: false);
    });

/// Condomino selezionato nel pannello anagrafica.
final selectedCondominoDocumentProvider =
    Provider.autoDispose<CondominoDocumentModel?>((ref) {
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
