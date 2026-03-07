package it.condomio.service;

import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import it.condomio.controller.model.CondominoResource;
import it.condomio.document.Condominio;
import it.condomio.document.Condomino;
import it.condomio.document.CondominoRoot;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominoRepository;
import it.condomio.repository.CondominoRootRepository;
import it.condomio.util.JsonMergePatchHelper;
import tools.jackson.databind.JsonNode;

/**
 * Service tenant-aware per anagrafica condomini.
 *
 * Modello applicato:
 * - `CondominoRoot`: anagrafica stabile e accesso applicativo
 * - `Condomino`: posizione del condomino nel singolo esercizio
 *
 * L'API resta flat verso il frontend, ma il backend non duplica piu' l'identita'
 * del condomino quando apre un nuovo esercizio: duplica solo la posizione.
 */
@Service
public class CondominoService {
    private static final String APP_ROLE_STANDARD = "default-roles-condominio";
    private static final String APP_ROLE_CONSIGLIERE = "consigliere";

    @Autowired
    private CondominoRepository condominoRepository;

    @Autowired
    private CondominoRootRepository condominoRootRepository;

    @Autowired
    private CondominioRepository condominioRepository;

    @Autowired
    private TenantAccessService tenantAccessService;

    @Autowired
    private EsercizioGuardService esercizioGuardService;

    @Autowired
    private MongoTemplate mongoTemplate;

    /** Crea una nuova posizione esercizio, riusando o creando l'anagrafica stabile. */
    public CondominoResource createCondomino(CondominoResource resource, String adminKeycloakUserId)
            throws ApiException {
        sanitizeForCreate(resource);
        validateAllowedCondominoRole(resource.getAppRole());
        validateBaseFields(resource);

        Condominio exercise = esercizioGuardService.requireOwnedOpenExercise(
                resource.getIdCondominio(),
                adminKeycloakUserId);
        normalizeStableFields(resource);

        StableRootWriteResult rootWrite = resolveOrCreateStableRootForCreate(exercise, resource);
        CondominoRoot stableRoot = rootWrite.root();
        ensureUniquePositionOnExercise(exercise.getId(), stableRoot.getId(), null);

        Condomino position = buildPositionForCreate(resource, exercise, stableRoot);
        normalizeFinancialFieldsForCreate(position);
        Condomino saved = condominoRepository.save(position);
        if (rootWrite.syncOtherPositions()) {
            syncPositionSnapshots(stableRoot, saved.getId());
        }
        return toResource(saved, stableRoot);
    }

    /** Lettura puntuale filtrata per tenant visibile: admin owner o condomino associato. */
    public Optional<CondominoResource> getCondominoById(String id, String keycloakUserId) {
        Optional<Condomino> positionOpt = condominoRepository.findById(id);
        if (positionOpt.isEmpty()) {
            return Optional.empty();
        }

        Condomino position = positionOpt.get();
        boolean isAdminOwner = tenantAccessService.ownsCondominio(keycloakUserId, position.getIdCondominio());
        boolean isSelf = keycloakUserId.equals(position.getKeycloakUserId());
        CondominoRoot root = null;
        if (!isAdminOwner && !isSelf) {
            try {
                root = loadStableRoot(position.getCondominoRootId());
            } catch (NotFoundException ex) {
                return Optional.empty();
            }
            isSelf = keycloakUserId.equals(root.getKeycloakUserId());
        }
        if (!isAdminOwner && !isSelf) {
            return Optional.empty();
        }
        if (requiresStableRootFallback(position)) {
            try {
                root = root == null ? loadStableRoot(position.getCondominoRootId()) : root;
            } catch (NotFoundException ex) {
                return Optional.empty();
            }
        }
        return Optional.of(toResource(position, root));
    }

    /** Elenco anagrafica sulle posizioni esercizio visibili all'utente corrente. */
    public List<CondominoResource> getAllCondomini(String keycloakUserId, String idCondominio) {
        final List<Condomino> positions;
        if (idCondominio != null && !idCondominio.isBlank()) {
            if (!tenantAccessService.canViewCondominio(keycloakUserId, idCondominio)) {
                return List.of();
            }
            positions = condominoRepository.findByIdCondominioOrderByCognomeAscNomeAsc(idCondominio);
        } else {
            List<String> ownedExerciseIds = tenantAccessService.findOwnedCondominioIds(keycloakUserId);
            if (!ownedExerciseIds.isEmpty()) {
                positions = condominoRepository.findByIdCondominioIn(ownedExerciseIds);
            } else {
                List<String> stableRootIds = condominoRootRepository.findByKeycloakUserId(keycloakUserId)
                        .stream()
                        .map(CondominoRoot::getId)
                        .filter(value -> value != null && !value.isBlank())
                        .toList();
                if (stableRootIds.isEmpty()) {
                    return List.of();
                }
                positions = condominoRepository.findByCondominoRootIdIn(stableRootIds);
            }
        }
        return toResources(positions);
    }

    /** Update flat dell'aggregate, con enforcement tenant e separazione root/posizione. */
    public CondominoResource updateCondomino(String id, CondominoResource updatedResource, String requesterKeycloakUserId)
            throws ApiException {
        CondominoAggregate aggregate = loadAggregate(id);
        ensureExerciseOpen(aggregate.position().getIdCondominio());

        boolean isAdminOwner = tenantAccessService.ownsCondominio(
                requesterKeycloakUserId,
                aggregate.position().getIdCondominio());
        boolean isSelf = requesterKeycloakUserId.equals(aggregate.root().getKeycloakUserId());
        if (!isAdminOwner && !isSelf) {
            throw new ForbiddenException();
        }

        if (!isAdminOwner) {
            applyNonAdminUpdateGuards(updatedResource, aggregate);
        } else {
            validateAllowedCondominoRole(updatedResource.getAppRole());
        }
        validateBaseFields(updatedResource);
        normalizeStableFields(updatedResource);

        Condominio exercise = condominioRepository.findById(aggregate.position().getIdCondominio())
                .orElseThrow(() -> new NotFoundException("condominio"));
        StableRootWriteResult rootWrite = syncStableRoot(
                aggregate.root(),
                exercise.getCondominioRootId(),
                updatedResource);
        CondominoRoot updatedRoot = rootWrite.root();

        Condomino updatedPosition = buildPositionForUpdate(aggregate.position(), updatedResource);
        applySnapshotFields(updatedPosition, updatedRoot);
        reconcileFinancialFieldsOnUpdate(aggregate.position(), updatedPosition);
        ensureUniquePositionOnExercise(updatedPosition.getIdCondominio(), updatedRoot.getId(), updatedPosition.getId());

        Condomino saved = condominoRepository.save(updatedPosition);
        if (rootWrite.syncOtherPositions()) {
            syncPositionSnapshots(updatedRoot, saved.getId());
        }
        return toResource(saved, updatedRoot);
    }

    /** Delete della sola posizione esercizio; la root viene rimossa solo se orfana. */
    public void deleteCondomino(String id, String adminKeycloakUserId) throws ApiException {
        CondominoAggregate aggregate = loadAggregate(id);
        esercizioGuardService.requireOwnedOpenExercise(aggregate.position().getIdCondominio(), adminKeycloakUserId);
        condominoRepository.deleteById(id);
        if (!condominoRepository.existsByCondominoRootId(aggregate.root().getId())) {
            condominoRootRepository.deleteById(aggregate.root().getId());
        }
    }

    /** Patch merge flat: applica patch al resource API e poi riallinea root + posizione. */
    public CondominoResource patch(String id, JsonNode mergePatch, String requesterKeycloakUserId)
            throws IOException, ValidationFailedException, ApiException {
        CondominoAggregate aggregate = loadAggregate(id);
        CondominoResource current = toResource(aggregate.position(), aggregate.root());
        CondominoResource patched = JsonMergePatchHelper.applyMergePatch(mergePatch, current, CondominoResource.class);
        return updateCondomino(id, patched, requesterKeycloakUserId);
    }

    /**
     * Add versamento atomico:
     * - push sul solo array versamenti della posizione esercizio
     * - delta residui su posizione + esercizio
     */
    @Transactional
    public void addVersamento(String condominoId, Condomino.Versamento versamento, String adminKeycloakUserId)
            throws ApiException {
        Condomino existing = loadAdminOwnedPosition(condominoId, adminKeycloakUserId);
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
     * - set della sola entry array selezionata
     * - delta residui calcolato come (nuovoImporto - vecchioImporto)
     */
    @Transactional
    public void updateVersamento(
            String condominoId,
            String versamentoId,
            Condomino.Versamento payload,
            String adminKeycloakUserId) throws ApiException {
        Condomino existing = loadAdminOwnedPosition(condominoId, adminKeycloakUserId);
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
     * - pull della sola entry array selezionata
     * - delta residui negativo sull'importo rimosso
     */
    @Transactional
    public void deleteVersamento(String condominoId, String versamentoId, String adminKeycloakUserId)
            throws ApiException {
        Condomino existing = loadAdminOwnedPosition(condominoId, adminKeycloakUserId);
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

    private List<CondominoResource> toResources(List<Condomino> positions) {
        if (positions == null || positions.isEmpty()) {
            return List.of();
        }

        Map<String, CondominoRoot> rootsById = loadFallbackRootsById(positions);
        return positions.stream()
                .map(position -> toResource(position, rootsById.get(position.getCondominoRootId())))
                .sorted(Comparator
                        .comparing(CondominoResource::getCognome, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                        .thenComparing(CondominoResource::getNome, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                        .thenComparing(CondominoResource::getScala, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                        .thenComparing(CondominoResource::getInterno, Comparator.nullsLast(Long::compareTo)))
                .toList();
    }

    private CondominoResource toResource(Condomino position, CondominoRoot root) {
        CondominoResource resource = new CondominoResource();
        resource.setId(position.getId());
        resource.setVersion(position.getVersion());
        resource.setCondominoRootId(position.getCondominoRootId());
        resource.setNome(defaultString(resolveSnapshotString(position.getNome(), root == null ? null : root.getNome())));
        resource.setCognome(defaultString(resolveSnapshotString(position.getCognome(), root == null ? null : root.getCognome())));
        resource.setEmail(defaultString(resolveSnapshotString(position.getEmail(), root == null ? null : root.getEmail())));
        resource.setCellulare(defaultString(resolveSnapshotString(
                position.getCellulare(),
                root == null ? null : root.getCellulare())));
        resource.setIdCondominio(position.getIdCondominio());
        resource.setScala(defaultString(position.getScala()));
        resource.setInterno(position.getInterno());
        resource.setAnno(position.getAnno());
        resource.setKeycloakUserId(resolveSnapshotString(
                position.getKeycloakUserId(),
                root == null ? null : root.getKeycloakUserId()));
        resource.setKeycloakUsername(resolveSnapshotString(
                position.getKeycloakUsername(),
                root == null ? null : root.getKeycloakUsername()));
        resource.setAppRole(resolveSnapshotString(position.getAppRole(), root == null ? null : root.getAppRole()));
        resource.setAppEnabled(resolveSnapshotBoolean(position.getAppEnabled(), root == null ? null : root.getAppEnabled()));
        resource.setConfig(position.getConfig());
        resource.setVersamenti(position.getVersamenti());
        resource.setSaldoIniziale(position.getSaldoIniziale());
        resource.setResiduo(position.getResiduo());
        return resource;
    }

    /**
     * Il read model caldo e' `condomino`: carichiamo le root solo come fallback
     * per documenti legacy/non ancora riallineati.
     */
    private Map<String, CondominoRoot> loadFallbackRootsById(List<Condomino> positions) {
        List<String> rootIds = positions.stream()
                .filter(this::requiresStableRootFallback)
                .map(Condomino::getCondominoRootId)
                .filter(value -> value != null && !value.isBlank())
                .distinct()
                .toList();
        if (rootIds.isEmpty()) {
            return Map.of();
        }
        Map<String, CondominoRoot> result = new HashMap<>();
        for (CondominoRoot root : condominoRootRepository.findByIdIn(rootIds)) {
            result.put(root.getId(), root);
        }
        return result;
    }

    private CondominoAggregate loadAggregate(String positionId) throws NotFoundException {
        Condomino position = condominoRepository.findById(positionId)
                .orElseThrow(() -> new NotFoundException("condomino"));
        CondominoRoot root = loadStableRoot(position.getCondominoRootId());
        return new CondominoAggregate(position, root);
    }

    private CondominoRoot loadStableRoot(String condominoRootId) throws NotFoundException {
        if (condominoRootId == null || condominoRootId.isBlank()) {
            throw new NotFoundException("condominoRoot");
        }
        return condominoRootRepository.findById(condominoRootId)
                .orElseThrow(() -> new NotFoundException("condominoRoot"));
    }

    private StableRootWriteResult resolveOrCreateStableRootForCreate(Condominio exercise, CondominoResource resource)
            throws ApiException {
        if (resource.getCondominoRootId() != null && !resource.getCondominoRootId().isBlank()) {
            CondominoRoot existing = loadStableRoot(resource.getCondominoRootId());
            if (!exercise.getCondominioRootId().equals(existing.getCondominioRootId())) {
                throw new ValidationFailedException("validation.invalid.condomino.condominioRootId");
            }
            return syncStableRoot(existing, exercise.getCondominioRootId(), resource);
        }

        CondominoRoot existing = findStableRootMatch(exercise.getCondominioRootId(), resource);
        if (existing != null) {
            return syncStableRoot(existing, exercise.getCondominioRootId(), resource);
        }
        return new StableRootWriteResult(
                createStableRoot(exercise.getCondominioRootId(), resource),
                false);
    }

    private CondominoRoot findStableRootMatch(String condominioRootId, CondominoResource resource) {
        final String normalizedKeycloakUserId = normalizeBlank(resource.getKeycloakUserId());
        if (normalizedKeycloakUserId != null) {
            Optional<CondominoRoot> byKeycloak = condominoRootRepository
                    .findByCondominioRootIdAndKeycloakUserId(condominioRootId, normalizedKeycloakUserId);
            if (byKeycloak.isPresent()) {
                return byKeycloak.get();
            }
        }
        final String normalizedEmail = normalizeEmail(resource.getEmail());
        if (normalizedEmail != null) {
            return condominoRootRepository.findByCondominioRootIdAndEmail(condominioRootId, normalizedEmail)
                    .orElse(null);
        }
        return null;
    }

    private CondominoRoot createStableRoot(String condominioRootId, CondominoResource resource)
            throws ValidationFailedException {
        ensureUniqueStableIdentity(condominioRootId, resource, null);

        CondominoRoot root = new CondominoRoot();
        root.setCondominioRootId(condominioRootId);
        root.setCreatedAt(Instant.now());
        root.setUpdatedAt(Instant.now());
        copyStableFields(resource, root);
        return condominoRootRepository.save(root);
    }

    private StableRootWriteResult syncStableRoot(
            CondominoRoot existing,
            String condominioRootId,
            CondominoResource resource)
            throws ValidationFailedException {
        ensureUniqueStableIdentity(condominioRootId, resource, existing.getId());
        boolean changed = stableRootChanged(existing, condominioRootId, resource);
        if (!changed) {
            return new StableRootWriteResult(existing, false);
        }
        existing.setCondominioRootId(condominioRootId);
        existing.setUpdatedAt(Instant.now());
        copyStableFields(resource, existing);
        CondominoRoot saved = condominoRootRepository.save(existing);
        return new StableRootWriteResult(saved, changed);
    }

    private void ensureUniqueStableIdentity(
            String condominioRootId,
            CondominoResource resource,
            String excludeRootId) throws ValidationFailedException {
        final String normalizedEmail = normalizeEmail(resource.getEmail());
        if (excludeRootId == null) {
            if (normalizedEmail != null
                    && condominoRootRepository.findByCondominioRootIdAndEmail(condominioRootId, normalizedEmail)
                            .isPresent()) {
                throw new ValidationFailedException("validation.duplicate.condomino.email");
            }
        } else if (normalizedEmail != null
                && condominoRootRepository.existsByCondominioRootIdAndEmailAndIdNot(
                        condominioRootId,
                        normalizedEmail,
                        excludeRootId)) {
            throw new ValidationFailedException("validation.duplicate.condomino.email");
        }

        final String normalizedKeycloakUserId = normalizeBlank(resource.getKeycloakUserId());
        if (excludeRootId == null) {
            if (normalizedKeycloakUserId != null
                    && condominoRootRepository.findByCondominioRootIdAndKeycloakUserId(
                            condominioRootId,
                            normalizedKeycloakUserId).isPresent()) {
                throw new ValidationFailedException("validation.duplicate.condomino.keycloakUserId");
            }
        } else if (normalizedKeycloakUserId != null
                && condominoRootRepository.existsByCondominioRootIdAndKeycloakUserIdAndIdNot(
                        condominioRootId,
                        normalizedKeycloakUserId,
                        excludeRootId)) {
            throw new ValidationFailedException("validation.duplicate.condomino.keycloakUserId");
        }
    }

    private Condomino buildPositionForCreate(CondominoResource resource, Condominio exercise, CondominoRoot stableRoot) {
        Condomino position = new Condomino();
        position.setId(null);
        position.setVersion(null);
        position.setCondominoRootId(stableRoot.getId());
        position.setIdCondominio(exercise.getId());
        position.setScala(normalizeBlank(resource.getScala()));
        position.setInterno(resource.getInterno() == null ? 0L : resource.getInterno());
        position.setAnno(exercise.getAnno());
        position.setConfig(resource.getConfig());
        position.setVersamenti(resource.getVersamenti() == null ? new ArrayList<>() : resource.getVersamenti());
        position.setSaldoIniziale(resource.getSaldoIniziale());
        position.setResiduo(resource.getResiduo());
        applySnapshotFields(position, stableRoot);
        return position;
    }

    private Condomino buildPositionForUpdate(Condomino existing, CondominoResource resource) {
        Condomino position = new Condomino();
        position.setId(existing.getId());
        position.setVersion(existing.getVersion());
        position.setCondominoRootId(existing.getCondominoRootId());
        position.setIdCondominio(existing.getIdCondominio());
        position.setScala(normalizeBlank(resource.getScala()));
        position.setInterno(resource.getInterno() == null ? existing.getInterno() : resource.getInterno());
        position.setAnno(existing.getAnno());
        position.setConfig(resource.getConfig() == null ? existing.getConfig() : resource.getConfig());
        position.setVersamenti(resource.getVersamenti() == null ? existing.getVersamenti() : resource.getVersamenti());
        position.setSaldoIniziale(resource.getSaldoIniziale());
        position.setResiduo(resource.getResiduo());
        return position;
    }

    private void ensureUniquePositionOnExercise(String exerciseId, String stableRootId, String excludePositionId)
            throws ValidationFailedException {
        if (!condominoRepository.existsByIdCondominioAndCondominoRootId(exerciseId, stableRootId)) {
            return;
        }
        if (excludePositionId != null) {
            Condomino existing = condominoRepository.findById(excludePositionId).orElse(null);
            if (existing != null
                    && exerciseId.equals(existing.getIdCondominio())
                    && stableRootId.equals(existing.getCondominoRootId())) {
                return;
            }
        }
        throw new ValidationFailedException("validation.duplicate.condomino.position");
    }

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

    private void validateBaseFields(CondominoResource resource) throws ValidationFailedException {
        if (resource.getNome() == null || resource.getNome().trim().isEmpty()) {
            throw new ValidationFailedException("validation.required.condomino.nome");
        }
        if (resource.getCognome() == null || resource.getCognome().trim().isEmpty()) {
            throw new ValidationFailedException("validation.required.condomino.cognome");
        }
        if (resource.getEmail() == null || resource.getEmail().trim().isEmpty()) {
            throw new ValidationFailedException("validation.required.condomino.email");
        }
        if (resource.getIdCondominio() == null || resource.getIdCondominio().isBlank()) {
            throw new ValidationFailedException("validation.required.condomino.idCondominio");
        }
        if (resource.getSaldoIniziale() != null
                && (resource.getSaldoIniziale().isNaN() || resource.getSaldoIniziale().isInfinite())) {
            throw new ValidationFailedException("validation.invalid.condomino.saldoIniziale");
        }
    }

    private void sanitizeForCreate(CondominoResource resource) {
        resource.setId(null);
        resource.setVersion(null);
        resource.setCondominoRootId(normalizeBlank(resource.getCondominoRootId()));
    }

    private void normalizeStableFields(CondominoResource resource) {
        resource.setNome(resource.getNome() == null ? null : resource.getNome().trim());
        resource.setCognome(resource.getCognome() == null ? null : resource.getCognome().trim());
        resource.setEmail(normalizeEmail(resource.getEmail()));
        resource.setCellulare(normalizeBlank(resource.getCellulare()));
        resource.setKeycloakUserId(normalizeBlank(resource.getKeycloakUserId()));
        resource.setKeycloakUsername(normalizeBlank(resource.getKeycloakUsername()));
        if (resource.getAppRole() != null) {
            resource.setAppRole(resource.getAppRole().trim().toLowerCase());
        }
        if (resource.getAppEnabled() == null) {
            resource.setAppEnabled(Boolean.FALSE);
        }
    }

    private void copyStableFields(CondominoResource source, CondominoRoot target) {
        target.setNome(source.getNome());
        target.setCognome(source.getCognome());
        target.setEmail(source.getEmail());
        target.setCellulare(source.getCellulare());
        target.setKeycloakUserId(source.getKeycloakUserId());
        target.setKeycloakUsername(source.getKeycloakUsername());
        target.setAppRole(source.getAppRole());
        target.setAppEnabled(Boolean.TRUE.equals(source.getAppEnabled()));
    }

    /**
     * Lo snapshot sulla posizione evita merge root/position su tutte le query
     * calde. Va aggiornato ogni volta che cambia l'anagrafica stabile.
     */
    private void applySnapshotFields(Condomino target, CondominoRoot stableRoot) {
        target.setNome(stableRoot.getNome());
        target.setCognome(stableRoot.getCognome());
        target.setEmail(stableRoot.getEmail());
        target.setCellulare(stableRoot.getCellulare());
        target.setKeycloakUserId(stableRoot.getKeycloakUserId());
        target.setKeycloakUsername(stableRoot.getKeycloakUsername());
        target.setAppRole(stableRoot.getAppRole());
        target.setAppEnabled(Boolean.TRUE.equals(stableRoot.getAppEnabled()));
        target.setSnapshotUpdatedAt(stableRoot.getUpdatedAt() == null ? Instant.now() : stableRoot.getUpdatedAt());
    }

    /**
     * Propaga lo snapshot stabile alle altre posizioni collegate.
     *
     * La posizione corrente viene esclusa esplicitamente dopo il suo `save` per
     * evitare conflitti di versione ottimistica sul documento appena aggiornato.
     */
    private void syncPositionSnapshots(CondominoRoot stableRoot, String excludePositionId) {
        if (stableRoot.getId() == null || stableRoot.getId().isBlank()) {
            return;
        }
        Criteria criteria = Criteria.where("condominoRootId").is(stableRoot.getId());
        if (excludePositionId != null && !excludePositionId.isBlank()) {
            criteria = criteria.and("_id").ne(excludePositionId);
        }
        Query query = Query.query(criteria);
        Update update = new Update()
                .set("nome", stableRoot.getNome())
                .set("cognome", stableRoot.getCognome())
                .set("email", stableRoot.getEmail())
                .set("cellulare", stableRoot.getCellulare())
                .set("keycloakUserId", stableRoot.getKeycloakUserId())
                .set("keycloakUsername", stableRoot.getKeycloakUsername())
                .set("appRole", stableRoot.getAppRole())
                .set("appEnabled", Boolean.TRUE.equals(stableRoot.getAppEnabled()))
                .set("snapshotUpdatedAt", stableRoot.getUpdatedAt() == null ? Instant.now() : stableRoot.getUpdatedAt());
        mongoTemplate.updateMulti(query, update, Condomino.class);
    }

    private boolean stableRootChanged(
            CondominoRoot existing,
            String condominioRootId,
            CondominoResource resource) {
        return !defaultString(existing.getCondominioRootId()).equals(defaultString(condominioRootId))
                || !defaultString(existing.getNome()).equals(defaultString(resource.getNome()))
                || !defaultString(existing.getCognome()).equals(defaultString(resource.getCognome()))
                || !defaultString(existing.getEmail()).equals(defaultString(resource.getEmail()))
                || !defaultString(existing.getCellulare()).equals(defaultString(resource.getCellulare()))
                || !defaultString(existing.getKeycloakUserId()).equals(defaultString(resource.getKeycloakUserId()))
                || !defaultString(existing.getKeycloakUsername()).equals(defaultString(resource.getKeycloakUsername()))
                || !defaultString(existing.getAppRole()).equals(defaultString(resource.getAppRole()))
                || Boolean.TRUE.equals(existing.getAppEnabled()) != Boolean.TRUE.equals(resource.getAppEnabled());
    }

    private void applyNonAdminUpdateGuards(CondominoResource target, CondominoAggregate aggregate) {
        // Self-service: l'utente puo' correggere solo i propri dati anagrafici stabili.
        target.setCondominoRootId(aggregate.root().getId());
        target.setIdCondominio(aggregate.position().getIdCondominio());
        target.setScala(aggregate.position().getScala());
        target.setInterno(aggregate.position().getInterno());
        target.setAnno(aggregate.position().getAnno());
        target.setConfig(aggregate.position().getConfig());
        target.setVersamenti(aggregate.position().getVersamenti());
        target.setSaldoIniziale(aggregate.position().getSaldoIniziale());
        target.setResiduo(aggregate.position().getResiduo());
        target.setAppRole(aggregate.root().getAppRole());
        target.setAppEnabled(aggregate.root().getAppEnabled());
        target.setKeycloakUserId(aggregate.root().getKeycloakUserId());
        target.setKeycloakUsername(aggregate.root().getKeycloakUsername());
    }

    private void normalizeFinancialFieldsForCreate(Condomino position) {
        final double saldoIniziale = position.getSaldoIniziale() == null ? 0d : position.getSaldoIniziale();
        position.setSaldoIniziale(saldoIniziale);
        position.setResiduo(saldoIniziale);
        if (position.getVersamenti() == null) {
            position.setVersamenti(new ArrayList<>());
        }
    }

    private void reconcileFinancialFieldsOnUpdate(Condomino existing, Condomino target) {
        final double oldSaldo = existing.getSaldoIniziale() == null ? 0d : existing.getSaldoIniziale();
        final double newSaldo = target.getSaldoIniziale() == null ? oldSaldo : target.getSaldoIniziale();
        target.setSaldoIniziale(newSaldo);

        final double currentResiduo = existing.getResiduo() == null ? 0d : existing.getResiduo();
        final double deltaSaldo = newSaldo - oldSaldo;
        target.setResiduo(currentResiduo + deltaSaldo);

        if (target.getVersamenti() == null) {
            target.setVersamenti(existing.getVersamenti());
        }
    }

    private Condomino loadAdminOwnedPosition(String condominoId, String adminKeycloakUserId) throws ApiException {
        Condomino existing = condominoRepository.findById(condominoId)
                .orElseThrow(() -> new NotFoundException("condomino"));
        esercizioGuardService.requireOwnedOpenExercise(existing.getIdCondominio(), adminKeycloakUserId);
        return existing;
    }

    private void ensureExerciseOpen(String exerciseId) throws ApiException {
        Condominio exercise = condominioRepository.findById(exerciseId)
                .orElseThrow(() -> new NotFoundException("condominio"));
        esercizioGuardService.ensureOpen(exercise);
    }

    private Condomino.Versamento normalizeNewVersamento(Condomino.Versamento payload) {
        Condomino.Versamento versamento = payload == null ? new Condomino.Versamento() : payload;
        if (versamento.getId() == null || versamento.getId().isBlank()) {
            versamento.setId(UUID.randomUUID().toString());
        }
        if (versamento.getDate() == null) {
            versamento.setDate(Instant.now());
        }
        if (versamento.getInsertedAt() == null) {
            versamento.setInsertedAt(Instant.now());
        }
        if (versamento.getRipartizioneTabelle() == null) {
            versamento.setRipartizioneTabelle(new ArrayList<>());
        }
        return versamento;
    }

    private Condomino.Versamento normalizeUpdatedVersamento(
            Condomino.Versamento old,
            Condomino.Versamento payload,
            String versamentoId) {
        Condomino.Versamento versamento = payload == null ? new Condomino.Versamento() : payload;
        versamento.setId(versamentoId);
        if (versamento.getDate() == null) {
            versamento.setDate(old.getDate());
        }
        if (versamento.getInsertedAt() == null) {
            versamento.setInsertedAt(old.getInsertedAt());
        }
        if (versamento.getRipartizioneTabelle() == null) {
            versamento.setRipartizioneTabelle(old.getRipartizioneTabelle());
        }
        return versamento;
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

    private String normalizeEmail(String value) {
        if (value == null) {
            return null;
        }
        final String trimmed = value.trim().toLowerCase();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String normalizeBlank(String value) {
        if (value == null) {
            return null;
        }
        final String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String defaultString(String value) {
        return value == null ? "" : value;
    }

    private String resolveSnapshotString(String snapshotValue, String stableValue) {
        return snapshotValue != null ? snapshotValue : stableValue;
    }

    private Boolean resolveSnapshotBoolean(Boolean snapshotValue, Boolean stableValue) {
        if (snapshotValue != null) {
            return snapshotValue;
        }
        if (stableValue != null) {
            return stableValue;
        }
        return Boolean.FALSE;
    }

    private boolean requiresStableRootFallback(Condomino position) {
        return position.getNome() == null
                || position.getCognome() == null
                || position.getEmail() == null
                || position.getSnapshotUpdatedAt() == null
                || position.getAppEnabled() == null
                || (Boolean.TRUE.equals(position.getAppEnabled())
                        && (position.getAppRole() == null || position.getKeycloakUserId() == null));
    }

    private double round2(double value) {
        return Math.round(value * 100d) / 100d;
    }

    private record CondominoAggregate(Condomino position, CondominoRoot root) {
    }

    private record StableRootWriteResult(CondominoRoot root, boolean syncOtherPositions) {
    }

}
