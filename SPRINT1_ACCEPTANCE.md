# Sprint 1 - Checklist Accettazione Funzionale

## Obiettivo sprint
Gestire configurazione riparto, tabelle e spese con aggiornamento realtime dei residui.

## Prerequisiti
- servizi attivi: `core`, `keycloak-service`, `keycloak`
- login come amministratore di un condominio
- almeno 2 condomini con quote tabella valorizzate

## Scenario 1 - Configura riparto spese
1. Apri pagina `Documenti`.
2. Clicca `Configura riparto`.
3. Crea una configurazione spesa con 2 tabelle al 50/50.
4. Salva.
5. Verifica che il salvataggio sia accettato solo con totale 100%.

Esito atteso:
- salvataggio riuscito
- configurazione visibile dopo refresh

## Scenario 2 - Crea tabella
1. Clicca `Nuova tabella`.
2. Inserisci codice e descrizione validi.
3. Salva.

Esito atteso:
- tabella visibile subito nella lista

## Scenario 3 - Modifica tabella
1. Scegli una tabella non referenziata.
2. Azione `Modifica`.
3. Cambia descrizione e salva.

Esito atteso:
- modifica persistita e visibile subito

## Scenario 4 - Blocca modifica codice tabella referenziata
1. Scegli una tabella usata in `Configura riparto`.
2. Prova a cambiare codice.

Esito atteso:
- blocco con dialog guidato
- opzioni: `Aggiorna riferimenti` o `Apri Configura riparto`

## Scenario 5 - Elimina tabella referenziata con cleanup automatico
1. Prova a eliminare una tabella usata.
2. Nel dialog scegli `Rimuovi automaticamente`.
3. Conferma eliminazione.

Esito atteso:
- tabella rimossa dalle configurazioni
- eliminazione completata

## Scenario 6 - Registra spesa con riparto realtime
1. Clicca `Nuova spesa`.
2. Scegli codice spesa configurato.
3. Inserisci importo e salva.

Esito atteso:
- movimento creato
- dettaglio movimento mostra riparto per tabella e per condomino
- residui condomini e condominio aggiornati senza interventi manuali

## Scenario 7 - Modifica spesa
1. Seleziona un movimento.
2. Azione `Modifica`, cambia importo.
3. Salva.

Esito atteso:
- movimento aggiornato
- riparto ricalcolato
- residui aggiornati realtime

## Scenario 8 - Elimina spesa
1. Seleziona un movimento.
2. Azione `Elimina`.
3. Conferma.

Esito atteso:
- movimento rimosso
- residui ricalcolati realtime

## Scenario 9 - Quote condomino
1. Seleziona un condomino nel pannello dettaglio.
2. Clicca `Modifica quote`.
3. Aggiorna numeratore/denominatore e salva.

Esito atteso:
- quote salvate su backend
- nuovo calcolo applicato ai movimenti successivi

## Scenario 10 - Isolamento tenant
1. Accedi con utente di altro condominio.
2. Apri `Documenti`.

Esito atteso:
- visualizza e modifica solo dati del condominio di pertinenza
