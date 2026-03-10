package it.condomio.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import it.condomio.client.keycloak.KeycloakAppRoleUpdateRequest;
import it.condomio.client.keycloak.KeycloakServiceClient;

/**
 * Bridge service core -> keycloak-service (service-to-service via discovery).
 *
 * Il token utente corrente viene propagato in `Authorization` per mantenere
 * controllo autorizzativo centralizzato sul servizio destinatario.
 */
@Service
public class KeycloakAppRoleBridgeService {
    private static final Logger log = LoggerFactory.getLogger(KeycloakAppRoleBridgeService.class);

    private final KeycloakServiceClient keycloakServiceClient;
    private final RequestBearerTokenResolver bearerTokenResolver;

    public KeycloakAppRoleBridgeService(
            KeycloakServiceClient keycloakServiceClient,
            RequestBearerTokenResolver bearerTokenResolver) {
        this.keycloakServiceClient = keycloakServiceClient;
        this.bearerTokenResolver = bearerTokenResolver;
    }

    public void updateAppRole(
            String actorSub,
            String targetUserId,
            String targetCondominoId,
            String exerciseId,
            String oldRole,
            String newRole) {
        try {
            keycloakServiceClient.updateUserAppRole(
                    bearerTokenResolver.resolveBearerToken(),
                    targetUserId,
                    new KeycloakAppRoleUpdateRequest(newRole));
            log.info(
                    "[AUDIT][ROLE_CHANGE] actorSub={} targetUserId={} targetCondominoId={} exerciseId={} oldRole={} newRole={} outcome=success",
                    actorSub,
                    targetUserId,
                    targetCondominoId,
                    exerciseId,
                    oldRole,
                    newRole);
        } catch (RuntimeException ex) {
            log.warn(
                    "[AUDIT][ROLE_CHANGE] actorSub={} targetUserId={} targetCondominoId={} exerciseId={} oldRole={} newRole={} outcome=failure reason={}",
                    actorSub,
                    targetUserId,
                    targetCondominoId,
                    exerciseId,
                    oldRole,
                    newRole,
                    ex.getMessage());
            throw ex;
        }
    }
}
