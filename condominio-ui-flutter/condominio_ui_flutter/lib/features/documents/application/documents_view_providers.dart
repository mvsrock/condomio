import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/movimento_model.dart';
import '../domain/condomino_document_model.dart';
import 'documents_ui_notifier.dart';

/// Riga di dettaglio che rappresenta la quota di un singolo movimento
/// attribuita a un condomino.
class DocumentsCondominoQuotaSpesaRow {
  const DocumentsCondominoQuotaSpesaRow({
    required this.codiceSpesa,
    required this.descrizione,
    required this.data,
    required this.importo,
    required this.importoMovimento,
    required this.tipoRiparto,
    required this.ripartizioneTabelle,
  });

  final String codiceSpesa;
  final String descrizione;
  final DateTime data;
  final double importo;
  final double importoMovimento;
  final MovimentoRipartoTipo tipoRiparto;
  final List<RipartizioneTabellaModel> ripartizioneTabelle;

  double get incidenzaPercentuale {
    if (importoMovimento == 0) {
      return 0;
    }
    return (importo / importoMovimento) * 100;
  }
}

/// Totale aggregato per codice spesa nel dettaglio del condomino.
class DocumentsCondominoQuotaByCodiceRow {
  const DocumentsCondominoQuotaByCodiceRow({
    required this.codiceSpesa,
    required this.importo,
  });

  final String codiceSpesa;
  final double importo;
}

/// Quote analitiche di uno specifico condomino, ricavate dai movimenti del
/// condominio selezionato.
final documentsCondominoQuoteSpeseProvider =
    Provider.family<List<DocumentsCondominoQuotaSpesaRow>, String>((
      ref,
      condominoId,
    ) {
      final movimenti = ref.watch(movimentiBySelectedCondominioProvider);
      final rows = <DocumentsCondominoQuotaSpesaRow>[];

      for (final movimento in movimenti) {
        for (final quota in movimento.ripartizioneCondomini) {
          if (quota.idCondomino != condominoId) continue;
          rows.add(
            DocumentsCondominoQuotaSpesaRow(
              codiceSpesa: movimento.codiceSpesa,
              descrizione: movimento.descrizione,
              data: movimento.date,
              importo: quota.importo,
              importoMovimento: movimento.importo,
              tipoRiparto: movimento.tipoRiparto,
              ripartizioneTabelle: movimento.ripartizioneTabelle,
            ),
          );
        }
      }

      rows.sort((left, right) => right.data.compareTo(left.data));
      return rows;
    });

/// Aggregazione per codice spesa delle quote analitiche del condomino.
final documentsCondominoQuoteByCodiceProvider =
    Provider.family<List<DocumentsCondominoQuotaByCodiceRow>, String>((
      ref,
      condominoId,
    ) {
      final rows = ref.watch(documentsCondominoQuoteSpeseProvider(condominoId));
      final byCodice = <String, double>{};

      for (final row in rows) {
        final code = row.codiceSpesa.trim();
        if (code.isEmpty) continue;
        byCodice[code] = (byCodice[code] ?? 0) + row.importo;
      }

      final result = byCodice.entries
          .map(
            (entry) => DocumentsCondominoQuotaByCodiceRow(
              codiceSpesa: entry.key,
              importo: entry.value,
            ),
          )
          .toList(growable: false);
      result.sort((left, right) => left.codiceSpesa.compareTo(right.codiceSpesa));
      return result;
    });

/// Storico versamenti ordinato dal più recente al più vecchio.
final documentsCondominoVersamentiProvider =
    Provider.family<List<VersamentoModel>, String>((ref, condominoId) {
      final condomini = ref.watch(condominiBySelectedCondominioProvider);
      for (final condomino in condomini) {
        if (condomino.id != condominoId) continue;
        final sorted = List<VersamentoModel>.from(
          condomino.versamenti,
          growable: false,
        );
        sorted.sort((left, right) => right.date.compareTo(left.date));
        return sorted;
      }
      return const [];
    });

/// Quote analitiche del condomino attualmente selezionato in UI.
final selectedCondominoQuoteSpeseProvider =
    Provider<List<DocumentsCondominoQuotaSpesaRow>>((ref) {
      final selectedCondomino = ref.watch(selectedCondominoDocumentProvider);
      if (selectedCondomino == null) return const [];
      return ref.watch(documentsCondominoQuoteSpeseProvider(selectedCondomino.id));
    });

/// Totali aggregati per codice spesa del condomino selezionato.
final selectedCondominoQuoteByCodiceProvider =
    Provider<List<DocumentsCondominoQuotaByCodiceRow>>((ref) {
      final selectedCondomino = ref.watch(selectedCondominoDocumentProvider);
      if (selectedCondomino == null) return const [];
      return ref.watch(documentsCondominoQuoteByCodiceProvider(selectedCondomino.id));
    });

/// Storico versamenti ordinato del condomino selezionato.
final selectedCondominoVersamentiProvider =
    Provider<List<VersamentoModel>>((ref) {
      final selectedCondomino = ref.watch(selectedCondominoDocumentProvider);
      if (selectedCondomino == null) return const [];
      return ref.watch(documentsCondominoVersamentiProvider(selectedCondomino.id));
    });
