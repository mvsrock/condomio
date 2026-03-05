package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Condomino;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
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
    private TenantAccessService tenantAccessService;

    /** Crea condomino solo se l'utente corrente amministra l'idCondominio richiesto. */
    public Condomino createCondomino(Condomino condomino, String adminKeycloakUserId) throws ApiException {
        sanitizeForCreate(condomino);
        validateAllowedCondominoRole(condomino.getAppRole());
        validateBaseFields(condomino);
        ensureAdminOwnsCondominio(condomino.getIdCondominio(), adminKeycloakUserId);
        ensureUniqueEmailOnCondominio(condomino.getIdCondominio(), condomino.getEmail(), null);
        return condominoRepository.save(condomino);
    }

    /** Lettura puntuale filtrata per tenant visibili: no accesso cross-condominio. */
    public Optional<Condomino> getCondominoById(String id, String keycloakUserId) {
        List<String> ownedCondominioIds = tenantAccessService.findOwnedCondominioIds(keycloakUserId);
        if (!ownedCondominioIds.isEmpty()) {
            return condominoRepository.findByIdAndIdCondominioIn(id, ownedCondominioIds);
        }
        return condominoRepository.findById(id)
                .filter(c -> keycloakUserId.equals(c.getKeycloakUserId()));
    }

    /** Elenco anagrafica su condomini visibili all'utente corrente. */
    public List<Condomino> getAllCondomini(String keycloakUserId) {
        List<String> ownedCondominioIds = tenantAccessService.findOwnedCondominioIds(keycloakUserId);
        if (!ownedCondominioIds.isEmpty()) {
            return condominoRepository.findByIdCondominioIn(ownedCondominioIds);
        }
        return condominoRepository.findByKeycloakUserId(keycloakUserId);
    }

    /** Update full document con validazione ownership admin su record corrente e target. */
    public Condomino updateCondomino(String id, Condomino updatedCondomino, String adminKeycloakUserId)
            throws ApiException {
        Optional<Condomino> existingOpt = condominoRepository.findById(id);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("condomino");
        }

        Condomino existing = existingOpt.get();
        boolean isAdminOwner = tenantAccessService.ownsCondominio(adminKeycloakUserId, existing.getIdCondominio());
        boolean isSelf = adminKeycloakUserId.equals(existing.getKeycloakUserId());
        if (!isAdminOwner && !isSelf) {
            throw new ForbiddenException();
        }
        if (!isAdminOwner) {
            applyNonAdminUpdateGuards(updatedCondomino, existing);
        } else {
            validateAllowedCondominoRole(updatedCondomino.getAppRole());
        }
        validateBaseFields(updatedCondomino);
        ensureUniqueEmailOnCondominio(
                updatedCondomino.getIdCondominio(),
                updatedCondomino.getEmail(),
                existing.getId());

        updatedCondomino.setId(id);
        updatedCondomino.setVersion(existing.getVersion());
        return condominoRepository.save(updatedCondomino);
    }

    /** Delete permessa solo su record appartenenti ai condomini amministrati. */
    public void deleteCondomino(String id, String adminKeycloakUserId) throws ApiException {
        Optional<Condomino> existingOpt = condominoRepository.findById(id);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("condomino");
        }
        Condomino existing = existingOpt.get();
        if (!tenantAccessService.ownsCondominio(adminKeycloakUserId, existing.getIdCondominio())) {
            throw new ForbiddenException();
        }
        condominoRepository.deleteById(id);
    }

    /** Patch merge JSON con enforcement tenant + conservazione id/version per evitare insert involontari. */
    public Condomino patch(String id, JsonNode mergePatch, String adminKeycloakUserId)
            throws IOException, ValidationFailedException, ApiException {
        Optional<Condomino> optionalCondomino = condominoRepository.findById(id);
        if (optionalCondomino.isEmpty()) {
            throw new NotFoundException("condomino");
        }

        Condomino existing = optionalCondomino.get();
        Condomino patchedCondomino = JsonMergePatchHelper.applyMergePatch(mergePatch, existing, Condomino.class);

        boolean isAdminOwner = tenantAccessService.ownsCondominio(adminKeycloakUserId, existing.getIdCondominio());
        boolean isSelf = adminKeycloakUserId.equals(existing.getKeycloakUserId());
        if (!isAdminOwner && !isSelf) {
            throw new ForbiddenException();
        }
        if (!isAdminOwner) {
            applyNonAdminUpdateGuards(patchedCondomino, existing);
        } else {
            validateAllowedCondominoRole(patchedCondomino.getAppRole());
        }
        validateBaseFields(patchedCondomino);
        ensureUniqueEmailOnCondominio(
                patchedCondomino.getIdCondominio(),
                patchedCondomino.getEmail(),
                existing.getId());

        patchedCondomino.setId(existing.getId());
        patchedCondomino.setVersion(existing.getVersion());
        return condominoRepository.save(patchedCondomino);
    }

    /** Fallisce se l'utente corrente prova a operare in scrittura su un condominio non suo. */
    private void ensureAdminOwnsCondominio(String condominioId, String adminKeycloakUserId) throws ApiException {
        if (condominioId == null || condominioId.isBlank()) {
            throw new ValidationFailedException("validation.required.condomino.idCondominio");
        }
        boolean owns = tenantAccessService.ownsCondominio(adminKeycloakUserId, condominioId);
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

    private void validateBaseFields(Condomino condomino) throws ValidationFailedException {
        if (condomino.getNome() == null || condomino.getNome().trim().isEmpty()) {
            throw new ValidationFailedException("validation.required.condomino.nome");
        }
        if (condomino.getCognome() == null || condomino.getCognome().trim().isEmpty()) {
            throw new ValidationFailedException("validation.required.condomino.cognome");
        }
        if (condomino.getEmail() == null || condomino.getEmail().trim().isEmpty()) {
            throw new ValidationFailedException("validation.required.condomino.email");
        }
        if (condomino.getIdCondominio() == null || condomino.getIdCondominio().isBlank()) {
            throw new ValidationFailedException("validation.required.condomino.idCondominio");
        }
    }

    private void sanitizeForCreate(Condomino condomino) {
        // Evita collisioni _id: sul create l'id viene sempre generato da Mongo.
        condomino.setId(null);
        condomino.setVersion(null);
    }

    private void ensureUniqueEmailOnCondominio(String idCondominio, String email, String excludeId)
            throws ValidationFailedException {
        if (excludeId == null || excludeId.isBlank()) {
            if (condominoRepository.existsByIdCondominioAndEmailIgnoreCase(idCondominio, email)) {
                throw new ValidationFailedException("validation.duplicate.condomino.email");
            }
            return;
        }
        if (condominoRepository.existsByIdCondominioAndEmailIgnoreCaseAndIdNot(idCondominio, email, excludeId)) {
            throw new ValidationFailedException("validation.duplicate.condomino.email");
        }
    }

    private void applyNonAdminUpdateGuards(Condomino target, Condomino existing) {
        // Utente non admin: puo' aggiornare solo i propri dati anagrafici base.
        target.setIdCondominio(existing.getIdCondominio());
        target.setAppRole(existing.getAppRole());
        target.setAppEnabled(existing.getAppEnabled());
        target.setKeycloakUserId(existing.getKeycloakUserId());
        target.setKeycloakUsername(existing.getKeycloakUsername());
    }
}
