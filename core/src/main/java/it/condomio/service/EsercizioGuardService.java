package it.condomio.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Service;

import it.condomio.document.Condominio;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;

/**
 * Guard centralizzato per ownership e stato dell'esercizio.
 *
 * Tutte le scritture devono passare da qui per evitare comportamenti incoerenti
 * quando un esercizio e' chiuso.
 */
@Service
public class EsercizioGuardService {
    private static final String ADMIN_REALM_ROLE = "amministratore";


    @Autowired
    private CondominioRepository condominioRepository;

    @Autowired
    private TenantAccessService tenantAccessService;

    public Condominio requireOwnedExercise(String esercizioId, String keycloakUserId) throws ApiException {
        requireAdminRealmRole();
        Condominio esercizio = condominioRepository.findById(esercizioId)
                .orElseThrow(() -> new NotFoundException("condominio"));
        if (!tenantAccessService.ownsCondominio(keycloakUserId, esercizioId)) {
            throw new ForbiddenException();
        }
        return esercizio;
    }

    public Condominio requireOwnedOpenExercise(String esercizioId, String keycloakUserId) throws ApiException {
        Condominio esercizio = requireOwnedExercise(esercizioId, keycloakUserId);
        ensureOpen(esercizio);
        return esercizio;
    }

    public void ensureOpen(Condominio esercizio) throws ValidationFailedException {
        if (esercizio == null) {
            return;
        }
        if (esercizio.getStato() == Condominio.EsercizioStato.CLOSED) {
            throw new ValidationFailedException("validation.esercizio.closed");
        }
    }

    /**
     * Hardening BE: le scritture sull'esercizio richiedono sia ownership tenant
     * sia ruolo realm "amministratore" nel token JWT corrente.
     */
    private void requireAdminRealmRole() throws ForbiddenException {
        final Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication instanceof JwtAuthenticationToken jwtAuth)) {
            throw new ForbiddenException();
        }

        final Object realmAccessRaw = jwtAuth.getToken().getClaims().get("realm_access");
        if (!(realmAccessRaw instanceof Map<?, ?> realmAccess)) {
            throw new ForbiddenException();
        }
        final Object rolesRaw = realmAccess.get("roles");
        if (!(rolesRaw instanceof List<?> roles)) {
            throw new ForbiddenException();
        }

        final String expected = ADMIN_REALM_ROLE;
        final String expectedPrefixed = "ROLE_" + ADMIN_REALM_ROLE;
        for (Object role : roles) {
            if (!(role instanceof String roleName)) {
                continue;
            }
            if (expected.equalsIgnoreCase(roleName) || expectedPrefixed.equalsIgnoreCase(roleName)) {
                return;
            }
        }
        throw new ForbiddenException();
    }
}
