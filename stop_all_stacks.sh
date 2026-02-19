#!/bin/bash
set -e

STACKS=("MIM" "SRVC" "KAFKA" "DB")


for STACK in "${STACKS[@]}"; do
  echo
  echo " Rimozione stack '$STACK'..."
  docker stack rm "$STACK" || true
done

echo
echo " Attendo la rimozione completa..."
sleep 10

echo " Tutti gli stack rimossi con successo!"
