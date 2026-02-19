#!/bin/bash
set -e

STACK_NAME="KAFKA"

echo " Controllo se Docker Swarm è attivo..."
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

echo
echo " Deploy dello stack '$STACK_NAME'"

docker stack deploy -c docker-compose-common-kafka-swarm.yml -c docker-compose-kafka-swarm.yml "$STACK_NAME"

echo
echo " Stack '$STACK_NAME' avviato con successo!"

