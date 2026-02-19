#!/bin/bash
set -e

STACK_NAME="DB"


echo
echo " Rimozione dello stack '$STACK_NAME'..."
docker stack rm "$STACK_NAME"

echo " Attendo la rimozione completa..."
sleep 10

echo "Stack '$STACK_NAME' rimosso con successo!"
