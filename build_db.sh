#!/bin/bash

set -e
DOCKER_ORG="myorg"
TAG="latest"

declare -A DOCKER_SERVICES=(
  ["postgres-init"]="my-postgres-powa"
  ["powa"]="mypowaweb"

)

for service in "${!DOCKER_SERVICES[@]}"; do
  if [ -d "$service" ]; then
    echo ""
    echo " Docker build per $service ..."
    cd "$service"
    docker build -t "${DOCKER_SERVICES[$service]}:${TAG}" .
    cd ..
  else
    echo " Cartella $service non trovata, salto."
  fi
done

echo ""
echo " Tutti i build Maven e Docker completati con successo!"
