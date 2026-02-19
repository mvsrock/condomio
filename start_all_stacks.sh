#!/bin/bash
set -e

STACK_MIM="MIM"
STACK_SRVC="SRVC"
#STACK_KAFKA="KAFKA"
STACK_DB="DB"

echo " Controllo se Docker Swarm è attivo..."
if ! docker info 2>/dev/null | grep -q 'Swarm: active'; then
  echo "  Swarm non attivo — lo inizializzo ora..."
  docker swarm init >/dev/null 2>&1 || {
    echo " Errore durante l'inizializzazione di Docker Swarm. Verifica che Docker sia in esecuzione e riprova."
    exit 1
  }
  echo " Docker Swarm inizializzato con successo."
else
  echo " Docker Swarm è già attivo."
fi

echo
echo " DEPLOY COMPLETO DEGLI STACK"
echo "=============================="

echo
echo " Deploy dello stack '$STACK_SRVC'..."
docker stack deploy -c docker-services-swarm.yml "$STACK_SRVC"
echo " Stack '$STACK_SRVC' avviato con successo!"

echo
echo " Deploy dello stack '$STACK_DB'..."
docker stack deploy -c docker-compose-common-db-swarm.yml  -c  docker-compose-postgres-swarm.yml  -c docker-compose-mongo-swarm.yml  "$STACK_DB"
echo "Stack '$STACK_DB' avviato con successo!"


echo
echo " Deploy dello stack '$STACK_MIM'..."
docker stack deploy -c docker-compose-common-swarm.yml    -c docker-compose-keycloak-swarm.yml -c docker-compose-discovery-swarm.yml -c docker-compose-gateway-swarm.yml -c docker-compose-redis-swarm.yml   -c docker-compose-admin-swarm.yml -c docker-compose-angular-swarm.yml "$STACK_MIM"
echo "Stack '$STACK_MIM' avviato con successo!"


#echo
#echo " Deploy dello stack '$STACK_KAFKA'..."
#docker stack deploy -c docker-compose-common-kafka-swarm.yml -c docker-compose-kafka-swarm.yml "$STACK_KAFKA"
#echo " Stack '$STACK_KAFKA' avviato con successo!"



echo
echo " Tutti gli stack sono stati deployati con successo!"
echo
