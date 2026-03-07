# Product Roadmap

## Visione

`Condomio` deve diventare uno strumento operativo completo per amministratori di condominio:
- gestione di piu' condomini
- piu' gestioni per condominio (`ordinaria`, `riscaldamento`, `straordinaria`)
- piu' esercizi nel tempo
- contabilità leggibile e coerente in tempo reale
- documenti, report e portale utenti finali

L'obiettivo non e' solo "salvare dati", ma ridurre il lavoro manuale dell'amministratore e rendere tracciabile ogni operazione.

## Stato attuale

Baseline tecnica gia' chiusa:
- autenticazione e autorizzazione applicativa
- selezione `condominio / gestione / esercizio`
- root condominio + esercizio annuale
- anagrafica condomini
- anagrafica stabile del condomino separata dalla posizione d'esercizio
- tabelle millesimali
- configurazioni spesa
- movimenti con riparto realtime
- versamenti atomici
- storico esercizi chiusi in sola lettura
- tenant isolation di base

## Cosa manca per un prodotto finito

Mancano ancora i blocchi di valore che un amministratore usa ogni giorno:
- rate, scadenze e stato incassi
- consuntivo e preventivo
- unità immobiliari e titolarita'
- documentale e allegati
- report professionali
- portale condomino
- automazioni operative

## Principi di roadmap

Le prossime fasi devono rispettare queste regole:
- prima chiudere il ciclo contabile, poi il portale utente
- ogni sprint deve rilasciare un flusso utilizzabile davvero
- niente nuove feature senza hardening minimo su sicurezza, indici, audit e UX
- ogni dominio nuovo deve essere modellato con entita' stabili + posizione d'esercizio dove serve

## Sequenza di rilascio

### Fase 0 - Stabilizzazione piattaforma

Obiettivo:
- consolidare la base appena costruita prima di aggiungere nuova complessita'

Da chiudere:
- migrazione Mongo completa su `condomino_root`
- verifica runtime della separazione `condominio / esercizio / condomino_root / condomino`
- logging e messaggi errore coerenti
- smoke test di apertura esercizio, chiusura, riparto, versamenti

Definition of done:
- il backend parte senza errori di migrazione o indice
- i documenti legacy sono stati riallineati
- la UI continua a funzionare senza adattamenti manuali sui dati

### Fase 1 - Ciclo incasso reale

Obiettivo:
- permettere all'amministratore di emettere rate e incassare in modo strutturato

Funzionalita':
- modello `Rata` per esercizio
- piano rateale manuale e guidato
- stato rata `aperta / parziale / pagata / scaduta`
- collegamento versamenti <-> rate
- ripartizione automatica del versamento sulle rate
- cronologia finanziaria del condomino

Valore business:
- l'amministratore capisce subito chi deve pagare cosa
- il condomino puo' avere un estratto conto sensato

Definition of done:
- posso creare un piano rateale per esercizio
- posso incassare totalmente o parzialmente una rata
- il residuo del condomino e dello specifico esercizio resta coerente

### Fase 2 - Modello immobiliare corretto

Obiettivo:
- smettere di trattare il condomino come semplice persona generica

Funzionalita':
- unita' immobiliari
- proprietario, inquilino, delegato
- relazione persona <-> unita'
- quote di proprieta' separate dalle quote di riparto
- storico cambi titolarita'

Valore business:
- il gestionale riflette la realta' amministrativa
- rate, report e portale potranno essere corretti anche in casi complessi

Definition of done:
- ogni posizione contabile e' riferita a una unita' e a un soggetto corretto
- e' possibile distinguere chi paga, chi possiede e chi consulta

### Fase 3 - Preventivo, consuntivo e chiusura anno

Obiettivo:
- rendere l'esercizio annuale realmente gestibile dall'inizio alla chiusura

Funzionalita':
- preventivo per codice spesa
- confronto preventivo vs consuntivo
- saldo finale esercizio
- wizard di chiusura esercizio
- wizard di apertura nuovo esercizio con carry-over guidato
- storico esercizi chiusi con confronto anno su anno

Valore business:
- il prodotto smette di essere solo contabile operativo e diventa strumento di governo dell'anno

Definition of done:
- posso vedere quanto era previsto, quanto e' stato speso e come chiudo l'anno
- posso aprire l'anno successivo con regole di riporto chiare

### Fase 4 - Report professionali

Obiettivo:
- produrre output realmente consegnabili a condomini, consiglieri e assemblea

Funzionalita':
- estratto conto condomino
- situazione contabile condominio
- situazione morosita'
- riparto per tabella
- consuntivo esercizio
- export PDF/Excel

Valore business:
- riduzione del lavoro fuori piattaforma
- meno fogli Excel e documenti costruiti a mano

Definition of done:
- un amministratore puo' scaricare e consegnare documenti leggibili senza passaggi esterni

### Fase 5 - Documentale e allegati

Obiettivo:
- collegare la contabilita' ai documenti reali

Funzionalita':
- allegati ai movimenti
- archivio documenti per esercizio e gestione
- categorie documento
- ricerca e filtri
- download e versionamento minimo

Valore business:
- ogni spesa ha i propri riferimenti documentali
- si riduce la dispersione tra gestionale, email e cartelle locali

Definition of done:
- posso aprire una spesa e vedere subito fattura, ricevute e allegati

### Fase 6 - Portale condomino

Obiettivo:
- aprire la piattaforma anche agli utenti finali

Funzionalita':
- accesso condomino standard
- vista saldo, rate, versamenti, documenti
- download documenti personali
- notifiche e comunicazioni
- aperture segnalazioni

Valore business:
- meno richieste ripetitive all'amministratore
- maggiore trasparenza verso i condomini

Definition of done:
- un condomino vede solo cio' che lo riguarda
- puo' consultare situazione, documenti e pagamenti senza supporto manuale

### Fase 7 - Operativita' amministratore

Obiettivo:
- trasformare `Condomio` in un cockpit operativo quotidiano

Funzionalita':
- dashboard con alert veri
- morosi e scadenze imminenti
- task manutentivi e fornitori
- ricerca globale
- filtri rapidi
- azioni massive

Valore business:
- l'amministratore apre il prodotto per lavorare, non solo per registrare dati

Definition of done:
- dalla dashboard posso capire cosa richiede attenzione oggi e intervenire rapidamente

### Fase 8 - Automazioni

Obiettivo:
- ridurre drasticamente il carico operativo manuale

Funzionalita':
- solleciti automatici
- template email/PEC
- reminder scadenze
- import anagrafiche e movimenti
- riconciliazione guidata
- job asincroni per export e invii massivi

Valore business:
- aumento produttivita'
- meno attivita' ripetitive

Definition of done:
- le attivita' ripetitive diventano workflow assistiti o automatici

## Tracce tecniche parallele

Queste attivita' non sono uno sprint a parte: devono avanzare insieme al business.

### Sicurezza e compliance
- audit trail completo
- storico modifiche su movimenti, versamenti, quote, esercizi
- ruoli granulari per amministratore, consigliere, condomino
- mascheramento dati e gestione retention

### Scalabilita'
- paginazione server-side ovunque
- filtri e ricerca lato backend
- indici allineati ai pattern reali di query
- job asincroni per report pesanti
- caching solo dove utile e misurato

### Qualita'
- test backend sui casi contabili critici
- integration test sui flussi d'esercizio
- test widget sui flussi UX principali
- smoke test automatici delle migrazioni Mongo

### UX
- eliminazione dei passaggi ambigui
- meno popup ridondanti
- stato esercizio sempre evidente
- mobile davvero utilizzabile
- messaggi di errore orientati all'azione

## Ordine di priorita' consigliato

Se l'obiettivo e' andare in uso reale il prima possibile, l'ordine corretto e':
1. fase 0
2. fase 1
3. fase 2
4. fase 3
5. fase 4
6. fase 5
7. fase 6
8. fase 7
9. fase 8

## KPI da monitorare

Metriche utili per capire se il prodotto sta migliorando davvero:
- tempo medio per aprire un nuovo esercizio
- tempo medio per creare un piano rateale
- tempo medio per registrare un incasso
- percentuale di rate pagate entro scadenza
- numero di solleciti inviati
- numero di documenti scaricati
- tempo medio per trovare una spesa o un documento

## Riferimenti

- sprint base gia' chiuso: [SPRINT1_ACCEPTANCE.md](C:\Users\marco.simone\Desktop\smartmetering\regenesy\Condomio\SPRINT1_ACCEPTANCE.md)
