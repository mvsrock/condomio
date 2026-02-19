#!/bin/bash
set -e

STACK_NAME="MIM"

echo "Controllo se Docker Swarm è attivo..."

if ! docker info 2>/dev/null | grep -q 'Swarm: active'; then
  echo " Swarm non attivo — lo inizializzo ora..."
  docker swarm init >/dev/null 2>&1 || {
    echo " Errore durante l'inizializzazione di Docker Swarm. Verifica che Docker sia in esecuzione e riprova."
    exit 1
  }
  echo " Docker Swarm inizializzato con successo."
else
  echo " Docker Swarm è già attivo."
fi
echo " Deploy dello stack $STACK_NAME"

docker stack deploy -c docker-compose-common-swarm.yml    -c docker-compose-keycloak-swarm.yml -c docker-compose-discovery-swarm.yml -c docker-compose-gateway-swarm.yml -c docker-compose-redis-swarm.yml   -c docker-compose-admin-swarm.yml -c docker-compose-angular-swarm.yml "$STACK_NAME"

echo " Stack '$STACK_NAME' avviato con successo"


