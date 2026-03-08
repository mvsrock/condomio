import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scope di refresh dati per l'esercizio attivo.
///
/// Viene usato come piccolo event bus Riverpod per riallineare i moduli che
/// tengono cache locali dello stesso esercizio (`Anagrafica`, `Documenti`, ...).
/// In questo modo evitiamo refresh globali e rebuild inutili dopo una write.
enum ExerciseRefreshScope {
  registryItems,
  documentsExercise,
  documentsCondomini,
  documentsMovimenti,
  documentsTabelle,
}

class ExerciseRefreshEvent {
  const ExerciseRefreshEvent({
    required this.revision,
    required this.exerciseId,
    required this.scopes,
  });

  const ExerciseRefreshEvent.idle()
    : revision = 0,
      exerciseId = null,
      scopes = const <ExerciseRefreshScope>{};

  final int revision;
  final String? exerciseId;
  final Set<ExerciseRefreshScope> scopes;

  bool appliesToExercise(String? selectedExerciseId) {
    if (selectedExerciseId == null || selectedExerciseId.isEmpty) {
      return false;
    }
    return exerciseId == selectedExerciseId && scopes.isNotEmpty;
  }

  bool hasScope(ExerciseRefreshScope scope) => scopes.contains(scope);
}

class ExerciseRefreshNotifier extends StateNotifier<ExerciseRefreshEvent> {
  ExerciseRefreshNotifier() : super(const ExerciseRefreshEvent.idle());

  void publish({
    required String exerciseId,
    required Set<ExerciseRefreshScope> scopes,
  }) {
    if (exerciseId.isEmpty || scopes.isEmpty) {
      return;
    }
    state = ExerciseRefreshEvent(
      revision: state.revision + 1,
      exerciseId: exerciseId,
      scopes: scopes,
    );
  }
}

final exerciseRefreshProvider =
    StateNotifierProvider<ExerciseRefreshNotifier, ExerciseRefreshEvent>(
      (ref) => ExerciseRefreshNotifier(),
    );
