package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Movimenti;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.MovimentiRepository;
import it.condomio.util.JsonMergePatchHelper;
import tools.jackson.databind.JsonNode;

@Service
public class MovimentiService {

    @Autowired
    private MovimentiRepository movimentiRepository;

    @Autowired
    private TenantAccessService tenantAccessService;

    public Movimenti createMovimento(Movimenti movimento, String keycloakUserId) throws ApiException {
        validateMovimento(movimento);
        ensureAdminOwnsCondominio(movimento.getIdCondominio(), keycloakUserId);
        movimento.setId(null);
        movimento.setVersion(null);
        return movimentiRepository.save(movimento);
    }

    public Optional<Movimenti> getMovimentoById(String id, String keycloakUserId) {
        List<String> visibleCondominioIds = tenantAccessService.findVisibleCondominioIds(keycloakUserId);
        if (visibleCondominioIds.isEmpty()) {
            return Optional.empty();
        }
        return movimentiRepository.findByIdAndIdCondominioIn(id, visibleCondominioIds);
    }

    public List<Movimenti> getAllMovimenti(String keycloakUserId) {
        List<String> visibleCondominioIds = tenantAccessService.findVisibleCondominioIds(keycloakUserId);
        if (visibleCondominioIds.isEmpty()) {
            return List.of();
        }
        return movimentiRepository.findByIdCondominioIn(visibleCondominioIds);
    }

    public Movimenti updateMovimento(String id, Movimenti updatedMovimento, String keycloakUserId) throws ApiException {
        Optional<Movimenti> existingOpt = movimentiRepository.findById(id);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("movimento");
        }
        Movimenti existing = existingOpt.get();
        ensureAdminOwnsCondominio(existing.getIdCondominio(), keycloakUserId);
        updatedMovimento.setIdCondominio(existing.getIdCondominio());
        updatedMovimento.setVersion(existing.getVersion());
        validateMovimento(updatedMovimento);
        updatedMovimento.setId(id);
        return movimentiRepository.save(updatedMovimento);
    }

    public void deleteMovimento(String id, String keycloakUserId) throws ApiException {
        Optional<Movimenti> existingOpt = movimentiRepository.findById(id);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("movimento");
        }
        ensureAdminOwnsCondominio(existingOpt.get().getIdCondominio(), keycloakUserId);
        movimentiRepository.deleteById(id);
    }

    public Movimenti patch(String id, JsonNode mergePatch, String keycloakUserId)
            throws IOException, ValidationFailedException, ApiException {
        Optional<Movimenti> optionalMovimenti = movimentiRepository.findById(id);
        if (optionalMovimenti.isEmpty()) {
            throw new NotFoundException("movimento");
        }
        Movimenti existing = optionalMovimenti.get();
        ensureAdminOwnsCondominio(existing.getIdCondominio(), keycloakUserId);
        Movimenti patchedMovimenti = JsonMergePatchHelper.applyMergePatch(mergePatch, existing, Movimenti.class);
        patchedMovimenti.setId(existing.getId());
        patchedMovimenti.setVersion(existing.getVersion());
        patchedMovimenti.setIdCondominio(existing.getIdCondominio());
        validateMovimento(patchedMovimenti);
        return movimentiRepository.save(patchedMovimenti);
    }

    private void ensureAdminOwnsCondominio(String condominioId, String keycloakUserId) throws ApiException {
        if (condominioId == null || condominioId.isBlank()) {
            throw new ValidationFailedException("validation.required.movimento.idCondominio");
        }
        if (!tenantAccessService.ownsCondominio(keycloakUserId, condominioId)) {
            throw new ForbiddenException();
        }
    }

    private void validateMovimento(Movimenti movimento) throws ValidationFailedException {
        if (movimento.getIdCondominio() == null || movimento.getIdCondominio().isBlank()) {
            throw new ValidationFailedException("validation.required.movimento.idCondominio");
        }
        if (movimento.getCodiceSpesa() == null || movimento.getCodiceSpesa().isBlank()) {
            throw new ValidationFailedException("validation.required.movimento.codiceSpesa");
        }
        if (movimento.getImporto() == null) {
            throw new ValidationFailedException("validation.required.movimento.importo");
        }
    }
}
