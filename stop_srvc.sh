#!/bin/bash
set -e

STACK_NAME="SRVC"


echo
echo " Rimozione stack '$STACK_NAME'..."
docker stack rm "$STACK_NAME"

echo " Attendo la rimozione completa..."
sleep 10

echo "Stack '$STACK_NAME' rimosso!"
