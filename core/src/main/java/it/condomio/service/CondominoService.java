package it.condomio.service;

import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Autowired
    private TenantAccessService tenantAccessService;

    @Autowired
    private EsercizioGuardService esercizioGuardService;

    @Autowired
    private MongoTemplate mongoTemplate;

    /** Crea condomino solo se l'utente corrente amministra l'idCondominio richiesto. */
    public Condomino createCondomino(Condomino condomino, String adminKeycloakUserId) throws ApiException {
        sanitizeForCreate(condomino);
        validateAllowedCondominoRole(condomino.getAppRole());
        validateBaseFields(condomino);
        normalizeFinancialFieldsForCreate(condomino);
        esercizioGuardService.requireOwnedOpenExercise(condomino.getIdCondominio(), adminKeycloakUserId);
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
    public List<Condomino> getAllCondomini(String keycloakUserId, String idCondominio) {
        if (idCondominio != null && !idCondominio.isBlank()) {
            if (!tenantAccessService.canViewCondominio(keycloakUserId, idCondominio)) {
                return List.of();
            }
            return condominoRepository.findByIdCondominioOrderByCognomeAscNomeAsc(idCondominio);
        }
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
        ensureExerciseOpen(existing.getIdCondominio());
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
        reconcileFinancialFieldsOnUpdate(existing, updatedCondomino);

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
        esercizioGuardService.requireOwnedOpenExercise(existing.getIdCondominio(), adminKeycloakUserId);
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
        ensureExerciseOpen(existing.getIdCondominio());
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
        reconcileFinancialFieldsOnUpdate(existing, patchedCondomino);

        patchedCondomino.setId(existing.getId());
        patchedCondomino.setVersion(existing.getVersion());
        return condominoRepository.save(patchedCondomino);
    }

    /**
     * Add versamento atomico:
     * - push sul solo array versamenti del condomino
     * - delta residui condomino + condominio con $inc
     */
    @Transactional
    public void addVersamento(String condominoId, Condomino.Versamento versamento, String adminKeycloakUserId)
            throws ApiException {
        Condomino existing = loadAdminOwnedCondomino(condominoId, adminKeycloakUserId);
        final Condomino.Versamento normalized = normalizeNewVersamento(versamento);
        validateVersamento(normalized);

        long changed = condominoRepository.addVersamentoByIdAndCondominio(
                existing.getId(),
                existing.getIdCondominio(),
                normalized);
        if (changed == 0) {
            throw new NotFoundException("condomino");
        }
        applyVersamentoResiduoDelta(existing.getId(), existing.getIdCondominio(), normalized.getImporto());
    }

    /**
     * Update versamento atomico:
     * - set della sola entry array selezionata (id versamento)
     * - delta residui calcolato come (nuovoImporto - vecchioImporto)
     */
    @Transactional
    public void updateVersamento(
            String condominoId,
            String versamentoId,
            Condomino.Versamento payload,
            String adminKeycloakUserId) throws ApiException {
        Condomino existing = loadAdminOwnedCondomino(condominoId, adminKeycloakUserId);
        Condomino.Versamento old = findVersamento(existing, versamentoId);
        if (old == null) {
            throw new NotFoundException("versamento");
        }
        Condomino.Versamento updated = normalizeUpdatedVersamento(old, payload, versamentoId);
        validateVersamento(updated);

        Query query = new Query(
                Criteria.where("_id").is(existing.getId())
                        .and("idCondominio").is(existing.getIdCondominio())
                        .and("versamenti.id").is(versamentoId));
        Update update = new Update().set("versamenti.$", updated);
        var result = mongoTemplate.updateFirst(query, update, Condomino.class);
        if (result.getMatchedCount() == 0) {
            throw new NotFoundException("versamento");
        }

        final double oldImporto = old.getImporto() == null ? 0d : old.getImporto();
        final double newImporto = updated.getImporto() == null ? 0d : updated.getImporto();
        applyVersamentoResiduoDelta(existing.getId(), existing.getIdCondominio(), newImporto - oldImporto);
    }

    /**
     * Delete versamento atomico:
     * - pull della sola entry array selezionata (id versamento)
     * - delta residui negativo sull'importo rimosso
     */
    @Transactional
    public void deleteVersamento(String condominoId, String versamentoId, String adminKeycloakUserId)
            throws ApiException {
        Condomino existing = loadAdminOwnedCondomino(condominoId, adminKeycloakUserId);
        Condomino.Versamento old = findVersamento(existing, versamentoId);
        if (old == null) {
            throw new NotFoundException("versamento");
        }
        long changed = condominoRepository.removeVersamentoByIdAndCondominio(
                existing.getId(),
                existing.getIdCondominio(),
                versamentoId);
        if (changed == 0) {
            throw new NotFoundException("versamento");
        }
        final double oldImporto = old.getImporto() == null ? 0d : old.getImporto();
        applyVersamentoResiduoDelta(existing.getId(), existing.getIdCondominio(), -oldImporto);
    }

    /** Fallisce se l'utente corrente prova a operare in scrittura su un condominio non suo. */
    private void ensureAdminOwnsCondominio(String condominioId, String adminKeycloakUserId) throws ApiException {
        if (condominioId == null || condominioId.isBlank()) {
            throw new ValidationFailedException("validation.required.condomino.idCondominio");
        }
        esercizioGuardService.requireOwnedOpenExercise(condominioId, adminKeycloakUserId);
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
        if (condomino.getSaldoIniziale() != null
                && (condomino.getSaldoIniziale().isNaN() || condomino.getSaldoIniziale().isInfinite())) {
            throw new ValidationFailedException("validation.invalid.condomino.saldoIniziale");
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
        target.setSaldoIniziale(existing.getSaldoIniziale());
        target.setResiduo(existing.getResiduo());
        target.setVersamenti(existing.getVersamenti());
    }

    private void normalizeFinancialFieldsForCreate(Condomino condomino) {
        final double saldoIniziale = condomino.getSaldoIniziale() == null ? 0d : condomino.getSaldoIniziale();
        condomino.setSaldoIniziale(saldoIniziale);
        // In creazione il residuo iniziale coincide con saldoIniziale.
        condomino.setResiduo(saldoIniziale);
        if (condomino.getVersamenti() == null) {
            condomino.setVersamenti(new ArrayList<>());
        }
    }

    private void reconcileFinancialFieldsOnUpdate(Condomino existing, Condomino target) {
        final double oldSaldo = existing.getSaldoIniziale() == null ? 0d : existing.getSaldoIniziale();
        final double newSaldo = target.getSaldoIniziale() == null ? oldSaldo : target.getSaldoIniziale();
        target.setSaldoIniziale(newSaldo);

        final double currentResiduo = existing.getResiduo() == null ? 0d : existing.getResiduo();
        final double deltaSaldo = newSaldo - oldSaldo;
        // Manteniamo il saldo iniziale come componente additiva stabile del residuo.
        target.setResiduo(currentResiduo + deltaSaldo);

        if (target.getVersamenti() == null) {
            target.setVersamenti(existing.getVersamenti());
        }
    }

    private Condomino loadAdminOwnedCondomino(String condominoId, String adminKeycloakUserId) throws ApiException {
        Optional<Condomino> existingOpt = condominoRepository.findById(condominoId);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("condomino");
        }
        Condomino existing = existingOpt.get();
        esercizioGuardService.requireOwnedOpenExercise(existing.getIdCondominio(), adminKeycloakUserId);
        return existing;
    }

    private void ensureExerciseOpen(String condominioId) throws ApiException {
        Condominio exercise = condominioRepository.findById(condominioId)
                .orElseThrow(() -> new NotFoundException("condominio"));
        esercizioGuardService.ensureOpen(exercise);
    }

    private Condomino.Versamento normalizeNewVersamento(Condomino.Versamento payload) {
        Condomino.Versamento v = payload == null ? new Condomino.Versamento() : payload;
        if (v.getId() == null || v.getId().isBlank()) {
            v.setId(UUID.randomUUID().toString());
        }
        if (v.getDate() == null) {
            v.setDate(Instant.now());
        }
        if (v.getInsertedAt() == null) {
            v.setInsertedAt(Instant.now());
        }
        if (v.getRipartizioneTabelle() == null) {
            v.setRipartizioneTabelle(new ArrayList<>());
        }
        return v;
    }

    private Condomino.Versamento normalizeUpdatedVersamento(
            Condomino.Versamento old,
            Condomino.Versamento payload,
            String versamentoId) {
        Condomino.Versamento v = payload == null ? new Condomino.Versamento() : payload;
        v.setId(versamentoId);
        if (v.getDate() == null) {
            v.setDate(old.getDate());
        }
        if (v.getInsertedAt() == null) {
            v.setInsertedAt(old.getInsertedAt());
        }
        if (v.getRipartizioneTabelle() == null) {
            v.setRipartizioneTabelle(old.getRipartizioneTabelle());
        }
        return v;
    }

    private void validateVersamento(Condomino.Versamento versamento) throws ValidationFailedException {
        if (versamento.getDescrizione() == null || versamento.getDescrizione().trim().isEmpty()) {
            throw new ValidationFailedException("validation.required.versamento.descrizione");
        }
        if (versamento.getImporto() == null || !Double.isFinite(versamento.getImporto()) || versamento.getImporto() <= 0d) {
            throw new ValidationFailedException("validation.invalid.versamento.importo");
        }
    }

    private Condomino.Versamento findVersamento(Condomino condomino, String versamentoId) {
        if (condomino.getVersamenti() == null || condomino.getVersamenti().isEmpty()) {
            return null;
        }
        for (Condomino.Versamento versamento : condomino.getVersamenti()) {
            if (versamento == null || versamento.getId() == null) {
                continue;
            }
            if (versamentoId.equals(versamento.getId())) {
                return versamento;
            }
        }
        return null;
    }

    private void applyVersamentoResiduoDelta(String condominoId, String idCondominio, double delta) {
        if (Math.abs(delta) <= 0.000001d) {
            return;
        }
        final double rounded = round2(delta);
        condominoRepository.incResiduoByIdAndCondominio(condominoId, idCondominio, rounded);
        condominioRepository.incResiduoById(idCondominio, rounded);
    }

    private double round2(double value) {
        return Math.round(value * 100d) / 100d;
    }
}
