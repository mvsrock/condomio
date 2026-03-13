# Production Roadmap

## Obiettivo

Portare `Condomio` da base gestionale forte a prodotto realmente usabile in produzione da un amministratore di condominio.

La roadmap parte dallo stato attuale del dominio:
- `condominio` stabile
- `esercizio` per anno/gestione
- `condomino_root` come profilo condiviso
- `condomino` come posizione temporale nell'esercizio
- riparto realtime, versamenti atomici, storico esercizi
- subentro e cessazione posizione nello stesso esercizio

## AS-IS

### Dominio e persistenza

Il prodotto oggi ha gia' superato il modello iniziale "un solo condominio con dati annuali mischiati" ed e' strutturato in modo piu' corretto:
- `condominio` rappresenta il master stabile del contesto amministrato
- `esercizio` rappresenta il contesto operativo annuale per una specifica gestione
- `condomino_root` rappresenta il profilo anagrafico condiviso del soggetto
- `condomino` rappresenta la posizione temporale del soggetto in uno specifico esercizio

Questa separazione evita due problemi tipici:
- duplicazione incontrollata dei dati stabili tra esercizi
- perdita di significato contabile quando cambiano anno, gestione o soggetto

Sul piano Mongo il modello attuale e' ibrido:
- i documenti `root` sono il source of truth dei dati stabili
- i documenti di posizione contengono snapshot denormalizzati dei campi caldi di lettura

Questa scelta e' voluta. La parte normalizzata serve per scrivere bene e mantenere coerenza del dominio. La parte denormalizzata serve per leggere bene liste, dettagli, sorting e autorizzazioni senza costringere il backend a join o `$lookup` costosi sul path operativo normale.

### Contesto operativo

L'applicazione lavora gia' su un contesto esplicito `condominio / gestione / esercizio`.

Questo implica che:
- uno stesso condominio puo' avere piu' gestioni nello stesso anno
- ogni gestione ha il proprio esercizio
- lo stato dell'esercizio (`OPEN` o `CLOSED`) condiziona le operazioni disponibili
- l'utente non lavora su un generico "anno", ma su un esercizio selezionato

Il modello supporta gia':
- selezione dell'esercizio attivo
- distinzione tra esercizi aperti e storico chiuso
- apertura di un nuovo esercizio dalla gestione precedente
- carry-over opzionale dei saldi finali

### Posizioni, cessazioni e subentri

La posizione del condomino non e' piu' trattata come record piatto sempre attivo.

Ogni posizione ha adesso:
- stato
- data di ingresso
- data di uscita
- motivo di uscita
- collegamento opzionale a posizione precedente o successiva

Questo consente due flussi distinti:
- cancellazione dura solo per errore di inserimento e solo quando non c'e' storico incompatibile
- cessazione o subentro quando il soggetto smette di far parte dell'esercizio o viene sostituito

Il riparto usa la validita' temporale della posizione. Quindi:
- un movimento storico continua a riferirsi ai soggetti efficaci in quella data
- un subentro non riscrive artificialmente il passato
- il nuovo esercizio clona solo le posizioni ancora attive al termine dell'esercizio precedente

### Contabilita' gia' disponibile

Lo stato funzionale attuale copre bene la base contabile operativa:
- tabelle millesimali
- configurazioni spesa
- movimenti con riparto realtime
- rebuild storico del riparto
- versamenti atomici
- residui coerenti su posizione ed esercizio

I movimenti sono gia' pensati per aggiornare immediatamente il saldo contabile senza dover dipendere sempre da ricostruzioni totali. Dove necessario resta disponibile il rebuild, ma non e' l'unico meccanismo.

### Sicurezza e isolamento

Il perimetro applicativo e' gia' protetto da:
- autenticazione centralizzata
- selezione del contesto attivo
- tenant isolation per esercizio
- regole di sola lettura sugli esercizi chiusi

Il sistema distingue gia' tra profilo stabile, posizione contabile ed esercizio attivo, che e' la base necessaria per arrivare a permessi piu' granulari senza rifare il dominio.

### Stato della UI Flutter

Sul fronte Flutter la base tecnica e' stata gia' consolidata:
- pattern `presentation / application / domain / data`
- Riverpod come stato applicativo condiviso
- provider derivati per ridurre i rebuild
- sincronizzazione cross-tab tra `Anagrafica` e `Documenti`
- refactor delle pagine monolitiche in shell, widget e dialog separati
- selezione testo gestita in modo locale sui punti utili (no wrapper globale)

Questo significa che il frontend non e' piu' appoggiato a refresh manuali o stato sparso in widget troppo grandi. I flussi principali sono gia' orchestrati con stato osservabile e refresh mirati.

Nota performance UI:
- il wrapper globale `SelectionArea` e' stato rimosso per stabilita' runtime (evita `ConcurrentModificationError` su rebuild dinamici web)
- i testi restano selezionabili nei punti diagnostici e nelle viste dove porta valore reale
- la strategia attuale privilegia robustezza UI su web/desktop mantenendo selezione locale esplicita

### Query, read model e scalabilita'

La parte piu' sensibile per la crescita non e' solo il numero di utenti finali, ma il volume di letture ripetute su anagrafiche, movimenti, posizioni e storico esercizi.

L'AS-IS attuale e' gia' allineato a questo obiettivo:
- i pattern di query principali sono server-side
- le liste calde leggono i dati snapshot da `condomino`
- gli indici sono costruiti sui pattern reali di accesso e non in modo generico
- il backend evita nel path operativo normale ricostruzioni inutili tramite merge completo di root e posizione

Questo non significa che la scalabilita' sia "finita", ma significa che la base dati attuale non e' piu' modellata in modo incompatibile con carichi grandi.

### Limiti ancora aperti dell'AS-IS

Il prodotto oggi e' solido come piattaforma di dominio e base contabile, ma non e' ancora completo per un uso pienamente produttivo da parte di uno studio di amministrazione.

Mancano ancora:
- automazioni operative (job asincroni, reminder, azioni massive)
- orchestrazione comunicazioni/notifiche su scala produzione

Questi gap non richiedono un cambio radicale del modello appena costruito. La direzione giusta ora non e' rifare il dominio, ma completare i verticali funzionali sopra una base che e' finalmente coerente.

## Modello di stato fase

Ogni fase viene classificata con uno di questi stati:
- `In sviluppo`: funzionalita' parziale o non chiusa end-to-end.
- `Feature complete`: flusso funzionale disponibile, ma con gap UX/operativi/robustezza.
- `Production ready`: utilizzabile in vendita senza workaround critici sul perimetro della fase.

Una fase non e' `Production ready` finche' non supera tutte le verifiche:
- flusso utente completo senza operazioni tecniche manuali
- errori leggibili e orientati all'azione
- comportamento coerente web/mobile
- permessi corretti per ruolo e pertinenza
- migrazione/compatibilita' dati verificata
- test minimi automatici sul perimetro fase

## Audit stato reale (2026-03-12)

### Quadro sintetico
- `Fase 0 - Hardening`: **Production ready**
- `Fase 1 - Ciclo rate/incassi`: **Production ready**
- `Fase 2 - Unita' e titolarita'`: **Production ready**
- `Fase 3`: **Production ready**
- `Fase 4`: **Production ready**
- `Fase 5`: **Production ready**
- `Fase 6`: **Production ready**
- `Fase 7`: **Production ready**
- `Fase 8`: **Production ready**

### Evidenze consolidate oggi
- Dominio base multi-esercizio presente (`condominio root + esercizio + condomino root + posizione`)
- Riparto realtime e residui coerenti presenti
- Versamenti e rate presenti con aggiornamento incrementale
- Subentro/cessazione posizione presenti
- Unita' immobiliari e titolarita' presenti con storico titolarita'
- UI con Riverpod strutturata per feature e separazione livelli
- Update unita' con sync snapshot su `condomino` (scala/interno riallineati automaticamente)
- Disassociazione unita' da posizione disponibile in modifica anagrafica
- `interno` alfanumerico supportato end-to-end (core + flutter + parser documenti)
- Flusso admin allineato a sicurezza service-to-service: Flutter chiama solo `core`, e `core` inoltra a `keycloak-service` via OpenFeign + discovery
- Split microservizi avviato su perimetro operativo:
  - nuovo `operations-service` come owner dei job asincroni (`/jobs`)
  - `core` mantiene `/jobs` come facade/proxy verso `operations-service` (nessun impatto su Flutter)
  - `operations-service` delega la business logic a `core` tramite endpoint interni signed (`/internal/operations/**`)
  - bonifica legacy completata su `core`: rimossi service/repository/document asincroni locali duplicati
  - observability minima su `operations-service`: metriche `queued/running/completed/duration` + log lifecycle job
  - deploy stack allineato: aggiunti compose dedicati per `core` e `operations-service`
- Riparto condominiale reso coerente con partecipazione opzionale per tabella
- Error mapping FE aggiornato sui nuovi codici business (`unita in uso`, `noPartecipanti`)
- Verticale preventivo/consuntivo disponibile con API dedicate (`/preventivi/{idCondominio}`)
- Confronto budget vs consuntivo esposto in UI documenti con editing preventivo per coppia codice/tabella
- Consuntivo aggregato automaticamente dai movimenti reali dell'esercizio
- Vista morosita' con aging debito e stato pratica (`in bonis`, `sollecitato`, `legale`)
- Solleciti manuali e automatici con storico per posizione esercizio
- Dashboard home restylizzata in chiave operativa (contesto, KPI, scadenze, attivita' recenti, azioni rapide)
- UX workspace unificata Anagrafica/Documenti con switch contestuale e pagina Documenti semplificata (riduzione ridondanze esercizio, riepilogo e azioni meno rumorosi)
- Documenti riorganizzata in viste operative separate (`Contabilita` / `Condomini`) e Anagrafica senza tab annidate per la gestione accessi
- Fase 5 avviata end-to-end:
  - backend `documenti` con archivio per esercizio, allegati a movimento, categorie e versioning minimo (`documentGroupId` + `versionNumber`)
  - storage binario su GridFS con metadati tenant-aware
  - frontend Riverpod con provider derivati e dialog archivio operativo (upload, nuova versione, delete, filtri)
  - preview documenti in UI:
    - PDF, immagini, testo e Excel
    - preview Excel con selector foglio, griglia scrollabile e formattazione tipi cella
    - compat mode su `styles.xml` per file `.xlsx` con `numFmtId` non standard (normalizzazione in memoria, file sorgente invariato)
    - error details copiabile da modale (`Copia dettaglio`) per debug veloce
  - modali archivio/preview con testo selezionabile
  - paginazione server-side archivio documenti (`page`, `size`, metadati pagina in header)
  - dialog archivio aggiornato su paginazione reale (filtri server-side + controlli pagina)
  - mapping errori business documentale completato (upload/list/paginazione/movimento tenant)
- Fase 6 chiusa end-to-end:
  - backend reportistica con API dedicate:
    - `GET /reports/{idCondominio}` snapshot aggregato (situazione, consuntivo, riparto, morosita, estratti)
    - `GET /reports/{idCondominio}/export?format=pdf|xlsx` export professionale
  - sicurezza BE allineata admin-only su `/reports/**` + guard ownership esercizio lato service
  - export nativo server-side:
    - XLSX multi-sheet (`Situazione`, `Consuntivo`, `Riparto Tabelle`, `Morosita`, `Estratti`)
    - PDF con sezioni tabellari omogenee alle viste operative
  - UI documenti:
    - nuova azione `Report` nella toolbar contabilita'
    - dialog report con filtro posizione, preview sezioni e download PDF/XLSX
    - download cross-platform (web + IO) centralizzato con helper dedicato
  - analyze Flutter su perimetro report senza issue
  - compile core verificata (`mvnw -DskipTests compile`)
  - allineamento numerico tra:
    - dettaglio spesa UI (`Dettaglio + Tabelle`)
    - dialog report
    - export PDF/XLSX
  - dettaglio quota condomino raggruppato per singola spesa/movimento con riferimento leggibile, importo spesa, quota condomino e controllo quadratura
  - export report aggiornati con la stessa logica di raggruppamento (niente piu' righe tabellari isolate senza contesto)
  - hardening download report/documenti su Windows con sanificazione robusta del filename (`Content-Disposition` + caratteri riservati)
- Fase 7 chiusa end-to-end:
  - backend:
    - endpoint self-service `GET /portale/me?idCondominio=...` con snapshot completo del condomino (contesto esercizio, posizione personale, rate, versamenti, quote spese, documenti recenti)
    - tenant guard applicata server-side su esercizio visibile e pertinenza posizione utente
    - hardening lettura anagrafica: su `GET /condomino?idCondominio=...` utente non-admin vede solo la propria posizione (admin owner continua a vedere l'intera anagrafica)
  - frontend Flutter:
    - nuova feature `portal` strutturata in `presentation/application/domain/data`
    - pagina portale condomino con KPI personali, rate, versamenti, spese imputate e documenti recenti scaricabili
    - routing e navigation role-aware:
      - admin -> area amministrativa
      - condomino -> area self-service (`/home/portal`)
    - guard router per impedire l'accesso non-admin ai branch admin
  - quality gate:
    - `mvnw -DskipTests compile` su core
    - `flutter analyze` su app Flutter
- Fase 8 punto 1 chiuso end-to-end (job asincroni):
  - backend core:
    - nuova collection `async_job` con indici tenant/requester + stato lifecycle (`QUEUED/RUNNING/DONE/FAILED`)
    - worker asincrono con executor dedicato (`jobExecutor`) e persistenza stato job
    - API job:
      - `POST /jobs/report-export`
      - `POST /jobs/morosita/{idCondominio}/solleciti-automatici`
      - `GET /jobs`
      - `GET /jobs/{jobId}`
      - `GET /jobs/{jobId}/download`
    - download risultato export su GridFS con metadati e ownership guard
    - list job ottimizzata con query paginata lato repository (no scan completo utente)
  - frontend Flutter:
    - feature `jobs` strutturata in `presentation/application/domain/data`
    - notifier Riverpod dedicato con provider derivati (rebuild minimizzati via `select`)
    - dialog `Coda job` con polling leggero, stato operativo, errori e download output
    - integrazione flussi:
      - report: export ora accodato in background (`Accoda XLSX/PDF`)
      - morosita: auto-solleciti accodati in background
      - accesso rapido a `Coda job` da `Documenti` e `Dashboard`
    - mapping errori job allineato in `ApiError`
- Fase 8 completata end-to-end:
  - perimetro job estratto in microservizio dedicato:
    - `operations-service` owner runtime job
    - `core` facade `/jobs` + proxy OpenFeign verso `operations-service`
    - bridge interno signed `operations -> core` per esecuzione report/solleciti/reminder
  - dashboard amministratore con pannello alert operativo dedicato (scadenze, morosita, pratiche legali) e action hint
  - reminder scadenze rate in background:
    - nuovo job `MOROSITA_REMINDER_SCADENZE`
    - endpoint `POST /jobs/morosita/{idCondominio}/reminder-scadenze`
    - output tracciato in coda job (count reminder creati)
  - azioni massive operative:
    - applicazione piano rate in blocco su tutte le posizioni attive dell'esercizio (`POST /condomino/rate-plan/{idCondominio}`)
  - import guidato:
    - dialog automazioni in dashboard con parser CSV guidato, anteprima e validazione righe
    - applicazione piano rate dal CSV con refresh dataset e sync cross-modulo
  - UX operativa:
    - bottone `Automazioni` in dashboard (admin, esercizio aperto)
    - reminder/auto-solleciti accodabili direttamente da dashboard
    - accesso rapido alla coda job dalla stessa modale
  - hardening UX runtime (2026-03-13):
    - rimosso `SelectionArea` globale nel router per eliminare eccezioni concorrenti in selezione testo su pagine dinamiche
    - modali documenti aggiornate con selezione locale puntuale (`SelectableText`) al posto di wrapper globali
    - header home aggiornato: cambio esercizio solo via icona dedicata, label condominio solo informativa (non cliccabile)
    - dashboard semplificata: rimosso pulsante testuale "Cambia esercizio" dal box contesto

### Gap per diventare realmente vendibile
- Hardening error UX ancora incompleto in piu' punti operativi
- Alcuni flussi admin sono completi funzionalmente ma non ancora rifiniti come UX business-grade
- Mancano verticali avanzati oltre fase 8 (workflow multi-step studio, notifiche multi-canale reali, metriche SLA)

## Principi di rilascio

- niente nuove feature che rompano il modello `root + posizione temporale`
- ogni fase deve produrre un flusso usabile end-to-end
- backend e Flutter avanzano insieme
- i read model caldi restano denormalizzati dove serve
- indici e query server-side vengono definiti insieme al dominio
- dove possibile, creazione e relazione tra entita' devono avvenire inline nello stesso flusso UI

## Fase 0 - Hardening produzione

### Stato
Production ready

### Obiettivo
Chiudere la piattaforma per deploy ripetibili e dati affidabili.

### Da fare
- migrazione Mongo definitiva verificata su dataset reali
- audit dei flussi `create/update/delete/cessazione/subentro`
- pulizia error mapping backend verso codici e messaggi UI coerenti
- test automatici su:
  - subentro nello stesso esercizio
  - cessazione posizione
  - delete sicuro bloccato con storico
  - clone nuovo esercizio solo per posizioni attive
- paginazione e filtri server-side sull'anagrafica

### Definition of done
- boot backend senza warning funzionali o migrazioni incomplete
- i dati reali esistenti vengono riallineati senza interventi manuali
- i principali casi critici di dominio sono coperti da test

## Fase 1 - Ciclo incasso e rate

### Stato
Production ready

### Obiettivo
Permettere all'amministratore di emettere, monitorare e incassare rate.

### Funzionalita'
- piano rateale per esercizio
- rate ordinarie e straordinarie
- stato rata `aperta / parziale / pagata / scaduta`
- imputazione automatica dei versamenti alle rate
- estratto conto posizione
- storico movimenti finanziari della posizione

### Dipendenze
- usa gia' il modello posizione temporale
- prepara il terreno a morosita' e report

### Chiusura fase
- error mapping business consolidato lato client su codici critici rate/incassi
- percorsi CRUD rate/versamenti disponibili su backend e frontend
- test automatici minimi su mapping errori e regressione parsing

## Fase 2 - Unita immobiliari e titolarita'

### Stato
Production ready

### Obiettivo
Separare definitivamente la persona dalla relazione con l'unita' immobiliare.

### Funzionalita'
- `unita_immobiliare` stabile
- relazione posizione <-> unita'
- proprietario, inquilino, delegato
- storico titolarita' per unita'
- subentro guidato tra soggetti sulla stessa unita'

### Nota
Questa e' la fase che completa in modo rigoroso il subentro appena introdotto.
Oggi il subentro e' corretto sul piano contabile-temporale; qui diventa anche corretto sul piano immobiliare.

### Chiusura fase
- gestione unita' completa in UI admin (create/edit/delete + storico titolarita')
- validazione business su unita' (`scala` + `interno` obbligatori, `codice` derivato automaticamente come concatenazione univoca nel condominio)
- subentro guidato vincolato alla stessa unita'
- sincronizzazione automatica dei dati denormalizzati posizione quando cambia l'unita'
- supporto disassociazione unita' in modifica posizione (senza workaround manuali)
- supporto `interno` non numerico su tutto il flusso applicativo

## Fase 3 - Preventivo, consuntivo e chiusura anno

### Stato
Production ready

### Obiettivo
Gestire l'intero esercizio dall'apertura alla chiusura.

### Funzionalita'
- preventivo per gestione/codice spesa
- confronto preventivo vs consuntivo
- wizard di chiusura esercizio
- regole esplicite di carry-over
- apertura esercizio successivo guidata
- storico confrontabile anno su anno

### Chiusura fase
- backend preventivo/consuntivo su collection dedicata `preventivo` con ownership/open guard in scrittura
- API complete:
  - `GET /preventivi/{idCondominio}` snapshot confronto
  - `PUT /preventivi/{idCondominio}` salvataggio preventivo
- confronto consuntivo calcolato server-side dalle ripartizioni dei movimenti, senza input manuale duplicato
- UI documenti:
  - pulsante `Preventivo`
  - tabella editabile preventivo per riga codice spesa + tabella
  - totali preventivo/consuntivo/delta in dialog e riepilogo pagina
- chiusura esercizio e apertura esercizio successivo gia' integrate nel flusso selezione esercizio con carry-over esplicito

## Fase 4 - Morosita', solleciti e recupero crediti

### Stato
Production ready

### Obiettivo
Trasformare il prodotto in strumento operativo quotidiano.

### Funzionalita'
- vista morosi per esercizio e gestione
- aging del debito
- solleciti manuali e automatici
- cronologia solleciti
- stato pratica `in bonis / sollecitato / legale`

### Chiusura fase
- endpoint dedicati morosita':
  - `GET /morosita?idCondominio=...`
  - `PATCH /morosita/{condominoId}/stato`
  - `POST /morosita/{condominoId}/solleciti`
  - `POST /morosita/solleciti/automatici/{idCondominio}`
- calcolo aging lato backend su rate scadute/non scadute con bucket `0-30`, `31-60`, `61-90`, `>90`
- persistenza stato pratica e storico solleciti nel documento posizione `condomino`
- UI documenti:
  - azione `Morosita` dedicata
  - lista operativa con totale scaduto e ritardo massimo
  - cambio stato pratica inline
  - inserimento sollecito manuale
  - generazione solleciti automatici con soglia giorni

## Fase 5 - Documentale e allegati

### Stato
Production ready

### Obiettivo
Collegare contabilita' e documenti reali.

### Funzionalita'
- allegati ai movimenti
- archivio documenti per esercizio
- categorie documento
- ricerca e filtri
- versionamento minimo

### Avanzamento implementato
- API `documenti` su core:
  - `GET /documenti`
  - `POST /documenti` (multipart upload)
  - `POST /documenti/{idDocumento}/versioni`
  - `GET /documenti/{idDocumento}/download`
  - `DELETE /documenti/{idDocumento}`
- Sicurezza BE allineata: write admin-only + tenant guard server-side
- Indici Mongo dedicati per query archivio/versioni
- UI documenti:
  - azione `Archivio` nella toolbar contabilita'
  - dialog archivio con upload, nuova versione, eliminazione, filtro categoria/testo
  - collegamento rapido `Gestisci allegati` dal dettaglio movimento
  - paginazione server-side nel dialog (`25/50/100`, precedente/successiva, totale)
  - preview robusta PDF/immagini/testo/Excel con compatibilita' stile `.xlsx` non standard
  - dettaglio errore copiabile e testi selezionabili nelle modali archivio/preview

### Chiusura fase
- backend:
  - endpoint `GET /documenti` con paginazione opzionale e metadati pagina in response header
  - guard sicurezza coerenti: write admin-only + tenant guard server-side su list/download
  - compile core verificata (`mvnw -DskipTests compile`)
- frontend:
  - dialog archivio su paginazione server-side senza caricare tutto lato UI
  - filtri (categoria/search/movimento/versioni) applicati lato API
  - error mapping documentale allineato in `ApiError`
  - analyze Flutter su perimetro documentale senza issue

## Fase 6 - Report professionali

### Stato
Production ready

### Obiettivo
Produrre output consegnabili senza Excel esterni.

### Funzionalita'
- estratto conto posizione
- situazione contabile esercizio
- riparto per tabella
- situazione morosita'
- consuntivo
- export PDF/Excel

### Chiusura fase
- backend:
  - API snapshot report aggregato (`GET /reports/{idCondominio}`)
  - API export (`GET /reports/{idCondominio}/export?format=pdf|xlsx`)
  - hardening sicurezza: admin-only + ownership esercizio server-side
  - export XLSX/PDF generato lato core senza strumenti esterni
- frontend:
  - azione `Report` nel modulo documenti
  - dialog report con filtro condomino e viste coerenti per tutte le sezioni
  - dettaglio quote presentato a blocchi per spesa (evidenza chiara delle righe tabella appartenenti allo stesso movimento)
  - download file esportati su web/desktop tramite helper platform-aware
  - gestione robusta filename da header `Content-Disposition` (RFC5987 + fallback) per evitare blocchi di salvataggio su Windows
  - mapping errori report in `ApiError`

## Fase 7 - Portale condomino

### Stato
Production ready

### Obiettivo
Aprire il prodotto agli utenti finali senza esporre la complessita' amministrativa.

### Funzionalita'
- accesso condomino
- saldo, rate, versamenti, documenti
- consultazione posizione attiva e storico personale
- download documenti
- notifiche e comunicazioni

### Chiusura fase
- backend:
  - endpoint dedicato `GET /portale/me?idCondominio=...` (read-model self-service)
  - enforcement pertinenza tenant su esercizio e posizione del richiedente
  - hardening anagrafica in lettura: non-admin limitato alla propria posizione
- frontend:
  - feature `portal` completa (`presentation/application/domain/data`)
  - dashboard condomino con rate, versamenti, quote spese e documenti recenti
  - download documenti dal portale in sola lettura
  - routing role-aware con home default differenziata admin/condomino

## Fase 8 - Dashboard e automazioni

### Stato
Production ready

### Obiettivo
Ridurre il lavoro manuale e rendere il prodotto un cockpit operativo.

### Funzionalita'
- dashboard amministratore
- alert scadenze e morosi
- azioni massive
- import guidati
- job asincroni per export e invii
- reminder e automazioni operative

### Avanzamento implementato (punto 1)
- job asincroni production-grade disponibili su backend (`async_job` + API + GridFS)
- coda job disponibile lato Flutter con monitoraggio e download risultato
- export report e auto-solleciti spostati da flusso bloccante a esecuzione in background

### Chiusura fase
- dashboard amministratore completata con:
  - KPI esercizio
  - timeline attivita'
  - pannello alert scadenze/morosita con severity
  - quick actions contestuali
- automazioni operative completate:
  - auto-solleciti in background
  - reminder scadenze in background
  - coda job monitorabile con esito e download output
- azioni massive e import guidato completati:
  - import CSV guidato piano rate (preview + validazione)
  - applicazione bulk piano rate su posizioni attive esercizio
  - refresh coerente su documenti/anagrafica/dashboard

## Tracce tecniche continue

Queste non vivono in una singola fase: devono avanzare sempre.

### Sicurezza
- audit trail completo
- permessi granulari per ruolo e pertinenza
- hardening dei flussi mutativi

### Scalabilita'
- query server-side per liste grandi
- indici solo sui pattern reali
- denormalizzazione mirata dei read model
- job asincroni per operazioni costose

### Qualita'
- test di dominio sui casi contabili critici
- smoke test di migrazione Mongo
- widget/integration test sui flussi chiave Flutter

### UX
- messaggi orientati all'azione
- stato esercizio sempre evidente
- distinzione chiara tra profilo condiviso e posizione esercizio
- mobile realmente operativo
- mantenere selezione testo locale solo sui contenuti ad alto valore diagnostico/funzionale, evitando wrapper globali instabili

## Documentazione tecnica di riferimento

Per mantenere coerenza implementativa tra sprint:
- usare `ENGINEERING_PATTERNS.md` come fonte primaria per pattern FE/BE/Mongo/Riverpod/UX
- mantenere `condominio-ui-flutter/condominio_ui_flutter/ARCHITECTURE.md` allineato ai soli dettagli Flutter specifici

## Ordine di priorita' consigliato

1. Fase 0
2. Fase 1
3. Fase 3
4. Fase 4
5. Fase 5
6. Fase 6
7. Fase 7
8. Fase 8
