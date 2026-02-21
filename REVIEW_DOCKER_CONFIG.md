# Verifica rapida architettura Docker e configurazioni servizi

Data verifica: 2026-02-21  
Ambito: file Docker/Swarm e configurazioni di servizio (escluso codice applicativo)

## 1) Cose che vanno bene

1. Architettura a stack separati in Swarm chiara e leggibile:
- `SRVC` (registry/portainer)
- `DB` (postgres/mongo)
- `MIM` (servizi applicativi)
- Riferimento: `start_all_stacks.sh`

2. Reti overlay dedicate già presenti e separate per dominio funzionale:
- `keycloak-network`, `postgres-net`, `mongo-net`, `redis-net`, `kafka-net`
- Questo aiuta isolamento logico e troubleshooting.

3. Persistenza dati impostata per servizi principali:
- Volumi per Postgres, Mongo, Registry, Portainer, Kafka.

4. Build container backend/frontend già standardizzate:
- Dockerfile dedicati per Discovery, Gateway, keycloak-service, template web, PoWA.

5. Discovery server configurato in modo coerente:
- `Discovery/src/main/resources/application.properties` usa porta 8761 e modalità standalone eureka.

## 2) Cose da cambiare (priorità alta)

1. Segreti e credenziali hardcoded nel repository.
- Esempi: password DB, admin Keycloak, cookie secret, URI con password in chiaro.
- Rischio: sicurezza e rotazione segreti difficoltosa.

2. Keycloak in modalità dev su stack swarm.
- Uso di `start-dev` e `--features=preview`.
- Rischio: configurazione non adatta a runtime stabile/production-like.

3. Esposizione porte troppo ampia con `mode: host`.
- DB/Redis/Keycloak/admin esposti esternamente in più compose swarm.
- Rischio: superficie di attacco e collisioni porte.

4. Drift tra file compose.
- Incoerenze su nome DB (`keycloak` vs `mimdb`), immagini (`latest` vs versioni fisse/custom), naming volumi.
- Rischio: ambienti non riproducibili e problemi in deploy.

5. Uso di `depends_on` in stack Swarm come meccanismo di sequenza.
- In Swarm non garantisce readiness applicativa.
- Rischio: race condition all'avvio.

## 3) Cose da cambiare (priorità media)

1. Immagini con tag `latest`.
- Riduce prevedibilità e rollback.

2. Registry/UI con autenticazione non effettiva.
- In config è presente ma commentata o disabilitata.

3. CORS troppo permissivi in alcuni punti.
- In particolare su registry e gateway.

## 4) Piano di modifica consigliato (senza toccare codice applicativo)

## Fase A - Sicurezza configurazioni (immediata)

1. Spostare segreti da YAML/CONF a:
- Docker secrets (Swarm) per produzione.
- file `.env` locale non versionato per sviluppo.

2. Aggiornare compose per leggere valori da env/secrets:
- `KEYCLOAK_ADMIN`, `KEYCLOAK_ADMIN_PASSWORD`, `KC_DB_PASSWORD`
- `POSTGRES_PASSWORD`
- `MONGO_INITDB_ROOT_PASSWORD`
- `SPRING_DATASOURCE_PASSWORD`, `SPRING_DATA_MONGODB_PASSWORD`
- `cookie_secret`/password PoWA

3. Registry:
- riattivare auth (`htpasswd` o token).
- evitare segreto statico nel repo.

## Fase B - Hardening runtime (subito dopo Fase A)

1. Keycloak:
- passare da `start-dev` a `start` in swarm.
- mantenere opzioni esplicite coerenti con ingress/proxy.

2. Ridurre porte pubbliche:
- lasciare pubblici solo entrypoint necessari (es. gateway/UI).
- tenere interni DB/redis/keycloak quando non serve accesso esterno.

3. Inserire healthcheck container principali:
- Postgres (`pg_isready`)
- Mongo (`db.adminCommand('ping')`)
- Keycloak (endpoint health/ready)

## Fase C - Coerenza e manutenibilità

1. Uniformare naming e valori tra compose modulari e compose monolitico:
- DB name unico
- immagini allineate
- nome volume Mongo coerente
- nomi servizio coerenti (`discoveryservice` vs `discovery`)

2. Eliminare `latest` e fissare versioni immagine.

3. Ridurre configurazioni inline complesse (`SPRING_APPLICATION_JSON`) dove possibile.

## 5) Mappa sintetica file -> azione

- `docker-compose-keycloak-swarm.yml`
  - Rimuovere hardcoded secret, cambiare command a `start`, valutare publish porta 8082.

- `docker-compose-admin-swarm.yml`
  - Esternalizzare password, correggere dipendenze/naming servizio discovery.

- `docker-compose-postgres-swarm.yml`
  - Password via secrets/env, valutare rimozione esposizione host 5432.

- `docker-compose-mongo-swarm.yml`
  - Password via secrets/env, aggiungere healthcheck.

- `docker-compose-redis-swarm.yml`
  - Valutare esposizione host 6379 e presenza redis-commander in ambienti target.

- `docker-compose-gateway-swarm.yml`
  - Tenere come entrypoint pubblico, rivedere policy CORS e leggibilità config.

- `docker-compose-swarm.yml`
  - Correggere incoerenze (volume `mongo-data-config`/`mongo-data-conf`, DB name, image tag).

- `docker-services-swarm.yml`
  - Rimuovere `latest`, rafforzare auth registry.

- `config-registry/credentials.yml`
  - Secret esterno, auth abilitata, CORS restrittivo.

- `config-registry/registry.ui.config.yml`
  - `auth.enabled: true` (se registry protetto).

- `powa-web.conf` e `powa/powa-web.conf`
  - Rimuovere secret in chiaro.

## 6) Check finale dopo modifiche

1. Validazione sintassi:
- `docker compose -f <file> config` su tutti i compose principali.

2. Validazione deploy:
- deploy stack in ordine `SRVC -> DB -> MIM`
- controllo stato con `docker service ls` e `docker service ps`.

3. Validazione runtime:
- reachability gateway/UI.
- servizi DB non pubblici se previsto.
- login/auth registry funzionante.

## 7) Nota sui file `.properties`

Per i servizi backend, l'unico `.properties` runtime rilevante trovato è:
- `Discovery/src/main/resources/application.properties`

Gateway e keycloak-service usano file `application.yml`, già inclusi nella verifica.
