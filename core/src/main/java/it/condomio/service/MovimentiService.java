package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import it.condomio.document.Movimenti;
import it.condomio.exception.ApiException;
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

    @Autowired
    private RipartoRealtimeService ripartoRealtimeService;

    @Autowired
    private EsercizioGuardService esercizioGuardService;

    /**
     * Create movimento + aggiornamento residui come unita' atomica logica.
     * In Mongo la vera atomicita' multi-documento richiede replica set attivo.
     */
    @Transactional
    public Movimenti createMovimento(Movimenti movimento, String keycloakUserId) throws ApiException {
        validateMovimento(movimento);
        ensureAdminOwnsCondominio(movimento.getIdCondominio(), keycloakUserId);
        movimento.setId(null);
        movimento.setVersion(null);
        Movimenti enriched = ripartoRealtimeService.enrichMovimentoWithRiparto(movimento);
        Movimenti saved = movimentiRepository.save(enriched);
        ripartoRealtimeService.applyMovimentoDelta(saved.getIdCondominio(), null, saved);
        return saved;
    }

    public Optional<Movimenti> getMovimentoById(String id, String keycloakUserId) {
        List<String> visibleCondominioIds = tenantAccessService.findVisibleCondominioIds(keycloakUserId);
        if (visibleCondominioIds.isEmpty()) {
            return Optional.empty();
        }
        return movimentiRepository.findByIdAndIdCondominioIn(id, visibleCondominioIds);
    }

    public List<Movimenti> getAllMovimenti(String keycloakUserId, String idCondominio) {
        if (idCondominio != null && !idCondominio.isBlank()) {
            if (!tenantAccessService.canViewCondominio(keycloakUserId, idCondominio)) {
                return List.of();
            }
            return movimentiRepository.findByIdCondominioOrderByDateDesc(idCondominio);
        }
        List<String> visibleCondominioIds = tenantAccessService.findVisibleCondominioIds(keycloakUserId);
        if (visibleCondominioIds.isEmpty()) {
            return List.of();
        }
        return movimentiRepository.findByIdCondominioIn(visibleCondominioIds);
    }

    /**
     * Update full movimento + delta residui nella stessa transazione applicativa.
     */
    @Transactional
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
        Movimenti enriched = ripartoRealtimeService.enrichMovimentoWithRiparto(updatedMovimento);
        Movimenti saved = movimentiRepository.save(enriched);
        ripartoRealtimeService.applyMovimentoDelta(saved.getIdCondominio(), existing, saved);
        return saved;
    }

    /**
     * Delete movimento + rollback contabile residui nella stessa unita' di lavoro.
     */
    @Transactional
    public void deleteMovimento(String id, String keycloakUserId) throws ApiException {
        Optional<Movimenti> existingOpt = movimentiRepository.findById(id);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("movimento");
        }
        final String idCondominio = existingOpt.get().getIdCondominio();
        final Movimenti existing = existingOpt.get();
        ensureAdminOwnsCondominio(idCondominio, keycloakUserId);
        movimentiRepository.deleteById(id);
        ripartoRealtimeService.applyMovimentoDelta(idCondominio, existing, null);
    }

    /**
     * Patch movimento + applicazione delta residui in modo consistente.
     */
    @Transactional
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
        Movimenti enriched = ripartoRealtimeService.enrichMovimentoWithRiparto(patchedMovimenti);
        Movimenti saved = movimentiRepository.save(enriched);
        ripartoRealtimeService.applyMovimentoDelta(saved.getIdCondominio(), existing, saved);
        return saved;
    }

    /** Rebuild completo residui (manutenzione/allineamento straordinario). */
    @Transactional
    public void rebuildResidui(String idCondominio, String keycloakUserId) throws ApiException {
        ensureAdminOwnsCondominio(idCondominio, keycloakUserId);
        ripartoRealtimeService.recomputeCondominioResidui(idCondominio);
    }

    /** Rebuild storico completo: riparti movimenti + residui sul condominio corrente. */
    @Transactional
    public void rebuildStorico(String idCondominio, String keycloakUserId) throws ApiException {
        ensureAdminOwnsCondominio(idCondominio, keycloakUserId);
        ripartoRealtimeService.rebuildStoricoCondominio(idCondominio);
    }

    private void ensureAdminOwnsCondominio(String condominioId, String keycloakUserId) throws ApiException {
        if (condominioId == null || condominioId.isBlank()) {
            throw new ValidationFailedException("validation.required.movimento.idCondominio");
        }
        esercizioGuardService.requireOwnedOpenExercise(condominioId, keycloakUserId);
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
