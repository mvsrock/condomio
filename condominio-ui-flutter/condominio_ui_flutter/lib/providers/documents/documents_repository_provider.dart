import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/documents/condominio_document_model.dart';
import '../../models/documents/condomino_document_model.dart';
import '../../models/documents/movimento_model.dart';
import '../../models/documents/tabella_model.dart';

/// Contenitore dati modulo "Documenti".
///
/// In questa fase usa dati fake statici per prototipazione UI.
class DocumentsDataset {
  const DocumentsDataset({
    required this.condomini,
    required this.condominiAnagrafica,
    required this.movimenti,
    required this.tabelle,
  });

  final List<CondominioDocumentModel> condomini;
  final List<CondominoDocumentModel> condominiAnagrafica;
  final List<MovimentoModel> movimenti;
  final List<TabellaModel> tabelle;
}

/// Provider repository fake.
///
/// Da sostituire in seguito con chiamata backend reale.
final documentsRepositoryProvider = Provider<DocumentsDataset>((ref) {
  final condomini = <CondominioDocumentModel>[
    const CondominioDocumentModel(
      id: 'cond-001',
      version: 1,
      label: 'Condominio Aurora',
      anno: 2026,
      residuo: 1450.8,
      configurazioniSpesa: [
        ConfigurazioneSpesaModel(
          codice: 'SPESE_GESTIONE',
          tabelle: [
            TabellaPercentualeModel(
              codice: 'TAB-A',
              descrizione: 'Scala A',
              percentuale: 60,
            ),
            TabellaPercentualeModel(
              codice: 'TAB-B',
              descrizione: 'Scala B',
              percentuale: 40,
            ),
          ],
        ),
      ],
    ),
    const CondominioDocumentModel(
      id: 'cond-002',
      version: 1,
      label: 'Condominio Riviera',
      anno: 2026,
      residuo: -320.5,
      configurazioniSpesa: [
        ConfigurazioneSpesaModel(
          codice: 'RISCALDAMENTO',
          tabelle: [
            TabellaPercentualeModel(
              codice: 'TAB-R1',
              descrizione: 'Corpo R1',
              percentuale: 100,
            ),
          ],
        ),
      ],
    ),
  ];

  final tabelle = <TabellaModel>[
    const TabellaModel(
      id: 'tab-1',
      version: 1,
      codice: 'TAB-A',
      descrizione: 'Tabella Scala A',
      idCondominio: 'cond-001',
    ),
    const TabellaModel(
      id: 'tab-2',
      version: 1,
      codice: 'TAB-B',
      descrizione: 'Tabella Scala B',
      idCondominio: 'cond-001',
    ),
    const TabellaModel(
      id: 'tab-3',
      version: 1,
      codice: 'TAB-R1',
      descrizione: 'Tabella Corpo R1',
      idCondominio: 'cond-002',
    ),
  ];

  final condominiAnagrafica = <CondominoDocumentModel>[
    CondominoDocumentModel(
      id: 'cg-001',
      version: 3,
      nome: 'Mario',
      cognome: 'Rossi',
      idCondominio: 'cond-001',
      email: 'mario.rossi@example.com',
      cellulare: '+39 333 1111111',
      scala: 'A',
      interno: 10,
      anno: 2026,
      config: const CondominoConfigModel(
        tabelle: [
          TabellaConfigModel(codiceTabella: 'TAB-A', numeratore: 125, denominatore: 1000),
        ],
        rate: [],
      ),
      versamenti: [
        VersamentoModel(
          descrizione: 'Acconto febbraio',
          importo: 350,
          date: DateTime.utc(2026, 2, 5),
          insertedAt: DateTime.utc(2026, 2, 5, 10, 10),
          ripartizioneTabelle: const [
            RipartizioneModel(codice: 'TAB-A', descrizione: 'Scala A', importo: 350),
          ],
        ),
      ],
      residuo: 120.5,
    ),
    CondominoDocumentModel(
      id: 'cg-002',
      version: 2,
      nome: 'Lucia',
      cognome: 'Bianchi',
      idCondominio: 'cond-001',
      email: 'lucia.bianchi@example.com',
      cellulare: '+39 333 2222222',
      scala: 'B',
      interno: 4,
      anno: 2026,
      config: const CondominoConfigModel(
        tabelle: [
          TabellaConfigModel(codiceTabella: 'TAB-B', numeratore: 95, denominatore: 1000),
        ],
        rate: [],
      ),
      versamenti: const [],
      residuo: 890,
    ),
    CondominoDocumentModel(
      id: 'cg-003',
      version: 1,
      nome: 'Paolo',
      cognome: 'Verdi',
      idCondominio: 'cond-002',
      email: 'paolo.verdi@example.com',
      cellulare: '+39 333 3333333',
      scala: 'R1',
      interno: 2,
      anno: 2026,
      config: const CondominoConfigModel(
        tabelle: [
          TabellaConfigModel(codiceTabella: 'TAB-R1', numeratore: 70, denominatore: 1000),
        ],
        rate: [],
      ),
      versamenti: [
        VersamentoModel(
          descrizione: 'Saldo gennaio',
          importo: 500,
          date: DateTime.utc(2026, 1, 20),
          insertedAt: DateTime.utc(2026, 1, 20, 9, 20),
          ripartizioneTabelle: const [
            RipartizioneModel(codice: 'TAB-R1', descrizione: 'Corpo R1', importo: 500),
          ],
        ),
      ],
      residuo: -320.5,
    ),
  ];

  final movimenti = <MovimentoModel>[
    MovimentoModel(
      id: 'mv-001',
      version: 1,
      idCondominio: 'cond-001',
      codiceSpesa: 'ASSIC',
      descrizione: 'Polizza annuale',
      importo: 1200,
      date: DateTime.utc(2026, 2, 1),
      insertedAt: DateTime.utc(2026, 2, 1, 8, 45),
      ripartizioneTabelle: const [
        RipartizioneTabellaModel(codice: 'TAB-A', descrizione: 'Scala A', importo: 720),
        RipartizioneTabellaModel(codice: 'TAB-B', descrizione: 'Scala B', importo: 480),
      ],
    ),
    MovimentoModel(
      id: 'mv-002',
      version: 1,
      idCondominio: 'cond-002',
      codiceSpesa: 'MANUT',
      descrizione: 'Manutenzione ascensore',
      importo: 500,
      date: DateTime.utc(2026, 1, 15),
      insertedAt: DateTime.utc(2026, 1, 15, 11, 30),
      ripartizioneTabelle: const [
        RipartizioneTabellaModel(codice: 'TAB-R1', descrizione: 'Corpo R1', importo: 500),
      ],
    ),
  ];

  return DocumentsDataset(
    condomini: condomini,
    condominiAnagrafica: condominiAnagrafica,
    movimenti: movimenti,
    tabelle: tabelle,
  );
});
