# Engineering Patterns (Condomio)

Documento operativo unico per i pattern concordati su Flutter, Core, Keycloak-service e Mongo.
Va considerato vincolante per nuovi sviluppi e refactor.

## 1. Principi non negoziabili

- Separazione netta tra UI, stato applicativo, dominio e accesso dati.
- Tenant isolation sempre applicata lato backend (non solo lato UI).
- Regole di ruolo applicate sia FE che BE.
- Flussi business completi end-to-end: no funzionalita' "a meta'".
- Errori leggibili per utente, dettagli tecnici solo per debug.

## 2. Pattern Flutter (feature-first + Riverpod)

Struttura base per feature:

```text
lib/features/<feature_name>/
  presentation/   # page/widgets/dialog
  application/    # notifier/provider/state
  domain/         # model/value object/rule
  data/           # api client/repository/mapper
```

Regole:
- `presentation` non contiene logica business.
- `application` orchestra use-case e stato.
- `domain` non dipende da Flutter UI.
- `data` parla con API/storage e mappa DTO <-> domain.

### Riverpod ottimizzato (rebuild minimi)

- Usare provider derivati per viste filtrate/sortate.
- Usare `select(...)` quando serve un campo specifico.
- Spezzare pagine grandi in widget piccoli `Consumer`.
- Stato locale effimero nel widget, stato condiviso nei provider.
- Evitare refresh manuali "a cascata": aggiornare stato una sola volta e derivare il resto.

## 3. Pattern UI/UX

- Layout responsive desktop/mobile senza overflow.
- Azioni sensibili visibili solo ai ruoli corretti.
- Testi utente selezionabili dove utile (diagnostica, dettagli, logiche di calcolo).
- Messaggi business chiari: niente errori tecnici grezzi in UI finale.
- In caso di errore tecnico complesso, fornire un dettaglio copiabile.

## 4. Pattern Backend Core

Layer obbligatori:
- `controller`: endpoint e mapping input/output.
- `service`: regole business e orchestrazione.
- `repository`: query Mongo e update mirati.
- `document`: modello persistito.
- `controller/model`: resource DTO esposte verso FE.

Regole:
- Validazione centralizzata tramite librerie `validationhandler` e `errorhandler`.
- Nessuna logica business complessa nel controller.
- Security e guard dominio prima delle mutazioni.
- Commenti esplicativi su blocchi non banali (perche', non cosa ovvia).

## 5. Security & accessi

- Flutter chiama solo `core` (mai direttamente `keycloak-service`).
- `core` chiama `keycloak-service` via OpenFeign + discovery.
- Operazioni admin-only protette FE + BE.
- Oltre al ruolo: verifica pertinenza tenant/esercizio su ogni mutazione.
- Audit per operazioni sensibili (chi, cosa, target, quando).

## 6. Mongo model & performance

Modello atteso:
- `condominio` (root stabile)
- `esercizio` (contesto operativo)
- `condomino_root` (profilo stabile)
- `condomino` (posizione per esercizio, read-model denormalizzato)

Linee guida:
- Scrittura consistente su source-of-truth.
- Denormalizzazione mirata per query calde senza `$lookup` nel path operativo.
- Indici costruiti sui pattern reali di accesso.
- Evitare indici ambigui o incompatibili col server Mongo in uso.

## 7. Scritture e atomicita'

- Se modifica tocca un singolo documento: preferire update mirato (`Query + Update`) al save completo.
- Se coinvolge piu' documenti con invarianti condivise: usare transazione.
- Recompute completo solo quando necessario; altrimenti delta update.
- Nessuna doppia chiamata FE per la stessa operazione business.

## 8. Errori e diagnosi

- Mappare errori backend in codici business stabili.
- UI mostra messaggi orientati all'azione.
- Log tecnici completi lato backend.
- Su FE: dettaglio tecnico copiabile solo dove serve troubleshooting.

## 9. Definition of Done per feature

Una feature e' chiusa solo se:
- flusso completo FE+BE funzionante;
- sicurezza ruolo + tenant verificata;
- stato Riverpod coerente senza refresh manuali inutili;
- UX responsive (web/desktop/mobile) senza overflow;
- roadmap aggiornata;
- commenti/documentazione allineati.
