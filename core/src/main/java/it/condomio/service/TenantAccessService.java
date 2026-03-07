package it.condomio.service;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Condominio;
import it.condomio.document.Condomino;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominoRepository;

/**
 * Risoluzione centralizzata della visibilita' tenant.
 *
 * Regole:
 * - owned: condomini dove l'utente JWT e' admin.
 * - visible: owned + condomini dove e' associato come condomino.
 */
@Service
public class TenantAccessService {

    @Autowired
    private CondominioRepository condominioRepository;

    @Autowired
    private CondominoRepository condominoRepository;

    public List<String> findOwnedCondominioIds(String keycloakUserId) {
        return condominioRepository.findByAdminKeycloakUserId(keycloakUserId)
                .stream()
                .map(Condominio::getId)
                .filter(id -> id != null && !id.isBlank())
                .collect(Collectors.toList());
    }

    public List<String> findVisibleCondominioIds(String keycloakUserId) {
        Set<String> ids = new LinkedHashSet<>();

        for (Condominio c : condominioRepository.findByAdminKeycloakUserId(keycloakUserId)) {
            if (c.getId() != null && !c.getId().isBlank()) {
                ids.add(c.getId());
            }
        }

        for (Condomino posizione : condominoRepository.findByKeycloakUserId(keycloakUserId)) {
            if (posizione.getIdCondominio() != null && !posizione.getIdCondominio().isBlank()) {
                ids.add(posizione.getIdCondominio());
            }
        }

        return List.copyOf(ids);
    }

    public boolean ownsCondominio(String keycloakUserId, String condominioId) {
        return condominioRepository.existsByIdAndAdminKeycloakUserId(condominioId, keycloakUserId);
    }

    public boolean canViewCondominio(String keycloakUserId, String condominioId) {
        if (ownsCondominio(keycloakUserId, condominioId)) {
            return true;
        }
        return condominoRepository.existsByIdCondominioAndKeycloakUserId(condominioId, keycloakUserId);
    }
}
