# Condomio Keycloak Theme

Questo package contiene il tema `condomio` per la login page di Keycloak.

## Build locale immagine

```bash
docker build -t condomio-keycloak:26.3.0 ./keycloak-theme
```

## Deploy stack swarm

Usa il compose aggiornato:

```bash
docker stack deploy -c docker-compose-keycloak-swarm.yml condomio
```

## Attivazione nel realm

1. Apri Keycloak Admin Console
2. Vai su `Realm settings`
3. Apri tab `Themes`
4. Imposta `Login theme = condomio`
5. Salva

## Nota swarm

Il servizio Keycloak e' gia' vincolato al manager. Finche' il deploy resta su
quel nodo, l'immagine locale `condomio-keycloak:26.3.0` e' sufficiente.
Se in futuro rimuovi il vincolo o passi a piu' nodi, conviene pubblicare
l'immagine su un registry interno e puntare il compose a quel registry.
