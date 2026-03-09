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
- selezione testo abilitata a livello globale via router (`SelectionArea`)

Questo significa che il frontend non e' piu' appoggiato a refresh manuali o stato sparso in widget troppo grandi. I flussi principali sono gia' orchestrati con stato osservabile e refresh mirati.

Nota performance UI:
- l'abilitazione globale della selezione testo introduce un overhead leggero di hit-test/selection manager
- nel breve resta attiva per coerenza UX su web/desktop
- in hardening UX/performance verra' resa configurabile per piattaforma o per schermata, in base ai profili di carico reali

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
- ciclo rate e scadenze
- unita' immobiliari e titolarita'
- preventivo e consuntivo
- report professionali
- documentale e allegati
- portale condomino
- dashboard operative e automazioni

Questi gap non richiedono un cambio radicale del modello appena costruito. La direzione giusta ora non e' rifare il dominio, ma completare i verticali funzionali sopra una base che e' finalmente coerente.

## Stato attuale chiuso

### Fondazione dominio
- autenticazione e autorizzazione applicativa
- selezione `condominio / gestione / esercizio`
- esercizi aperti/chiusi con storico in sola lettura
- anagrafica stabile separata dalla posizione d'esercizio
- snapshot read-model su `condomino`
- subentro e cessazione con validita' temporale
- apertura nuovo esercizio che clona solo le posizioni ancora attive

### Fondazione contabile
- tabelle millesimali
- configurazioni spesa
- movimenti con riparto realtime
- rebuild storico
- versamenti atomici
- residui coerenti su posizione ed esercizio

### Fase 2 chiusa (Unita' e titolarita')
- `unita_immobiliare` stabile per `condominioRootId`
- relazione esplicita posizione `<->` unita' (`unitaImmobiliareId`)
- titolarita' posizione (`proprietario / inquilino / delegato`)
- subentro guidato vincolato alla stessa unita' del precedente
- storico titolarita' per unita' disponibile via API e UI operativa admin

### Fondazione UI
- Riverpod come stato applicativo condiviso
- sync cross-tab `Anagrafica <-> Documenti`
- refactor `presentation / application / domain / data`
- rebuild piu' mirati tramite provider derivati

## Principi di rilascio

- niente nuove feature che rompano il modello `root + posizione temporale`
- ogni fase deve produrre un flusso usabile end-to-end
- backend e Flutter avanzano insieme
- i read model caldi restano denormalizzati dove serve
- indici e query server-side vengono definiti insieme al dominio

## Fase 0 - Hardening produzione

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

## Fase 2 - Unita immobiliari e titolarita'

### Stato
Chiusa il 2026-03-09.

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

## Fase 3 - Preventivo, consuntivo e chiusura anno

### Obiettivo
Gestire l'intero esercizio dall'apertura alla chiusura.

### Funzionalita'
- preventivo per gestione/codice spesa
- confronto preventivo vs consuntivo
- wizard di chiusura esercizio
- regole esplicite di carry-over
- apertura esercizio successivo guidata
- storico confrontabile anno su anno

## Fase 4 - Morosita', solleciti e recupero crediti

### Obiettivo
Trasformare il prodotto in strumento operativo quotidiano.

### Funzionalita'
- vista morosi per esercizio e gestione
- aging del debito
- solleciti manuali e automatici
- cronologia solleciti
- stato pratica `in bonis / sollecitato / legale`

## Fase 5 - Documentale e allegati

### Obiettivo
Collegare contabilita' e documenti reali.

### Funzionalita'
- allegati ai movimenti
- archivio documenti per esercizio
- categorie documento
- ricerca e filtri
- versionamento minimo

## Fase 6 - Report professionali

### Obiettivo
Produrre output consegnabili senza Excel esterni.

### Funzionalita'
- estratto conto posizione
- situazione contabile esercizio
- riparto per tabella
- situazione morosita'
- consuntivo
- export PDF/Excel

## Fase 7 - Portale condomino

### Obiettivo
Aprire il prodotto agli utenti finali senza esporre la complessita' amministrativa.

### Funzionalita'
- accesso condomino
- saldo, rate, versamenti, documenti
- consultazione posizione attiva e storico personale
- download documenti
- notifiche e comunicazioni

## Fase 8 - Dashboard e automazioni

### Obiettivo
Ridurre il lavoro manuale e rendere il prodotto un cockpit operativo.

### Funzionalita'
- dashboard amministratore
- alert scadenze e morosi
- azioni massive
- import guidati
- job asincroni per export e invii
- reminder e automazioni operative

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
- profiling e tuning della selezione testo globale (`SelectionArea`) su web/desktop per bilanciare usabilita' e costo rendering

## Ordine di priorita' consigliato

1. Fase 0
2. Fase 1
3. Fase 3
4. Fase 4
5. Fase 5
6. Fase 6
7. Fase 7
8. Fase 8
