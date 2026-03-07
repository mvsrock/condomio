FROM quay.io/keycloak/keycloak:26.3.0

# Tema custom del server Keycloak usato da Condomio.
# In swarm preferiamo un'immagine dedicata: evita bind mount host-specific
# e rende il deploy ripetibile sul manager che ospita il servizio.
COPY themes/ /opt/keycloak/themes/
