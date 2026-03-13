# Condomio Flutter - Guida Completa Schermate, Modali, Pulsanti e Flussi

## 1) Scopo del file

Questo documento descrive in modo operativo:
- tutte le pagine principali dell'app Flutter
- tutte le modali/dialog piu importanti
- i pulsanti principali e cosa innescano
- il flusso tecnico dietro ogni azione (UI -> notifier/provider -> endpoint -> refresh)
- vincoli di ruolo (admin/non-admin) e vincoli esercizio (aperto/chiuso)

Obiettivo: avere una mappa unica, leggibile, utile sia per uso funzionale sia per debug.

---

## 2) Flusso di avvio e autenticazione

### 2.1 Entry point
File: `lib/main.dart`

1. Logga configurazione attiva (`APP_PROFILE`, server Keycloak, redirect URI).
2. Se web, avvia diagnostica URL startup.
3. Avvia `ProviderScope` + `MainApp`.

### 2.2 Bootstrap auth
File: `lib/app/main_app.dart`, `lib/app/app_startup.dart`

Flusso reale:
1. `MainApp` monta `MaterialApp.router`.
2. Dopo primo frame, `AppStartupCoordinator.initializeAuth()`:
   - inizializza servizio Keycloak
   - se trova `code` in URL (callback OAuth2) esegue token exchange
   - altrimenti se sessione valida, ripristina auth
   - altrimenti resta non autenticato

### 2.3 Routing e redirect
File: `lib/app/app_router.dart`

Route top-level:
- `/login`
- `/loading`
- `/error`
- `/condominio-loading`
- `/select-condominio`
- shell autenticata `/home/*`

Branch `/home/*`:
- `/home/dashboard`
- `/home/map`
- `/home/anagrafica`
- `/home/session`
- `/home/documents`
- `/home/portal`

Regole principali:
1. Se non autenticato -> `/login`
2. Se autenticazione in corso -> `/loading`
3. Dopo login, obbligo scelta contesto (`/select-condominio`) finche non c'e esercizio selezionato
4. Non-admin:
   - default home = `/home/portal`
   - blocco redirect da dashboard/map/anagrafica/documents verso `/home/portal`
5. Admin:
   - default home = `/home/dashboard`
   - se prova `/home/portal`, redirect a dashboard

Nota importante: non c'e `SelectionArea` globale nella shell route.
La selezione testo e locale nei punti utili (debug/report/dettagli), per evitare errori runtime su pagine dinamiche.

---

## 3) Shell Home comune

File: `lib/features/home/presentation/pages/home_screen.dart`

## 3.1 Header alto
File: `home_header.dart`

Elementi:
- brand "Condominio"
- label condominio attivo (solo informativa, non cliccabile)
- icona dedicata `swap_horiz` per cambio esercizio (`/select-condominio`)
- badge "Amministratore" se ruolo admin
- logout

Comportamento responsive:
- layout compatto su larghezze piccole
- su mobile resta la sola icona di cambio esercizio per non saturare lo spazio

### 3.2 Navigazione

Admin vede menu:
- Dashboard
- Mappa
- Anagrafica
- Sessione

Non-admin vede menu:
- Portale
- Sessione

Fonte regole: `home_navigation_provider.dart`.

### 3.3 Banner esercizio chiuso

Se esercizio e chiuso, appare banner rosso/amber: sola lettura.

---

## 4) Pagina Login

Route: `/login`
File: `lib/features/auth/presentation/pages/login_screen.dart`
Widget card: `login_hero_card.dart`

Elementi UI:
- titolo app "Condominio"
- testo accesso
- pulsante `Accedi`

Azione bottone:
1. `onLoginPressed` -> `AuthNotifier.login()`
2. avvio flusso OAuth2 (redirect Keycloak)
3. ritorno su callback e chiusura flow in startup

Stati:
- durante loading: bottone disabilitato, label `Accesso in corso...`

---

## 5) Pagina Selezione Condominio/Esercizio

Route: `/select-condominio`
File: `features/condominio_selection/presentation/pages/condominio_selection_page.dart`

Questa pagina e obbligatoria dopo login.

## 5.1 Blocchi principali

1. Lista esercizi assegnati
2. Creazione nuova entita:
   - Nuovo esercizio (se esiste almeno un condominio root)
   - Nuovo condominio
3. Overview strip con contatori (condomini, aperti, chiusi, selezionato)
4. Pulsanti appbar: Logout, Aggiorna

### 5.2 Pulsanti e azioni

- `Continua`
  - naviga a `/home/dashboard` (admin) o redirect successivo da router
- `Chiudi esercizio`
  - conferma modale
  - chiamata `closeSelectedExercise()` -> endpoint `POST /esercizi/{id}/close`
- `Crea condominio`
  - valida form
  - `createCondominio(...)` -> `POST /condomini`
- `Crea esercizio`
  - valida form (root, gestione, anno, saldo)
  - `createExercise(...)` -> `POST /condomini/{rootId}/esercizi?carryOverBalances=...`

### 5.3 Regole funzionali importanti

- solo admin puo creare condominio/esercizio
- un nuovo esercizio nella stessa gestione richiede chiusura del precedente aperto
- `carryOverBalances` permette riporto saldo finale nel nuovo esercizio

---

## 6) Dashboard (admin)

Route: `/home/dashboard`
File: `features/home/presentation/pages/dashboard_page.dart`

## 6.1 Struttura

1. Header contesto esercizio con:
   - nome condominio/gestione/anno
   - stato `Esercizio aperto` o `chiuso`
   - pulsante `Aggiorna dati` (`Cambia esercizio` e' nell'header principale via icona)
2. KPI card:
   - Residuo condominio
   - Budget delta
   - Morosita scaduta
   - Scadenze rate (7/15/30)
3. Alert panel
4. Timeline recenti:
   - ultime spese
   - ultimi versamenti
   - ultimi solleciti
5. Quick actions in basso

## 6.2 Significato KPI rate 7/15/30

Fonte: `dashboard_view_providers.dart`

`rateScadenza7/15/30` = conteggio rate con scadenza entro rispettivamente 7, 15, 30 giorni (future, non gia scadute).

Dettaglio calcolo:
- `diff = rata.scadenza - nowUtc` (giorni)
- se `diff < 0`: esclusa (gia scaduta)
- se `diff <= 7`: incrementa `7gg`
- se `diff <= 15`: incrementa `15gg`
- se `diff <= 30`: incrementa `30gg`

Nota importante:
- i bucket sono cumulativi, non esclusivi (una rata a +5gg conta in 7, 15 e 30).

## 6.3 Quando si aggiornano davvero questi KPI (tempo reale)

Modello aggiornamento attuale: **pull su richiesta**, non push realtime (no websocket).

In pratica i KPI si aggiornano quando avviene uno di questi eventi:
- caricamento iniziale del dataset documenti per esercizio (`loadForSelectedCondominio`)
- cambio esercizio selezionato
- click esplicito su `Aggiorna`
- operazione che salva dati e poi fa refresh (es. nuova spesa, modifica quote, versamento, update stato morosita)

Quindi:
- se apri pagina e i dati sono appena stati ricaricati, vedi valori aggiornati
- se i dati cambiano altrove e non c'e un refresh locale, non si aggiornano da soli

### 6.3.1 Chi calcola cosa

- KPI dashboard 7/15/30: calcolo lato Flutter provider (`dashboardKpiProvider`)
- KPI morosita/aging (`0-30`, `31-60`, `...`): calcolo lato backend (`MorositaService.computeDebt`)
- Flutter visualizza i dati backend ricevuti da `GET /morosita?idCondominio=...`

### 6.4 Pulsanti quick actions

- `Nuova spesa` -> apre area documenti
- `Budget e consuntivo` -> area documenti
- `Morosita e solleciti` -> area documenti
- `Anagrafica e subentri` -> area anagrafica
- `Automazioni` (solo admin, esercizio aperto) -> apre modale automazioni
- `Coda job` -> modale coda job

### 6.5 Modale "Automazioni"

File: `home/presentation/dialogs/dashboard_automation_dialog.dart`

Contiene 2 macro-aree:
1. Reminder/Solleciti automatici
   - `Accoda reminder`
   - `Accoda auto-solleciti`
   - `Apri coda job`
2. Import guidato piano rate da CSV
   - `Carica esempio`
   - `Valida e anteprima`
   - `Applica piano rate`

Effetto tecnico:
- usa `asyncJobsProvider` per accodare job backend
- usa `documentsDataProvider.applyRatePlan(...)` per bulk rate plan

---

## 7) Mappa (admin)

Route: `/home/map`
File: `features/map/presentation/pages/map_page.dart`

Elementi:
- pulsante `Aggiorna posizione`
- status testo
- mappa OpenLayers con marker

Flusso:
- `MapNotifier.refreshCurrentLocation()`
  - controlla GPS attivo
  - controlla permessi
  - legge posizione
  - aggiorna state center/marker

Nessuna chiamata backend core.

---

## 8) Anagrafica (admin + non-admin in forma limitata)

Route: `/home/anagrafica`
Container: `registry_tab_page.dart`

## 8.1 Modalita pagina

Admin vede switch:
- `Anagrafica`
- `Accessi`

Non-admin vede solo `Anagrafica`.

### 8.2 Modalita Anagrafica

File principali:
- `registry_page.dart`
- `registry_row.dart`
- `registry_condomino_pages.dart`
- `registry_position_dialogs.dart`

Funzioni disponibili:
- ricerca
- filtro mostra cessati
- ordinamento
- paginazione
- dettaglio condomino
- modifica condomino
- azioni posizione (cessa/subentra/elimina errore)

#### Pulsanti/azioni riga

- tap riga -> selezione corrente
- `Dettaglio` -> pagina dettaglio
- `Modifica` -> pagina edit (se permesso)

#### Pagina dettaglio condomino

Azioni in appbar (se edit consentito):
- `Modifica`
- menu azioni posizione:
  - `Cessa posizione`
  - `Registra subentro`
  - `Elimina se e errore`

#### Modale Cessazione posizione

Campi:
- data cessazione
- motivo

Submit -> `condominiProvider.notifier.cessaCondomino(...)` -> endpoint `POST /condomino/{id}/cessazione`

#### Modale Subentro

Campi:
- data subentro
- nome/cognome/email/telefono nuovo soggetto
- checkbox riporto saldo
- saldo iniziale se no riporto

Submit -> `subentraCondomino(...)` -> endpoint `POST /condomino/{id}/subentro`

#### Edit condomino

Sezioni:
1. Profilo condiviso (nome/cognome)
2. Contatti condivisi (email/telefono)
3. Posizione esercizio (unita, titolarita, saldo iniziale)
4. Accesso app condiviso (utente keycloak + ruolo)

Pulsante `Salva modifiche`:
- chiama callback `onSave` -> `condominiProvider.updateCondomino(...)`
- endpoint: `PATCH /condomino/{id}`

### 8.3 Modalita Accessi (solo admin)

File: `admin_users_page.dart`, `admin_users_sections.dart`, `admin_enable_access_dialog.dart`

Blocchi:
1. Form creazione condomino (anagrafica + accesso app opzionale)
2. Lista condomini e stato accesso app
3. Pulsante `Gestisci unita`

#### Form creazione condomino

Campi principali:
- Nome, Cognome
- Email (opzionale), Telefono (opzionale)
- Unita immobiliare (obbligatoria nel form)
- Saldo iniziale
- Residente
- opzioni accesso app:
  - associa utente app esistente
  - crea utenza app adesso
  - ruolo applicativo (solo se nuova utenza)

Pulsante `Crea condomino`:
1. opzionale create utente app via admin provider
2. create condomino via `condominiProvider.createCondomino(...)`

Endpoint coinvolti:
- utenti app: `/keycloak-admin/users` (tramite core)
- condomino: `PUT /condomino`

#### `Abilita accesso` da lista condomini

Apre modale `AdminEnableAccessDialog`:
- scelta tra utente esistente o nuovo utente
- eventuale ruolo su nuova utenza

Salvataggio finale aggiorna condomino (`PATCH /condomino/{id}`) con keycloak user id/username e ruolo.

#### Dialog Gestisci unita

Funzioni:
- creare unita (`Aggiungi`)
- aggiornare lista (`Aggiorna`)
- associare subito unita a condomino (opzionale)
- modificare unita
- eliminare unita
- vedere storico titolarita

Endpoint unita:
- `GET /unita-immobiliari?idCondominio=...`
- `POST /unita-immobiliari?idCondominio=...`
- `PUT /unita-immobiliari/{id}?idCondominio=...`
- `DELETE /unita-immobiliari/{id}?idCondominio=...`
- `GET /unita-immobiliari/{id}/titolarita?idCondominio=...`

---

## 9) Documenti (admin) + vista condomini

Route: `/home/documents`
File: `documents_page.dart` + widgets/dialog dedicati

La pagina ha due modalita:
- `Contabilita`
- `Condomini`

## 9.1 Header e barra azioni

Header mostra:
- residuo condominio
- posizioni
- movimenti
- documenti
- delta budget
- morosi
- chip esercizio chiuso se read-only

Azioni principali (Contabilita):
1. `Configura riparto`
2. `Nuova spesa`
3. `Nuova tabella`
4. `Preventivo`
5. `Morosita`
6. `Archivio`
7. `Report`
8. `Coda job`
9. `Aggiorna`

Regole abilitazione:
- scrittura solo admin e solo esercizio aperto
- letture consentite anche in read-only

## 9.2 Vista Contabilita

Desktop:
- pannello movimenti
- pannello tabelle

Mobile:
- tab `Condomini / Movimenti / Tabelle`

### Azioni movimenti

- tap movimento -> modale dettaglio riparto
- menu riga -> Modifica / Elimina

#### Modale dettaglio movimento

Mostra:
- descrizione, tipo riparto, importo
- assegnatario se riparto individuale
- ripartizione per tabella
- ripartizione per condomino
- pulsante `Gestisci allegati` (apre archivio filtrato movimento)

### Azioni tabelle

- menu riga tabella -> Modifica / Elimina

Gestione tabelle in uso:
- rinomina tabella in uso: conferma update automatico riferimenti
- eliminazione tabella in uso: dialog con 3 scelte
  - `Chiudi`
  - `Rimuovi automaticamente`
  - `Apri Configura riparto`

## 9.3 Vista Condomini

Pannello sinistro: elenco condomini.

Pannello destro (dettaglio condomino):
- quote spese aggregate e analitiche
- pulsante `Modifica quote`
- rate: aggiungi/modifica/elimina
- versamenti: aggiungi/modifica/elimina
- storico versamenti

Mobile:
- bottom sheet dettaglio condomino quando premi `Dettaglio`

### Modale "Perche questa quota"

Da dettaglio quote: spiega formula numerica tabella per tabella.

Mostra:
- importo movimento
- quota tabella
- millesimi (numeratore/denominatore)
- quota finale condomino
- quadratura totale

---

## 10) Modali Documenti - dettaglio per funzione

## 10.1 CRUD base (`documents_crud_dialogs.dart`)

1. Tabella form
   - campi: codice, descrizione
2. Movimento form
   - campi: codice spesa, tipo riparto, descrizione, importo
   - se individuale: selezione condomino destinatario
3. Versamento form
   - campi: descrizione, importo, rata opzionale
4. Rata form
   - campi: codice, descrizione, tipo, importo, scadenza
5. Dialog conferma elimina:
   - movimento
   - versamento
   - rata
   - tabella

## 10.2 Configurazioni riparto (`documents_config_dialogs.dart`)

### Configura riparto spese

- per ogni codice spesa definisci split percentuali su tabelle
- validazione:
  - codice spesa obbligatorio e univoco
  - almeno una tabella
  - no tabella duplicata
  - totale percentuali = 100
- checkbox `Ricostruisci storico`

### Modifica quote condomino

- per tabella: numeratore/denominatore
- health-check coerenza tra condomini stessa tabella
- se incoerente, conferma `Salva comunque` o `Torna a modificare`
- checkbox `Ricostruisci storico`

## 10.3 Preventivo (`documents_budget_dialogs.dart`)

- tabella preventivo/consuntivo/delta per codice+tabella
- preventivo editabile
- consuntivo read-only (calcolato)
- tasti: `Chiudi`, `Salva preventivo`

## 10.4 Morosita (`documents_morosita_dialogs.dart`)

Funzioni nella modale:
- riepilogo mora
- per condomino:
  - cambio `Stato pratica` (in bonis / sollecitato / legale)
  - `Registra sollecito`
  - espansione storico solleciti
- azione globale `Auto-solleciti`

Flussi:
- registra sollecito manuale -> aggiunge storico + imposta stato `sollecitato` se non legale
- auto-solleciti:
  - puo tornare risultato immediato (count)
  - o job accodato (job id)

### 10.4.1 "Posizioni in mora": cosa significa esattamente

Nella card riepilogo:
- `Posizioni in mora = overdueCount / rows.length`
- `overdueCount` = numero righe morosita con `hasDebitoScaduto = true`
- `hasDebitoScaduto` e vero quando `debitoScaduto > 0`

Tradotto:
- una posizione e "in mora" se ha almeno una quota scaduta ancora non incassata (anche parzialmente).

### 10.4.2 Chi e quando chiama `MorositaService.java`

`MorositaService` e invocato dal backend `core` tramite:
- `GET /morosita?idCondominio=...` (lista vista morosita)
- `PATCH /morosita/{condominoId}/stato` (cambio stato pratica)
- `POST /morosita/{condominoId}/solleciti` (registrazione sollecito)
- `POST /morosita/solleciti/automatici/{idCondominio}` (job/azione automatica)

Dal frontend:
- `DocumentsApiClient.fetchMorosita(...)` chiama `GET /morosita`
- questo metodo viene richiamato nei refresh del repository documenti (`includeMorosita: true`)
- la modale `Morosita e solleciti` usa `reloadMorositaItems()` dopo ogni modifica per aggiornare subito i numeri.

Sintesi operativa:
- i numeri in modale non sono statici: dopo un'azione valida, la UI richiede di nuovo i dati al backend e ricalcola il riepilogo.

## 10.5 Archivio documenti (`documents_archivio_dialogs.dart`)

Modalita:
- archivio esercizio completo
- allegati movimento (filtrato)

Funzioni:
- ricerca testuale
- filtro categoria
- toggle `Tutte le versioni`
- paginazione server-side (page/size)
- upload nuovo documento
- nuova versione documento
- elimina documento
- preview

### Upload nuovo documento

Flusso:
1. file picker
2. modale metadati:
   - titolo
   - categoria
   - collegamento movimento opzionale
   - descrizione
3. upload multipart

### Preview supportata

- PDF
- immagini
- testo/csv/json/xml
- Excel (`.xlsx`, `.xlsm`, ...)

Per Excel:
- selezione foglio
- griglia con header
- limite preview righe/colonne
- compat fix su stili numFmt non standard
- se errore, tasto `Copia dettaglio`

## 10.6 Report (`documents_reports_dialogs.dart`)

Funzioni:
- filtro condomino (estratto posizione)
- `Aggiorna report`
- `Accoda XLSX`
- `Accoda PDF`
- viste dati:
  - situazione contabile
  - consuntivo
  - riparto per tabella
  - morosita
  - estratti posizione
  - dettaglio quota condomino per tabella (se filtro condomino attivo)

Export:
- non scarica diretto dalla modale
- accoda job asincrono
- scarico da `Coda job`

---

## 11) Coda Job

Modale: `features/jobs/presentation/dialogs/async_jobs_dialog.dart`

Funzioni:
- lista job utente (o solo esercizio attivo)
- stato: queued/running/done/failed
- auto-refresh periodico mentre ci sono job attivi
- download output (quando disponibile)
- dettagli input/output/errore

Pulsanti:
- `Aggiorna`
- chip `Auto-refresh`
- `Scarica` su job completato con file
- `Chiudi`

Endpoint job:
- `GET /jobs`
- `POST /jobs/report-export`
- `POST /jobs/morosita/{idCondominio}/solleciti-automatici`
- `POST /jobs/morosita/{idCondominio}/reminder-scadenze`
- `GET /jobs/{jobId}/download`

---

## 12) Sessione token

Route: `/home/session`
File: `session_page.dart`

Mostra:
- Access Token (raw + json parsed)
- ID Token (raw + json parsed)
- Refresh Token (raw + json parsed)

Uso: diagnostica auth/claims/sessione.

---

## 13) Portale condomino (non-admin)

Route: `/home/portal`
File: `portal_page.dart`

Sezioni:
1. Header portale con contesto e pulsante `Aggiorna dati`
2. KPI personali:
   - residuo personale
   - scoperto rate
   - versamenti
   - spese imputate
3. Tabelle/liste:
   - rate
   - versamenti
   - spese imputate
   - documenti recenti

Azione documento:
- `Scarica documento` -> download file

Endpoint portale:
- `GET /portale/me?idCondominio=...`

---

## 14) Matrice permessi pratica (FE)

Admin + esercizio aperto:
- tutte le operazioni di scrittura abilitate

Admin + esercizio chiuso:
- sola lettura (pulsanti mutazione disabilitati)

Non-admin:
- route limitate (`/home/portal`, `/home/session`)
- niente dashboard/map/anagrafica/documents

Nota: oltre ai blocchi FE, la protezione vera deve stare anche su BE (ed e gia applicata nel progetto).

---

## 15) Eventi di refresh cross-modulo

File: `features/shared/application/exercise_refresh_provider.dart`

Quando una write in un modulo impatta altri dati, viene pubblicato evento con scope.

Esempio reale:
- crei/modifichi movimento in Documenti
- oltre al refresh documenti, viene pubblicato scope `registryItems`
- Anagrafica si riallinea senza refresh manuale totale

Questo evita UI incoerente e riduce rebuild inutili.

---

## 16) Mappa endpoint principale per feature (riassunto tecnico)

### Selezione condominio/esercizio
- `GET /esercizi`
- `GET /condomini`
- `POST /condomini`
- `POST /condomini/{rootId}/esercizi`
- `POST /esercizi/{id}/close`

### Anagrafica / posizioni
- `GET /condomino?idCondominio=...`
- `PUT /condomino`
- `PATCH /condomino/{id}`
- `DELETE /condomino/{id}`
- `POST /condomino/{id}/cessazione`
- `POST /condomino/{id}/subentro`

### Unita immobiliari
- `GET /unita-immobiliari?idCondominio=...`
- `POST /unita-immobiliari?idCondominio=...`
- `PUT /unita-immobiliari/{id}?idCondominio=...`
- `DELETE /unita-immobiliari/{id}?idCondominio=...`
- `GET /unita-immobiliari/{id}/titolarita?idCondominio=...`

### Accessi utenti app (via core facade)
- base path FE: `/keycloak-admin/*`
- utenti: `/users`, `/users/{id}/app-role`, `/users/{id}/add_groups`, ...

### Documenti / contabilita
- esercizio: `GET /esercizi/{id}`, `PATCH /esercizi/{id}`
- tabelle: `GET/POST/PATCH/DELETE /tabelle...`
- movimenti: `GET/POST/PATCH/DELETE /movimenti...`
- quote condomino: `PATCH /condomino/{id}`
- versamenti: `POST/PATCH/DELETE /condomino/{id}/versamenti...`
- rate: `POST/PATCH/DELETE /condomino/{id}/rate...`
- rebuild storico: `POST /movimenti/rebuild-storico/{idCondominio}`

### Preventivo / morosita / report
- `GET/PUT /preventivi/{idCondominio}`
- `GET /morosita?idCondominio=...`
- `PATCH /morosita/{condominoId}/stato`
- `POST /morosita/{condominoId}/solleciti`
- `POST /morosita/solleciti/automatici/{idCondominio}`
- `GET /reports/{idCondominio}`
- `GET /reports/{idCondominio}/export?format=...`

### Archivio documentale
- `GET /documenti` (anche paginato)
- `POST /documenti` (multipart)
- `POST /documenti/{id}/versioni`
- `DELETE /documenti/{id}`
- `GET /documenti/{id}/download`

### Job asincroni
- `GET /jobs`
- `POST /jobs/report-export`
- `POST /jobs/morosita/{idCondominio}/solleciti-automatici`
- `POST /jobs/morosita/{idCondominio}/reminder-scadenze`
- `GET /jobs/{jobId}/download`

### Portale condomino
- `GET /portale/me?idCondominio=...`

---

## 17) Flussi pratici "clicco -> cosa succede"

### 17.1 "Nuova spesa"
1. Click `Nuova spesa` in Documenti.
2. Apre modale movimento.
3. Submit -> `documentsDataProvider.createMovimento(...)`.
4. Chiamata `POST /movimenti`.
5. Refresh documenti (condominio+condomini+movimenti+preventivo+morosita+documenti).
6. Publish event refresh per anagrafica (`registryItems`).

### 17.2 "Modifica quote condomino"
1. Da Documenti vista Condomini -> `Modifica quote`.
2. Apre modale quote tabella.
3. Submit -> `updateCondominoQuoteTabelle` (`PATCH /condomino/{id}`).
4. Se checkbox storico attiva -> `POST /movimenti/rebuild-storico/{idCondominio}`.
5. Refresh dataset completo e anagrafica.

### 17.3 "Accoda PDF report"
1. Da modale Report -> `Accoda PDF`.
2. `asyncJobsProvider.queueReportExport(format: pdf)` -> `POST /jobs/report-export`.
3. Job in coda.
4. Da Coda job, quando `DONE` -> `Scarica`.

### 17.4 "Abilita accesso" in Accessi
1. Da lista condomini senza accesso -> `Abilita accesso`.
2. Modale: utente esistente o nuovo.
3. Se nuovo utente: crea su backend admin.
4. Aggiorna condomino con keycloak user e ruolo (`PATCH /condomino/{id}`).

---

## 18) Note operative utili

- Se un dato non appare subito, usa `Aggiorna` della sezione: quasi tutte le schermate hanno refresh dedicato.
- In esercizio chiuso l'app entra in sola lettura: i pulsanti mutazione si disabilitano.
- In Documenti, alcune azioni sono volutamente asincrone (report, auto-solleciti, reminder) e vanno monitorate in `Coda job`.
- In molte modali i testi sono selezionabili (utile per copia errori/debug).

---

## 19) Riferimento file principali

Routing e shell:
- `lib/app/app_router.dart`
- `lib/features/home/presentation/pages/home_screen.dart`

Login e startup:
- `lib/features/auth/presentation/pages/login_screen.dart`
- `lib/app/app_startup.dart`

Selezione contesto:
- `lib/features/condominio_selection/presentation/pages/condominio_selection_page.dart`

Dashboard:
- `lib/features/home/presentation/pages/dashboard_page.dart`
- `lib/features/home/presentation/dialogs/dashboard_automation_dialog.dart`

Anagrafica:
- `lib/features/registry/presentation/pages/registry_tab_page.dart`
- `lib/features/registry/presentation/pages/registry_page.dart`
- `lib/features/registry/presentation/pages/registry_condomino_pages.dart`
- `lib/features/registry/presentation/dialogs/registry_position_dialogs.dart`

Accessi:
- `lib/features/admin/presentation/pages/admin_users_page.dart`
- `lib/features/admin/presentation/dialogs/admin_enable_access_dialog.dart`

Documenti:
- `lib/features/documents/presentation/pages/documents_page.dart`
- `lib/features/documents/presentation/widgets/documents_panels.dart`
- `lib/features/documents/presentation/dialogs/documents_*.dart`

Portale:
- `lib/features/portal/presentation/pages/portal_page.dart`

Coda job:
- `lib/features/jobs/presentation/dialogs/async_jobs_dialog.dart`

