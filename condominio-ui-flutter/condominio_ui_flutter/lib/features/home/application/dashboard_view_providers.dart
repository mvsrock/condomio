import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../documents/application/documents_ui_notifier.dart';
import '../../documents/domain/morosita_item_model.dart';
import '../../documents/data/documents_repository_provider.dart';
import '../../registry/application/condomini_notifier.dart';

/// Riga timeline movimenti recenti.
class DashboardRecentMovimento {
  const DashboardRecentMovimento({
    required this.codiceSpesa,
    required this.descrizione,
    required this.importo,
    required this.date,
  });

  final String codiceSpesa;
  final String descrizione;
  final double importo;
  final DateTime date;
}

/// Riga timeline versamenti recenti.
class DashboardRecentVersamento {
  const DashboardRecentVersamento({
    required this.nominativo,
    required this.descrizione,
    required this.importo,
    required this.date,
  });

  final String nominativo;
  final String descrizione;
  final double importo;
  final DateTime date;
}

/// Riga timeline solleciti recenti.
class DashboardRecentSollecito {
  const DashboardRecentSollecito({
    required this.nominativo,
    required this.titolo,
    required this.canale,
    required this.createdAt,
    required this.automatico,
  });

  final String nominativo;
  final String titolo;
  final String canale;
  final DateTime createdAt;
  final bool automatico;
}

/// KPI sintetici della dashboard operativa.
class DashboardKpi {
  const DashboardKpi({
    required this.posizioniTotali,
    required this.morosiTotali,
    required this.praticheSollecitato,
    required this.praticheLegale,
    required this.debitoScadutoTotale,
    required this.residuoCondominio,
    required this.totalePreventivo,
    required this.totaleConsuntivo,
    required this.deltaBudget,
    required this.rateScadenza7,
    required this.rateScadenza15,
    required this.rateScadenza30,
  });

  final int posizioniTotali;
  final int morosiTotali;
  final int praticheSollecitato;
  final int praticheLegale;
  final double debitoScadutoTotale;
  final double residuoCondominio;
  final double totalePreventivo;
  final double totaleConsuntivo;
  final double deltaBudget;
  final int rateScadenza7;
  final int rateScadenza15;
  final int rateScadenza30;
}

final dashboardKpiProvider = Provider<DashboardKpi>((ref) {
  final exercise = ref.watch(selectedManagedCondominioProvider);
  final morosita = ref.watch(selectedMorositaItemsProvider);
  final snapshot = ref.watch(selectedPreventivoSnapshotProvider);
  final condomini = ref.watch(condominiBySelectedCondominioProvider);
  final now = DateTime.now().toUtc();

  int due7 = 0;
  int due15 = 0;
  int due30 = 0;

  for (final condomino in condomini) {
    for (final rata in condomino.config.rate) {
      final scadenza = rata.scadenza;
      if (scadenza == null) continue;
      final diff = scadenza.difference(now).inDays;
      if (diff < 0) continue;
      if (diff <= 7) due7++;
      if (diff <= 15) due15++;
      if (diff <= 30) due30++;
    }
  }

  final morosi = morosita.where((item) => item.hasDebitoScaduto).toList();
  final praticheSollecitate = morosita
      .where((item) => item.praticaStato == MorositaStatoUi.sollecitato)
      .length;
  final praticheLegali = morosita
      .where((item) => item.praticaStato == MorositaStatoUi.legale)
      .length;
  final debitoScaduto = morosi.fold<double>(
    0,
    (sum, item) => sum + item.debitoScaduto,
  );

  return DashboardKpi(
    posizioniTotali: condomini.length,
    morosiTotali: morosi.length,
    praticheSollecitato: praticheSollecitate,
    praticheLegale: praticheLegali,
    debitoScadutoTotale: debitoScaduto,
    residuoCondominio: exercise?.residuo ?? 0,
    totalePreventivo: snapshot.totalePreventivo,
    totaleConsuntivo: snapshot.totaleConsuntivo,
    deltaBudget: snapshot.totaleDelta,
    rateScadenza7: due7,
    rateScadenza15: due15,
    rateScadenza30: due30,
  );
});

final dashboardRecentMovimentiProvider =
    Provider<List<DashboardRecentMovimento>>((ref) {
      final source = ref.watch(movimentiBySelectedCondominioProvider);
      final rows = source
          .map(
            (movimento) => DashboardRecentMovimento(
              codiceSpesa: movimento.codiceSpesa,
              descrizione: movimento.descrizione,
              importo: movimento.importo,
              date: movimento.date,
            ),
          )
          .toList(growable: false);
      rows.sort((left, right) => right.date.compareTo(left.date));
      return rows.take(5).toList(growable: false);
    });

final dashboardRecentVersamentiProvider =
    Provider<List<DashboardRecentVersamento>>((ref) {
      final condomini = ref.watch(condominiBySelectedCondominioProvider);
      final rows = <DashboardRecentVersamento>[];
      for (final condomino in condomini) {
        for (final versamento in condomino.versamenti) {
          rows.add(
            DashboardRecentVersamento(
              nominativo: condomino.nominativo,
              descrizione: versamento.descrizione,
              importo: versamento.importo,
              date: versamento.date,
            ),
          );
        }
      }
      rows.sort((left, right) => right.date.compareTo(left.date));
      return rows.take(5).toList(growable: false);
    });

final dashboardRecentSollecitiProvider =
    Provider<List<DashboardRecentSollecito>>((ref) {
      final condomini = ref.watch(condominiBySelectedCondominioProvider);
      final rows = <DashboardRecentSollecito>[];
      for (final condomino in condomini) {
        for (final sollecito in condomino.solleciti) {
          final createdAt = sollecito.createdAt;
          if (createdAt == null) continue;
          rows.add(
            DashboardRecentSollecito(
              nominativo: condomino.nominativo,
              titolo: sollecito.titolo,
              canale: sollecito.canale,
              createdAt: createdAt,
              automatico: sollecito.automatico,
            ),
          );
        }
      }
      rows.sort((left, right) => right.createdAt.compareTo(left.createdAt));
      return rows.take(5).toList(growable: false);
    });

/// Mostra se i provider principali anagrafica/documenti stanno caricando.
final dashboardDataLoadingProvider = Provider<bool>((ref) {
  final registryLoading = ref.watch(condominiIsLoadingProvider);
  final documentsLoading = ref.watch(documentsIsLoadingProvider);
  return registryLoading || documentsLoading;
});
