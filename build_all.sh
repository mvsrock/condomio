#!/bin/bash
# =====================================================
# Script: build_all.sh
# Scopo: build multiplo Maven + Docker
# =====================================================

set -e  # interrompe lo script in caso di errore

DOCKER_ORG=""   # cambia con il tuo namespace docker

TAG="latest"

echo "🚀 Inizio build progetti MIM..."
echo "🧹 Rimozione artefatti locali Atlantica da ~/.m2..."
rm -rf ~/.m2/repository/it/atlantica || true

LIBRARIES=(
  "mim-errorhandler"
  "mim-validationhandler"
  "mim-security"
  "multi-transaction"
  "dynamic-yaml"
  "mim-dto"
  "cache"
  "mim-data"
  "keycloak"
  "Discovery"
  "Gateway"
)


for dir in "${LIBRARIES[@]}"; do
  if [ -d "$dir" ]; then
    echo ""
    echo "🔧 [LIB] Build Maven per: $dir"
    cd "$dir"
    if [ -f "./mvnw" ]; then
      ./mvnw clean install -DskipTests
    else
      mvn clean install -DskipTests
    fi
    cd ..
  else
    echo " Libreria $dir non trovata, salto."
  fi
done



declare -A DOCKER_SERVICES=(
  ["keycloak"]="admin"
   ["Discovery"]="discovery"
   ["Gateway"]="gateway"
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
