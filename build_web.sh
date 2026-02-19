#!/bin/bash
# =====================================================
# Script: build_all.sh
# Scopo: build multiplo Maven + Docker
# =====================================================

set -e  # interrompe lo script in caso di errore

DOCKER_ORG=""   # cambia con il tuo namespace docker

TAG="latest"

echo "🚀 Inizio build progetti MIM..."



declare -A DOCKER_SERVICES=(
   ["template"]="angular"
)

for service in "${!DOCKER_SERVICES[@]}"; do
  if [ -d "$service" ]; then
    echo ""
    echo " Docker build per $service ..."
    cd "$service"
    docker build -t "${DOCKER_ORG}${DOCKER_SERVICES[$service]}:${TAG}" .
    cd ..
  else
    echo " Cartella $service non trovata, salto."
  fi
done

echo ""
echo " Tutti i build Maven e Docker completati con successo!"
