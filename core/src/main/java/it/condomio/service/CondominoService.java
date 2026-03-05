package it.condomio.service;

import java.io.IOException;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Condominio;
import it.condomio.document.Condomino;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominoRepository;
import it.condomio.util.JsonMergePatchHelper;
import tools.jackson.databind.JsonNode;

/**
 * Service tenant-aware per anagrafica condomini.
 * - Lettura: consentita su condomini "visibili" (admin o condomino associato).
 * - Scrittura: consentita solo all'admin del condominio target.
 */
@Service
public class CondominoService {
    private static final String APP_ROLE_STANDARD = "default-roles-condominio";
    private static final String APP_ROLE_CONSIGLIERE = "consigliere";


    @Autowired
    private CondominoRepository condominoRepository;

    @Autowired
    private CondominioRepository condominioRepository;

    /** Crea condomino solo se l'utente corrente amministra l'idCondominio richiesto. */
    public Condomino createCondomino(Condomino condomino, String adminKeycloakUserId) throws ApiException {
        validateAllowedCondominoRole(condomino.getAppRole());
        ensureAdminOwnsCondominio(condomino.getIdCondominio(), adminKeycloakUserId);
        return condominoRepository.save(condomino);
    }

    /** Lettura puntuale filtrata per tenant visibili: no accesso cross-condominio. */
    public Optional<Condomino> getCondominoById(String id, String keycloakUserId) {
        List<String> visibleCondominioIds = findVisibleCondominioIds(keycloakUserId);
        if (visibleCondominioIds.isEmpty()) {
            return Optional.empty();
        }
        return condominoRepository.findByIdAndIdCondominioIn(id, visibleCondominioIds);
    }

    /** Elenco anagrafica su condomini visibili all'utente corrente. */
    public List<Condomino> getAllCondomini(String keycloakUserId) {
        List<String> visibleCondominioIds = findVisibleCondominioIds(keycloakUserId);
        if (visibleCondominioIds.isEmpty()) {
            return List.of();
        }
        return condominoRepository.findByIdCondominioIn(visibleCondominioIds);
    }

    /** Update full document con validazione ownership admin su record corrente e target. */
    public Condomino updateCondomino(String id, Condomino updatedCondomino, String adminKeycloakUserId)
            throws ApiException {
        validateAllowedCondominoRole(updatedCondomino.getAppRole());
        List<String> ownedCondominioIds = findOwnedCondominioIds(adminKeycloakUserId);
        Optional<Condomino> existingOpt = condominoRepository.findByIdAndIdCondominioIn(id, ownedCondominioIds);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("condomino");
        }

        Condomino existing = existingOpt.get();
        String targetCondominioId = updatedCondomino.getIdCondominio() != null
                ? updatedCondomino.getIdCondominio()
                : existing.getIdCondominio();
        ensureAdminOwnsCondominio(targetCondominioId, adminKeycloakUserId);

        updatedCondomino.setId(id);
        updatedCondomino.setVersion(existing.getVersion());
        return condominoRepository.save(updatedCondomino);
    }

    /** Delete permessa solo su record appartenenti ai condomini amministrati. */
    public void deleteCondomino(String id, String adminKeycloakUserId) throws ApiException {
        List<String> ownedCondominioIds = findOwnedCondominioIds(adminKeycloakUserId);
        if (!condominoRepository.existsByIdAndIdCondominioIn(id, ownedCondominioIds)) {
            throw new NotFoundException("condomino");
        }
        condominoRepository.deleteById(id);
    }

    /** Patch merge JSON con enforcement tenant + conservazione id/version per evitare insert involontari. */
    public Condomino patch(String id, JsonNode mergePatch, String adminKeycloakUserId)
            throws IOException, ValidationFailedException, ApiException {
        List<String> ownedCondominioIds = findOwnedCondominioIds(adminKeycloakUserId);
        Optional<Condomino> optionalCondomino = condominoRepository.findByIdAndIdCondominioIn(id, ownedCondominioIds);
        if (optionalCondomino.isEmpty()) {
            throw new NotFoundException("condomino");
        }

        Condomino existing = optionalCondomino.get();
        Condomino patchedCondomino = JsonMergePatchHelper.applyMergePatch(mergePatch, existing, Condomino.class);

        String targetCondominioId = patchedCondomino.getIdCondominio() != null
                ? patchedCondomino.getIdCondominio()
                : existing.getIdCondominio();
        validateAllowedCondominoRole(patchedCondomino.getAppRole());
        ensureAdminOwnsCondominio(targetCondominioId, adminKeycloakUserId);

        patchedCondomino.setId(existing.getId());
        patchedCondomino.setVersion(existing.getVersion());
        return condominoRepository.save(patchedCondomino);
    }

    /** Risolve gli idCondominio di cui l'utente JWT e' amministratore. */
    private List<String> findOwnedCondominioIds(String adminKeycloakUserId) {
        return condominioRepository.findByAdminKeycloakUserId(adminKeycloakUserId)
                .stream()
                .map(Condominio::getId)
                .filter(id -> id != null && !id.isBlank())
                .collect(Collectors.toList());
    }

    /**
     * Risolve tutti i condomini visibili:
     * - come admin del condominio
     * - come condomino collegato via keycloakUserId
     */
    private List<String> findVisibleCondominioIds(String keycloakUserId) {
        Set<String> ids = new LinkedHashSet<>();

        for (Condominio c : condominioRepository.findByAdminKeycloakUserId(keycloakUserId)) {
            if (c.getId() != null && !c.getId().isBlank()) {
                ids.add(c.getId());
            }
        }

        for (Condomino c : condominoRepository.findByKeycloakUserId(keycloakUserId)) {
            if (c.getIdCondominio() != null && !c.getIdCondominio().isBlank()) {
                ids.add(c.getIdCondominio());
            }
        }

        return List.copyOf(ids);
    }

    /** Fallisce se l'utente corrente prova a operare in scrittura su un condominio non suo. */
    private void ensureAdminOwnsCondominio(String condominioId, String adminKeycloakUserId) throws ApiException {
        if (condominioId == null || condominioId.isBlank()) {
            throw new ValidationFailedException("validation.required.condomino.idCondominio");
        }
        boolean owns = condominioRepository.existsByIdAndAdminKeycloakUserId(condominioId, adminKeycloakUserId);
        if (!owns) {
            throw new ForbiddenException();
        }
    }

    /**
     * Nel dominio applicativo i soli ruoli assegnabili al condomino sono:
     * - consigliere
     * - standard (default-roles-condominio)
     * L'admin del condominio e' gestito separatamente su Condominio.adminKeycloakUserId.
     */
    private void validateAllowedCondominoRole(String appRole) throws ValidationFailedException {
        if (appRole == null) {
            return;
        }
        final String normalized = appRole.trim().toLowerCase();
        final boolean allowed = APP_ROLE_CONSIGLIERE.equals(normalized)
                || APP_ROLE_STANDARD.equals(normalized)
                || "standard".equals(normalized);
        if (!allowed) {
            throw new ValidationFailedException("validation.invalid.condomino.appRole");
        }
    }
}
