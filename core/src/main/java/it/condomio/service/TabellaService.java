package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Tabella;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.TabellaRepository;
import it.condomio.util.JsonMergePatchHelper;
import tools.jackson.databind.JsonNode;

@Service
public class TabellaService {

    @Autowired
    private TabellaRepository tabellaRepository;

    @Autowired
    private TenantAccessService tenantAccessService;

    public Tabella createTabella(Tabella tabella, String keycloakUserId) throws ApiException {
        validateTabella(tabella);
        ensureAdminOwnsCondominio(tabella.getIdCondominio(), keycloakUserId);
        ensureUniqueCodice(tabella.getIdCondominio(), tabella.getCodice(), null);
        tabella.setId(null);
        tabella.setVersion(null);
        return tabellaRepository.save(tabella);
    }

    public Optional<Tabella> getTabellaById(String id, String keycloakUserId) {
        List<String> visibleCondominioIds = tenantAccessService.findVisibleCondominioIds(keycloakUserId);
        if (visibleCondominioIds.isEmpty()) {
            return Optional.empty();
        }
        return tabellaRepository.findByIdAndIdCondominioIn(id, visibleCondominioIds);
    }

    public List<Tabella> getAllTabelle(String keycloakUserId) {
        List<String> visibleCondominioIds = tenantAccessService.findVisibleCondominioIds(keycloakUserId);
        if (visibleCondominioIds.isEmpty()) {
            return List.of();
        }
        return tabellaRepository.findByIdCondominioIn(visibleCondominioIds);
    }

    public Tabella updateTabella(String id, Tabella updatedTabella, String keycloakUserId) throws ApiException {
        Optional<Tabella> existingOpt = tabellaRepository.findById(id);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("tabella");
        }
        Tabella existing = existingOpt.get();
        ensureAdminOwnsCondominio(existing.getIdCondominio(), keycloakUserId);
        updatedTabella.setIdCondominio(existing.getIdCondominio());
        updatedTabella.setVersion(existing.getVersion());
        validateTabella(updatedTabella);
        ensureUniqueCodice(existing.getIdCondominio(), updatedTabella.getCodice(), existing.getId());
        updatedTabella.setId(id);
        return tabellaRepository.save(updatedTabella);
    }

    public void deleteTabella(String id, String keycloakUserId) throws ApiException {
        Optional<Tabella> existingOpt = tabellaRepository.findById(id);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("tabella");
        }
        ensureAdminOwnsCondominio(existingOpt.get().getIdCondominio(), keycloakUserId);
        tabellaRepository.deleteById(id);
    }

    public Tabella patch(String id, JsonNode mergePatch, String keycloakUserId)
            throws IOException, ValidationFailedException, ApiException {
        Optional<Tabella> optionalTabella = tabellaRepository.findById(id);
        if (optionalTabella.isEmpty()) {
            throw new NotFoundException("tabella");
        }
        Tabella existing = optionalTabella.get();
        ensureAdminOwnsCondominio(existing.getIdCondominio(), keycloakUserId);
        Tabella patchedTabella = JsonMergePatchHelper.applyMergePatch(mergePatch, existing, Tabella.class);
        patchedTabella.setId(existing.getId());
        patchedTabella.setVersion(existing.getVersion());
        patchedTabella.setIdCondominio(existing.getIdCondominio());
        validateTabella(patchedTabella);
        ensureUniqueCodice(existing.getIdCondominio(), patchedTabella.getCodice(), existing.getId());
        return tabellaRepository.save(patchedTabella);
    }

    private void ensureAdminOwnsCondominio(String condominioId, String keycloakUserId) throws ApiException {
        if (condominioId == null || condominioId.isBlank()) {
            throw new ValidationFailedException("validation.required.tabella.idCondominio");
        }
        if (!tenantAccessService.ownsCondominio(keycloakUserId, condominioId)) {
            throw new ForbiddenException();
        }
    }

    private void validateTabella(Tabella tabella) throws ValidationFailedException {
        if (tabella.getIdCondominio() == null || tabella.getIdCondominio().isBlank()) {
            throw new ValidationFailedException("validation.required.tabella.idCondominio");
        }
        if (tabella.getCodice() == null || tabella.getCodice().isBlank()) {
            throw new ValidationFailedException("validation.required.tabella.codice");
        }
    }

    private void ensureUniqueCodice(String idCondominio, String codice, String excludeId)
            throws ValidationFailedException {
        if (excludeId == null || excludeId.isBlank()) {
            if (tabellaRepository.existsByIdCondominioAndCodiceIgnoreCase(idCondominio, codice)) {
                throw new ValidationFailedException("validation.duplicate.tabella.codice");
            }
            return;
        }
        if (tabellaRepository.existsByIdCondominioAndCodiceIgnoreCaseAndIdNot(idCondominio, codice, excludeId)) {
            throw new ValidationFailedException("validation.duplicate.tabella.codice");
        }
    }
}
