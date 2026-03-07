#!/bin/bash
set -e

# Build immagine Keycloak con tema "Condomio" incluso.
# Lo stack swarm punta a questo tag locale sul manager.
docker build -t condomio-keycloak:26.3.0 ./keycloak-theme
