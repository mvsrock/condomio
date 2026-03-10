package it.condomio.service;

import java.io.IOException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Collections;
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

import it.condomio.controller.model.CondominoCessazioneRequest;
import it.condomio.controller.model.CondominoResource;
import it.condomio.controller.model.CondominoSubentroRequest;
import it.condomio.controller.model.EstrattoContoResource;
import it.condomio.controller.model.RatePlanRequest;
import it.condomio.document.Condominio;
import it.condomio.document.Condomino;
import it.condomio.document.CondominoRoot;
import it.condomio.document.UnitaImmobiliare;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominoRepository;
import it.condomio.repository.CondominoRootRepository;
import it.condomio.repository.UnitaImmobiliareRepository;
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

    @Autowired
    private UnitaImmobiliareRepository unitaImmobiliareRepository;

    /** Crea una nuova posizione esercizio, riusando o creando l'anagrafica stabile. */
    public CondominoResource createCondomino(CondominoResource resource, String adminKeycloakUserId)
            throws ApiException {
        sanitizeForCreate(resource);
        validateAllowedCondominoRole(resource.getAppRole());
        validateBaseFields(resource, true);

        Condominio exercise = esercizioGuardService.requireOwnedOpenExercise(
                resource.getIdCondominio(),
                adminKeycloakUserId);
        normalizeStableFields(resource);

        StableRootWriteResult rootWrite = resolveOrCreateStableRootForCreate(exercise, resource);
        CondominoRoot stableRoot = rootWrite.root();
        ensureUniquePositionOnExercise(exercise.getId(), stableRoot.getId(), null);
        UnitaImmobiliare unita = resolveOrCreateUnitaForPosition(exercise, resource, false);

        Condomino position = buildPositionForCreate(resource, exercise, stableRoot, unita);
        validateUnitaTitolaritaOverlap(position, null);
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
        validateBaseFields(updatedResource, false);
        normalizeStableFields(updatedResource);

        Condominio exercise = condominioRepository.findById(aggregate.position().getIdCondominio())
                .orElseThrow(() -> new NotFoundException("condominio"));
        StableRootWriteResult rootWrite = syncStableRoot(
                aggregate.root(),
                exercise.getCondominioRootId(),
                updatedResource);
        CondominoRoot updatedRoot = rootWrite.root();
        UnitaImmobiliare unita = resolveOrCreateUnitaForPosition(exercise, updatedResource, true);

        Condomino updatedPosition = buildPositionForUpdate(aggregate.position(), updatedResource, unita);
        applySnapshotFields(updatedPosition, updatedRoot);
        reconcileFinancialFieldsOnUpdate(aggregate.position(), updatedPosition);
        ensureUniquePositionOnExercise(updatedPosition.getIdCondominio(), updatedRoot.getId(), updatedPosition.getId());
        validateUnitaTitolaritaOverlap(updatedPosition, updatedPosition.getId());

        Condomino saved = condominoRepository.save(updatedPosition);
        if (rootWrite.syncOtherPositions()) {
            syncPositionSnapshots(updatedRoot, saved.getId());
        }
        return toResource(saved, updatedRoot);
    }

    /** Delete della sola posizione esercizio; la root viene rimossa solo se orfana. */
    @Transactional
    public void deleteCondomino(String id, String adminKeycloakUserId) throws ApiException {
        CondominoAggregate aggregate = loadAggregate(id);
        esercizioGuardService.requireOwnedOpenExercise(aggregate.position().getIdCondominio(), adminKeycloakUserId);
        ensureHardDeleteAllowed(aggregate.position());
        condominoRepository.deleteById(id);
        if (!condominoRepository.existsByCondominoRootId(aggregate.root().getId())) {
            condominoRootRepository.deleteById(aggregate.root().getId());
        }
    }

    /**
     * Cessazione funzionale della posizione.
     *
     * Serve quando il soggetto non fa piu' parte dell'esercizio ma lo storico
     * contabile deve restare leggibile e ricostruibile.
     */
    @Transactional
    public CondominoResource ceaseCondomino(
            String id,
            CondominoCessazioneRequest request,
            String adminKeycloakUserId) throws ApiException {
        CondominoAggregate aggregate = loadAggregate(id);
        Condominio exercise = esercizioGuardService.requireOwnedOpenExercise(
                aggregate.position().getIdCondominio(),
                adminKeycloakUserId);
        ensurePositionActive(aggregate.position());

        final Instant cessazioneAt = resolveExitInstant(request == null ? null : request.getDataCessazione(), exercise);
        validateExitInstant(aggregate.position(), exercise, cessazioneAt);

        Condomino updatedPosition = aggregate.position();
        updatedPosition.setStatoPosizione(Condomino.PosizioneStato.CESSATO);
        updatedPosition.setDataUscita(cessazioneAt);
        updatedPosition.setMotivoUscita(normalizeBlank(request == null ? null : request.getMotivo()));
        Condomino saved = condominoRepository.save(updatedPosition);
        return toResource(saved, aggregate.root());
    }

    /**
     * Subentro sullo stesso esercizio:
     * - chiude il precedente condomino alla data effettiva
     * - crea una nuova posizione, di norma sulla stessa unita'
     * - eredita le quote del predecessore ma non i versamenti
     */
    @Transactional
    public CondominoResource subentraCondomino(
            String previousPositionId,
            CondominoSubentroRequest request,
            String adminKeycloakUserId) throws ApiException {
        if (request == null || request.getNuovoCondomino() == null) {
            throw new ValidationFailedException("validation.required.condomino.subentro.nuovoCondomino");
        }

        CondominoAggregate aggregate = loadAggregate(previousPositionId);
        Condominio exercise = esercizioGuardService.requireOwnedOpenExercise(
                aggregate.position().getIdCondominio(),
                adminKeycloakUserId);
        ensurePositionActive(aggregate.position());

        final Instant subentroAt = resolveEntryInstant(request.getDataSubentro(), exercise);
        // Retrocompatibilita':
        // alcuni record legacy possono avere dataIngresso valorizzata con l'istante
        // tecnico di creazione API. In quel caso un subentro "nello stesso giorno"
        // puo' risultare artificialmente precedente all'ingresso.
        // Clamppiamo alla data ingresso reale della posizione per evitare falsi 400.
        final Instant normalizedSubentroAt = normalizeSubentroInstant(aggregate.position(), subentroAt);
        validateExitInstant(aggregate.position(), exercise, normalizedSubentroAt);

        CondominoResource incoming = request.getNuovoCondomino();
        sanitizeForCreate(incoming);
        incoming.setIdCondominio(exercise.getId());
        // Subentro guidato: il nuovo soggetto eredita sempre la stessa unita' del precedente.
        // Non consentiamo subentro "traslato" su altra unita' nello stesso comando.
        incoming.setUnitaImmobiliareId(aggregate.position().getUnitaImmobiliareId());
        incoming.setScala(aggregate.position().getScala());
        incoming.setInterno(aggregate.position().getInterno());
        incoming.setConfig(incoming.getConfig() == null
                ? cloneCondominoConfig(aggregate.position().getConfig())
                : incoming.getConfig());
        incoming.setVersamenti(new ArrayList<>());
        incoming.setDataIngresso(normalizedSubentroAt);
        incoming.setDataUscita(null);
        incoming.setMotivoUscita(null);
        incoming.setPrecedenteCondominoId(previousPositionId);
        incoming.setSuccessivoCondominoId(null);
        incoming.setStatoPosizione(Condomino.PosizioneStato.ATTIVO);

        final boolean carryOverSaldo = Boolean.TRUE.equals(request.getCarryOverSaldo());
        final double incomingSaldo = carryOverSaldo ? safeAmount(aggregate.position().getResiduo()) : safeAmount(incoming.getSaldoIniziale());
        incoming.setSaldoIniziale(incomingSaldo);
        incoming.setResiduo(incomingSaldo);

        validateAllowedCondominoRole(incoming.getAppRole());
        validateBaseFields(incoming, true);
        normalizeStableFields(incoming);

        StableRootWriteResult rootWrite = resolveOrCreateStableRootForCreate(exercise, incoming);
        CondominoRoot stableRoot = rootWrite.root();
        ensureUniquePositionOnExercise(exercise.getId(), stableRoot.getId(), null);
        UnitaImmobiliare unita = resolveOrCreateUnitaForPosition(exercise, incoming, false);

        Condomino previousPosition = aggregate.position();
        previousPosition.setStatoPosizione(Condomino.PosizioneStato.CESSATO);
        previousPosition.setDataUscita(normalizedSubentroAt.minusMillis(1));
        previousPosition.setMotivoUscita("subentro");

        Condomino createdPosition = buildPositionForCreate(incoming, exercise, stableRoot, unita);
        validateUnitaTitolaritaOverlap(createdPosition, null);
        normalizeFinancialFieldsForCreate(createdPosition);
        Condomino savedIncoming = condominoRepository.save(createdPosition);

        previousPosition.setSuccessivoCondominoId(savedIncoming.getId());
        condominoRepository.save(previousPosition);

        if (rootWrite.syncOtherPositions()) {
            syncPositionSnapshots(stableRoot, savedIncoming.getId());
        }
        return toResource(savedIncoming, stableRoot);
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
        validateVersamentoRata(existing, normalized);

        long changed = condominoRepository.addVersamentoByIdAndCondominio(
                existing.getId(),
                existing.getIdCondominio(),
                normalized);
        if (changed == 0) {
            throw new NotFoundException("condomino");
        }
        applyVersamentoResiduoDelta(existing.getId(), existing.getIdCondominio(), normalized.getImporto());
        recalcAndPersistRateProgress(existing.getId(), existing.getIdCondominio());
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
        validateVersamentoRata(existing, updated);

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
        recalcAndPersistRateProgress(existing.getId(), existing.getIdCondominio());
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
        recalcAndPersistRateProgress(existing.getId(), existing.getIdCondominio());
    }

    /** Add rata su posizione esercizio (solo admin owner). */
    @Transactional
    public void addRata(String condominoId, Condomino.Config.Rata rata, String adminKeycloakUserId) throws ApiException {
        Condomino existing = loadAdminOwnedPosition(condominoId, adminKeycloakUserId);
        Condomino.Config.Rata normalized = normalizeNewRata(rata);
        validateRata(normalized);
        ensureConfig(existing);
        List<Condomino.Config.Rata> current = existing.getConfig().getRate() == null
                ? new ArrayList<>()
                : new ArrayList<>(existing.getConfig().getRate());
        current.add(normalized);
        existing.getConfig().setRate(current);
        List<Condomino.Config.Rata> recalculated = recalculateRateProgress(existing);
        updateRateList(existing.getId(), existing.getIdCondominio(), recalculated);
    }

    /** Update rata esistente con riallineamento stato/incassato. */
    @Transactional
    public void updateRata(
            String condominoId,
            String rataId,
            Condomino.Config.Rata rata,
            String adminKeycloakUserId) throws ApiException {
        Condomino existing = loadAdminOwnedPosition(condominoId, adminKeycloakUserId);
        ensureConfig(existing);
        List<Condomino.Config.Rata> current = existing.getConfig().getRate();
        if (current == null || current.isEmpty()) {
            throw new NotFoundException("rata");
        }
        boolean found = false;
        List<Condomino.Config.Rata> replaced = new ArrayList<>();
        for (Condomino.Config.Rata item : current) {
            if (item == null || item.getId() == null || !rataId.equals(item.getId())) {
                replaced.add(item);
                continue;
            }
            Condomino.Config.Rata normalized = normalizeUpdatedRata(item, rata, rataId);
            validateRata(normalized);
            replaced.add(normalized);
            found = true;
        }
        if (!found) {
            throw new NotFoundException("rata");
        }
        existing.getConfig().setRate(replaced);
        List<Condomino.Config.Rata> recalculated = recalculateRateProgress(existing);
        updateRateList(existing.getId(), existing.getIdCondominio(), recalculated);
    }

    /** Delete rata esistente con riallineamento stato/incassato delle rimanenti. */
    @Transactional
    public void deleteRata(String condominoId, String rataId, String adminKeycloakUserId) throws ApiException {
        Condomino existing = loadAdminOwnedPosition(condominoId, adminKeycloakUserId);
        ensureConfig(existing);
        List<Condomino.Config.Rata> current = existing.getConfig().getRate();
        if (current == null || current.isEmpty()) {
            throw new NotFoundException("rata");
        }
        List<Condomino.Config.Rata> filtered = new ArrayList<>();
        boolean removed = false;
        for (Condomino.Config.Rata item : current) {
            if (item != null && item.getId() != null && rataId.equals(item.getId())) {
                removed = true;
                continue;
            }
            filtered.add(item);
        }
        if (!removed) {
            throw new NotFoundException("rata");
        }
        existing.getConfig().setRate(filtered);
        List<Condomino.Config.Rata> recalculated = recalculateRateProgress(existing);
        updateRateList(existing.getId(), existing.getIdCondominio(), recalculated);
    }

    /**
     * Piano rate esercizio:
     * genera rate per tutte le posizioni attive dell'esercizio.
     * Strategia: ripartizione uguale dell'importo totale per template.
     */
    @Transactional
    public void applyRatePlanToExercise(
            String idCondominio,
            RatePlanRequest request,
            String adminKeycloakUserId) throws ApiException {
        esercizioGuardService.requireOwnedOpenExercise(idCondominio, adminKeycloakUserId);
        if (request == null || request.getRate() == null || request.getRate().isEmpty()) {
            throw new ValidationFailedException("validation.required.ratePlan.rate");
        }
        List<Condomino> positions = condominoRepository.findByIdCondominio(idCondominio)
                .stream()
                .filter(position -> isActiveState(resolvePositionState(position)))
                .toList();
        if (positions.isEmpty()) {
            throw new ValidationFailedException("validation.required.ratePlan.activePositions");
        }

        final int size = positions.size();
        for (RatePlanRequest.Template template : request.getRate()) {
            validateRateTemplate(template);
            double total = template.getImportoTotale() == null ? 0d : template.getImportoTotale();
            final double base = round2(total / size);
            double allocated = 0d;
            for (int i = 0; i < size; i++) {
                Condomino position = positions.get(i);
                ensureConfig(position);
                List<Condomino.Config.Rata> rate = position.getConfig().getRate() == null
                        ? new ArrayList<>()
                        : new ArrayList<>(position.getConfig().getRate());
                final double amount = i == size - 1 ? round2(total - allocated) : base;
                allocated += (i == size - 1 ? 0d : amount);

                Condomino.Config.Rata rata = new Condomino.Config.Rata();
                rata.setId(UUID.randomUUID().toString());
                rata.setCodice(template.getCodice().trim());
                rata.setDescrizione(normalizeBlank(template.getDescrizione()));
                rata.setTipo(template.getTipo() == null
                        ? Condomino.Config.Rata.Tipo.ORDINARIA
                        : template.getTipo().toRateTipo());
                rata.setScadenza(template.getScadenza());
                rata.setImporto(round2(amount));
                rata.setIncassato(0d);
                rata.setStato(resolveRataStato(0d, amount, template.getScadenza()));
                rata.setImporti(Collections.emptyList());
                rate.add(rata);
                position.getConfig().setRate(rate);
            }
        }

        for (Condomino position : positions) {
            List<Condomino.Config.Rata> recalculated = recalculateRateProgress(position);
            updateRateList(position.getId(), idCondominio, recalculated);
        }
    }

    /** Estratto conto posizione con focus sul ciclo rate/incassi. */
    public EstrattoContoResource getEstrattoConto(String condominoId, String requesterKeycloakUserId) throws ApiException {
        Optional<CondominoResource> visible = getCondominoById(condominoId, requesterKeycloakUserId);
        if (visible.isEmpty()) {
            throw new NotFoundException("condomino");
        }
        Condomino position = condominoRepository.findById(condominoId)
                .orElseThrow(() -> new NotFoundException("condomino"));
        List<Condomino.Config.Rata> rates = recalculateRateProgress(position);
        double totaleRate = 0d;
        double totaleIncassatoRate = 0d;
        List<EstrattoContoResource.RataDettaglio> dettagli = new ArrayList<>();
        for (Condomino.Config.Rata rata : rates) {
            if (rata == null) {
                continue;
            }
            final double due = round2(rata.getImporto() == null ? 0d : rata.getImporto());
            final double paid = round2(rata.getIncassato() == null ? 0d : rata.getIncassato());
            totaleRate += due;
            totaleIncassatoRate += paid;
            EstrattoContoResource.RataDettaglio row = new EstrattoContoResource.RataDettaglio();
            row.setId(rata.getId());
            row.setCodice(rata.getCodice());
            row.setDescrizione(rata.getDescrizione());
            row.setTipo(rata.getTipo() == null ? "" : rata.getTipo().name());
            row.setStato(rata.getStato() == null ? "" : rata.getStato().name());
            row.setScadenza(rata.getScadenza() == null ? null : rata.getScadenza().toString());
            row.setImporto(due);
            row.setIncassato(paid);
            row.setScoperto(round2(Math.max(0d, due - paid)));
            dettagli.add(row);
        }
        final double totalVersamenti = sumVersamenti(position.getVersamenti());
        EstrattoContoResource response = new EstrattoContoResource();
        response.setCondominoId(position.getId());
        response.setIdCondominio(position.getIdCondominio());
        response.setTotaleRate(round2(totaleRate));
        response.setTotaleIncassatoRate(round2(totaleIncassatoRate));
        response.setScopertoRate(round2(Math.max(0d, totaleRate - totaleIncassatoRate)));
        response.setTotaleVersamenti(round2(totalVersamenti));
        response.setRate(dettagli);
        return response;
    }

    private List<CondominoResource> toResources(List<Condomino> positions) {
        if (positions == null || positions.isEmpty()) {
            return List.of();
        }

        Map<String, CondominoRoot> rootsById = loadFallbackRootsById(positions);
        return positions.stream()
                .map(position -> toResource(position, rootsById.get(position.getCondominoRootId())))
                .sorted(Comparator
                        .comparing((CondominoResource resource) -> !isActiveState(resource.getStatoPosizione()))
                        .thenComparing(CondominoResource::getCognome, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                        .thenComparing(CondominoResource::getNome, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                        .thenComparing(CondominoResource::getScala, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                        .thenComparing(CondominoResource::getInterno, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER)))
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
        resource.setStatoPosizione(resolvePositionState(position));
        resource.setDataIngresso(position.getDataIngresso());
        resource.setDataUscita(position.getDataUscita());
        resource.setMotivoUscita(position.getMotivoUscita());
        resource.setPrecedenteCondominoId(position.getPrecedenteCondominoId());
        resource.setSuccessivoCondominoId(position.getSuccessivoCondominoId());
        resource.setUnitaImmobiliareId(position.getUnitaImmobiliareId());
        resource.setTitolaritaTipo(position.getTitolaritaTipo());
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
        resource.setMorositaStato(position.getMorositaStato());
        resource.setSolleciti(position.getSolleciti());
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

    private Condomino buildPositionForCreate(
            CondominoResource resource,
            Condominio exercise,
            CondominoRoot stableRoot,
            UnitaImmobiliare unita) {
        Condomino position = new Condomino();
        position.setId(null);
        position.setVersion(null);
        position.setCondominoRootId(stableRoot.getId());
        position.setIdCondominio(exercise.getId());
        position.setUnitaImmobiliareId(unita == null ? null : unita.getId());
        position.setTitolaritaTipo(resolveTitolaritaTipo(resource));
        position.setScala(unita == null ? normalizeBlank(resource.getScala()) : unita.getScala());
        position.setInterno(unita == null
                ? normalizeBlank(resource.getInterno())
                : normalizeBlank(unita.getInterno()));
        position.setAnno(exercise.getAnno());
        position.setStatoPosizione(resolveCreateState(resource));
        position.setDataIngresso(resolveEntryInstant(resource.getDataIngresso(), exercise));
        position.setDataUscita(normalizeExitInstant(resource.getDataUscita()));
        position.setMotivoUscita(normalizeBlank(resource.getMotivoUscita()));
        position.setPrecedenteCondominoId(normalizeBlank(resource.getPrecedenteCondominoId()));
        position.setSuccessivoCondominoId(normalizeBlank(resource.getSuccessivoCondominoId()));
        position.setConfig(resource.getConfig());
        position.setVersamenti(resource.getVersamenti() == null ? new ArrayList<>() : resource.getVersamenti());
        position.setSaldoIniziale(resource.getSaldoIniziale());
        position.setResiduo(resource.getResiduo());
        position.setMorositaStato(resource.getMorositaStato());
        position.setSolleciti(resource.getSolleciti() == null ? new ArrayList<>() : resource.getSolleciti());
        applySnapshotFields(position, stableRoot);
        return position;
    }

    private Condomino buildPositionForUpdate(
            Condomino existing,
            CondominoResource resource,
            UnitaImmobiliare unita) {
        final boolean clearUnitBinding = isUnitBindingExplicitlyCleared(resource);
        Condomino position = new Condomino();
        position.setId(existing.getId());
        position.setVersion(existing.getVersion());
        position.setCondominoRootId(existing.getCondominoRootId());
        position.setIdCondominio(existing.getIdCondominio());
        position.setUnitaImmobiliareId(unita == null
                ? (clearUnitBinding ? null : existing.getUnitaImmobiliareId())
                : unita.getId());
        position.setTitolaritaTipo(resource.getTitolaritaTipo() == null
                ? (existing.getTitolaritaTipo() == null
                        ? Condomino.TitolaritaTipo.PROPRIETARIO
                        : existing.getTitolaritaTipo())
                : resource.getTitolaritaTipo());
        position.setScala(unita == null ? normalizeBlank(resource.getScala()) : unita.getScala());
        position.setInterno(unita == null
                ? (resource.getInterno() == null ? existing.getInterno() : resource.getInterno())
                : normalizeBlank(unita.getInterno()));
        position.setAnno(existing.getAnno());
        position.setStatoPosizione(resolveUpdateState(existing, resource));
        position.setDataIngresso(resolveUpdateEntryInstant(existing, resource));
        position.setDataUscita(resolveUpdateExitInstant(existing, resource));
        position.setMotivoUscita(normalizeBlank(
                resource.getMotivoUscita() == null ? existing.getMotivoUscita() : resource.getMotivoUscita()));
        position.setPrecedenteCondominoId(normalizeBlank(
                resource.getPrecedenteCondominoId() == null
                        ? existing.getPrecedenteCondominoId()
                        : resource.getPrecedenteCondominoId()));
        position.setSuccessivoCondominoId(normalizeBlank(
                resource.getSuccessivoCondominoId() == null
                        ? existing.getSuccessivoCondominoId()
                        : resource.getSuccessivoCondominoId()));
        position.setConfig(resource.getConfig() == null ? existing.getConfig() : resource.getConfig());
        position.setVersamenti(resource.getVersamenti() == null ? existing.getVersamenti() : resource.getVersamenti());
        position.setSaldoIniziale(resource.getSaldoIniziale());
        position.setResiduo(resource.getResiduo());
        position.setMorositaStato(resource.getMorositaStato() == null
                ? existing.getMorositaStato()
                : resource.getMorositaStato());
        position.setSolleciti(resource.getSolleciti() == null ? existing.getSolleciti() : resource.getSolleciti());
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

    private UnitaImmobiliare resolveOrCreateUnitaForPosition(
            Condominio exercise,
            CondominoResource resource,
            boolean allowMissing) throws ValidationFailedException, NotFoundException {
        if (exercise == null || exercise.getCondominioRootId() == null || exercise.getCondominioRootId().isBlank()) {
            throw new ValidationFailedException("validation.required.condomino.condominioRootId");
        }
        final String condominioRootId = exercise.getCondominioRootId();
        final String explicitUnitaId = normalizeBlank(resource.getUnitaImmobiliareId());
        if (explicitUnitaId != null) {
            return unitaImmobiliareRepository.findByIdAndCondominioRootId(explicitUnitaId, condominioRootId)
                    .orElseThrow(() -> new NotFoundException("unitaImmobiliare"));
        }

        final String scala = normalizeBlank(resource.getScala());
        final String interno = normalizeBlank(resource.getInterno());
        if (allowMissing && scala == null && interno == null) {
            return null;
        }
        if (scala == null || interno == null || interno.isBlank()) {
            throw new ValidationFailedException("validation.required.condomino.unitaImmobiliare");
        }
        return unitaImmobiliareRepository
                .findByCondominioRootIdAndScalaAndInterno(condominioRootId, scala, interno)
                .orElseGet(() -> {
                    UnitaImmobiliare created = new UnitaImmobiliare();
                    created.setCondominioRootId(condominioRootId);
                    created.setScala(scala);
                    created.setInterno(interno);
                    created.setCodice(scala + "-" + interno);
                    created.setCreatedAt(Instant.now());
                    created.setUpdatedAt(Instant.now());
                    return unitaImmobiliareRepository.save(created);
                });
    }

    private void validateUnitaTitolaritaOverlap(Condomino candidate, String excludePositionId)
            throws ValidationFailedException {
        final String unitId = normalizeBlank(candidate.getUnitaImmobiliareId());
        if (unitId == null) {
            return;
        }
        final List<Condomino> positions = condominoRepository.findByIdCondominio(candidate.getIdCondominio());
        final Instant candidateStart = candidate.getDataIngresso() == null ? Instant.EPOCH : candidate.getDataIngresso();
        final Instant candidateEnd = candidate.getDataUscita() == null ? Instant.MAX : candidate.getDataUscita();
        for (Condomino existing : positions) {
            if (existing == null || existing.getUnitaImmobiliareId() == null) {
                continue;
            }
            if (!unitId.equals(existing.getUnitaImmobiliareId())) {
                continue;
            }
            if (excludePositionId != null && excludePositionId.equals(existing.getId())) {
                continue;
            }
            final Instant existingStart = existing.getDataIngresso() == null ? Instant.EPOCH : existing.getDataIngresso();
            final Instant existingEnd = existing.getDataUscita() == null ? Instant.MAX : existing.getDataUscita();
            if (candidateStart.isAfter(existingEnd) || existingStart.isAfter(candidateEnd)) {
                continue;
            }
            throw new ValidationFailedException("validation.overlap.condomino.unitaImmobiliare");
        }
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

    private void validateBaseFields(CondominoResource resource, boolean requireUnit) throws ValidationFailedException {
        if (resource.getNome() == null || resource.getNome().trim().isEmpty()) {
            throw new ValidationFailedException("validation.required.condomino.nome");
        }
        if (resource.getCognome() == null || resource.getCognome().trim().isEmpty()) {
            throw new ValidationFailedException("validation.required.condomino.cognome");
        }
        if (resource.getIdCondominio() == null || resource.getIdCondominio().isBlank()) {
            throw new ValidationFailedException("validation.required.condomino.idCondominio");
        }
        if (requireUnit
                && (resource.getUnitaImmobiliareId() == null || resource.getUnitaImmobiliareId().isBlank())
                && (resource.getScala() == null || resource.getScala().isBlank()
                        || resource.getInterno() == null || resource.getInterno().isBlank())) {
            throw new ValidationFailedException("validation.required.condomino.unitaImmobiliare");
        }
        if (resource.getSaldoIniziale() != null
                && (resource.getSaldoIniziale().isNaN() || resource.getSaldoIniziale().isInfinite())) {
            throw new ValidationFailedException("validation.invalid.condomino.saldoIniziale");
        }
        if (resource.getDataIngresso() != null
                && resource.getDataUscita() != null
                && !resource.getDataIngresso().isBefore(resource.getDataUscita())
                && !resource.getDataIngresso().equals(resource.getDataUscita())) {
            throw new ValidationFailedException("validation.invalid.condomino.periodo");
        }
    }

    private Condomino.PosizioneStato resolveCreateState(CondominoResource resource) {
        return isActiveState(resource.getStatoPosizione())
                ? Condomino.PosizioneStato.ATTIVO
                : Condomino.PosizioneStato.CESSATO;
    }

    private Condomino.TitolaritaTipo resolveTitolaritaTipo(CondominoResource resource) {
        return resource.getTitolaritaTipo() == null
                ? Condomino.TitolaritaTipo.PROPRIETARIO
                : resource.getTitolaritaTipo();
    }

    private Condomino.PosizioneStato resolveUpdateState(Condomino existing, CondominoResource resource) {
        if (resource.getStatoPosizione() != null) {
            return resource.getStatoPosizione();
        }
        return resolvePositionState(existing);
    }

    private Condomino.PosizioneStato resolvePositionState(Condomino position) {
        return position.getStatoPosizione() == null
                ? Condomino.PosizioneStato.ATTIVO
                : position.getStatoPosizione();
    }

    private boolean isActiveState(Condomino.PosizioneStato state) {
        return state == null || state == Condomino.PosizioneStato.ATTIVO;
    }

    private Instant resolveEntryInstant(Instant incoming, Condominio exercise) {
        if (incoming != null) {
            return incoming;
        }
        // Default coerente di dominio:
        // una posizione creata senza data esplicita e' valida dall'inizio esercizio,
        // non dall'istante tecnico della create API.
        if (exercise != null && exercise.getDataInizio() != null) {
            return exercise.getDataInizio();
        }
        return Instant.now();
    }

    private Instant resolveExitInstant(Instant incoming, Condominio exercise) {
        if (incoming != null) {
            return incoming;
        }
        return Instant.now();
    }

    private Instant normalizeExitInstant(Instant value) {
        return value;
    }

    private Instant normalizeSubentroInstant(Condomino previousPosition, Instant requestedSubentroAt) {
        if (requestedSubentroAt == null) {
            return Instant.now();
        }
        final Instant ingresso = previousPosition == null ? null : previousPosition.getDataIngresso();
        if (ingresso == null) {
            return requestedSubentroAt;
        }
        return requestedSubentroAt.isBefore(ingresso) ? ingresso : requestedSubentroAt;
    }

    private Instant resolveUpdateEntryInstant(Condomino existing, CondominoResource resource) {
        return resource.getDataIngresso() == null ? existing.getDataIngresso() : resource.getDataIngresso();
    }

    private Instant resolveUpdateExitInstant(Condomino existing, CondominoResource resource) {
        return resource.getDataUscita() == null ? existing.getDataUscita() : resource.getDataUscita();
    }

    private void validateExitInstant(Condomino position, Condominio exercise, Instant exitAt)
            throws ValidationFailedException {
        final Instant effectiveExit = exitAt == null ? Instant.now() : exitAt;
        final Instant ingresso = position.getDataIngresso();
        if (ingresso != null && effectiveExit.isBefore(ingresso) && !isSameUtcDay(effectiveExit, ingresso)) {
            throw new ValidationFailedException("validation.invalid.condomino.dataUscitaBeforeIngresso");
        }
        if (exercise.getDataInizio() != null && effectiveExit.isBefore(exercise.getDataInizio())) {
            throw new ValidationFailedException("validation.invalid.condomino.dataUscitaBeforeExercise");
        }
        if (exercise.getDataFine() != null && effectiveExit.isAfter(exercise.getDataFine())) {
            throw new ValidationFailedException("validation.invalid.condomino.dataUscitaAfterExercise");
        }
    }

    private void ensurePositionActive(Condomino position) throws ValidationFailedException {
        if (!isActiveState(resolvePositionState(position))) {
            throw new ValidationFailedException("validation.invalid.condomino.positionNotActive");
        }
    }

    private void ensureHardDeleteAllowed(Condomino position) throws ValidationFailedException {
        if (!isBlank(position.getPrecedenteCondominoId()) || !isBlank(position.getSuccessivoCondominoId())) {
            throw new ValidationFailedException("validation.inuse.condomino.subentro");
        }
        if (position.getVersamenti() != null && !position.getVersamenti().isEmpty()) {
            throw new ValidationFailedException("validation.inuse.condomino.versamenti");
        }
        Query linkedMovimenti = Query.query(
                Criteria.where("idCondominio").is(position.getIdCondominio())
                        .and("ripartizioneCondomini.idCondomino").is(position.getId()));
        if (mongoTemplate.exists(linkedMovimenti, "movimenti")) {
            throw new ValidationFailedException("validation.inuse.condomino.movimenti");
        }
    }

    private void sanitizeForCreate(CondominoResource resource) {
        resource.setId(null);
        resource.setVersion(null);
        resource.setCondominoRootId(normalizeBlank(resource.getCondominoRootId()));
        resource.setUnitaImmobiliareId(normalizeBlank(resource.getUnitaImmobiliareId()));
        resource.setSuccessivoCondominoId(normalizeBlank(resource.getSuccessivoCondominoId()));
        resource.setPrecedenteCondominoId(normalizeBlank(resource.getPrecedenteCondominoId()));
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
        target.setStatoPosizione(resolvePositionState(aggregate.position()));
        target.setDataIngresso(aggregate.position().getDataIngresso());
        target.setDataUscita(aggregate.position().getDataUscita());
        target.setMotivoUscita(aggregate.position().getMotivoUscita());
        target.setPrecedenteCondominoId(aggregate.position().getPrecedenteCondominoId());
        target.setSuccessivoCondominoId(aggregate.position().getSuccessivoCondominoId());
        target.setUnitaImmobiliareId(aggregate.position().getUnitaImmobiliareId());
        target.setTitolaritaTipo(aggregate.position().getTitolaritaTipo());
        target.setConfig(aggregate.position().getConfig());
        target.setVersamenti(aggregate.position().getVersamenti());
        target.setSaldoIniziale(aggregate.position().getSaldoIniziale());
        target.setResiduo(aggregate.position().getResiduo());
        target.setMorositaStato(aggregate.position().getMorositaStato());
        target.setSolleciti(aggregate.position().getSolleciti());
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
        if (position.getSolleciti() == null) {
            position.setSolleciti(new ArrayList<>());
        }
        if (position.getStatoPosizione() == null) {
            position.setStatoPosizione(Condomino.PosizioneStato.ATTIVO);
        }
        if (position.getMorositaStato() == null) {
            position.setMorositaStato(Condomino.MorositaStato.IN_BONIS);
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
        if (target.getSolleciti() == null) {
            target.setSolleciti(existing.getSolleciti());
        }
        if (target.getMorositaStato() == null) {
            target.setMorositaStato(existing.getMorositaStato());
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

    private void validateVersamentoRata(Condomino existing, Condomino.Versamento versamento)
            throws ValidationFailedException {
        if (versamento.getRataId() == null || versamento.getRataId().isBlank()) {
            return;
        }
        final List<Condomino.Config.Rata> rate = existing.getConfig() == null
                ? null
                : existing.getConfig().getRate();
        if (rate == null || rate.isEmpty()) {
            throw new ValidationFailedException("validation.notfound.versamento.rata");
        }
        final String targetId = versamento.getRataId().trim();
        for (Condomino.Config.Rata item : rate) {
            if (item != null && item.getId() != null && targetId.equals(item.getId())) {
                return;
            }
        }
        throw new ValidationFailedException("validation.notfound.versamento.rata");
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

    private void recalcAndPersistRateProgress(String condominoId, String idCondominio) {
        Condomino position = condominoRepository.findById(condominoId).orElse(null);
        if (position == null || !idCondominio.equals(position.getIdCondominio())) {
            return;
        }
        List<Condomino.Config.Rata> recalculated = recalculateRateProgress(position);
        updateRateList(condominoId, idCondominio, recalculated);
    }

    private void updateRateList(String condominoId, String idCondominio, List<Condomino.Config.Rata> rates) {
        Query query = new Query(
                Criteria.where("_id").is(condominoId)
                        .and("idCondominio").is(idCondominio));
        Update update = new Update().set("config.rate", rates);
        mongoTemplate.updateFirst(query, update, Condomino.class);
    }

    private List<Condomino.Config.Rata> recalculateRateProgress(Condomino position) {
        ensureConfig(position);
        final List<Condomino.Config.Rata> source = position.getConfig().getRate() == null
                ? new ArrayList<>()
                : new ArrayList<>(position.getConfig().getRate());
        if (source.isEmpty()) {
            return source;
        }

        // Normalizziamo prima le rate (id/importo/scadenza) per avere base consistente.
        final List<Condomino.Config.Rata> rates = new ArrayList<>();
        for (Condomino.Config.Rata rate : source) {
            Condomino.Config.Rata normalized = normalizeUpdatedRata(rate, rate, rate == null ? null : rate.getId());
            if (normalized == null) {
                continue;
            }
            rates.add(normalized);
        }
        final List<String> validRateIds = rates.stream()
                .map(Condomino.Config.Rata::getId)
                .filter(value -> value != null && !value.isBlank())
                .toList();

        final Map<String, Double> paidByRate = new HashMap<>();
        double unassignedPayments = 0d;
        if (position.getVersamenti() != null) {
            final List<Condomino.Versamento> versamenti = new ArrayList<>(position.getVersamenti());
            versamenti.sort(Comparator.comparing(v -> v.getDate() == null ? Instant.EPOCH : v.getDate()));
            for (Condomino.Versamento v : versamenti) {
                if (v == null || v.getImporto() == null || v.getImporto() <= 0d) {
                    continue;
                }
                final double amount = round2(v.getImporto());
                if (v.getRataId() != null && !v.getRataId().isBlank()) {
                    if (validRateIds.contains(v.getRataId())) {
                        paidByRate.merge(v.getRataId(), amount, Double::sum);
                    } else {
                        // Rata non più presente: rientra nell'imputazione automatica FIFO.
                        unassignedPayments += amount;
                    }
                } else {
                    unassignedPayments += amount;
                }
            }
        }

        // Imputazione automatica FIFO sul residuo rate in ordine scadenza.
        final List<Condomino.Config.Rata> ordered = new ArrayList<>(rates);
        ordered.sort(Comparator.comparing(r -> r.getScadenza() == null ? Instant.MAX : r.getScadenza()));
        for (Condomino.Config.Rata rata : ordered) {
            final String id = rata.getId();
            final double due = round2(rata.getImporto() == null ? 0d : rata.getImporto());
            final double already = round2(paidByRate.getOrDefault(id, 0d));
            final double remainingOnRate = Math.max(0d, round2(due - already));
            if (remainingOnRate <= 0d || unassignedPayments <= 0d) {
                continue;
            }
            final double auto = Math.min(remainingOnRate, unassignedPayments);
            paidByRate.put(id, round2(already + auto));
            unassignedPayments = round2(unassignedPayments - auto);
        }

        final Instant now = Instant.now();
        final List<Condomino.Config.Rata> result = new ArrayList<>();
        for (Condomino.Config.Rata rata : rates) {
            final double due = round2(rata.getImporto() == null ? 0d : rata.getImporto());
            final double paidRaw = round2(paidByRate.getOrDefault(rata.getId(), 0d));
            final double paid = Math.min(due, paidRaw);
            rata.setIncassato(paid);
            rata.setStato(resolveRataStato(paid, due, rata.getScadenza() == null ? now : rata.getScadenza()));
            result.add(rata);
        }
        result.sort(Comparator.comparing(r -> r.getScadenza() == null ? Instant.MAX : r.getScadenza()));
        return result;
    }

    private Condomino.Config.Rata normalizeNewRata(Condomino.Config.Rata payload) {
        Condomino.Config.Rata rata = payload == null ? new Condomino.Config.Rata() : payload;
        if (rata.getId() == null || rata.getId().isBlank()) {
            rata.setId(UUID.randomUUID().toString());
        }
        if (rata.getTipo() == null) {
            rata.setTipo(Condomino.Config.Rata.Tipo.ORDINARIA);
        }
        if (rata.getScadenza() == null) {
            rata.setScadenza(Instant.now());
        }
        final double due = round2(rata.getImporto() == null ? 0d : rata.getImporto());
        final double paid = round2(rata.getIncassato() == null ? 0d : rata.getIncassato());
        rata.setImporto(due);
        rata.setIncassato(Math.min(due, paid));
        rata.setCodice(normalizeBlank(rata.getCodice()));
        rata.setDescrizione(normalizeBlank(rata.getDescrizione()));
        rata.setImporti(rata.getImporti() == null ? Collections.emptyList() : rata.getImporti());
        rata.setStato(resolveRataStato(rata.getIncassato(), due, rata.getScadenza()));
        return rata;
    }

    private Condomino.Config.Rata normalizeUpdatedRata(
            Condomino.Config.Rata old,
            Condomino.Config.Rata payload,
            String rataId) {
        Condomino.Config.Rata rata = payload == null ? new Condomino.Config.Rata() : payload;
        rata.setId((rataId == null || rataId.isBlank()) ? (old == null ? UUID.randomUUID().toString() : old.getId()) : rataId);
        if (rata.getTipo() == null) {
            rata.setTipo(old == null || old.getTipo() == null
                    ? Condomino.Config.Rata.Tipo.ORDINARIA
                    : old.getTipo());
        }
        if (rata.getScadenza() == null) {
            rata.setScadenza(old == null ? Instant.now() : old.getScadenza());
        }
        if (rata.getImporto() == null) {
            rata.setImporto(old == null ? 0d : old.getImporto());
        }
        if (rata.getIncassato() == null) {
            rata.setIncassato(old == null ? 0d : old.getIncassato());
        }
        rata.setCodice(normalizeBlank(rata.getCodice() == null && old != null ? old.getCodice() : rata.getCodice()));
        rata.setDescrizione(normalizeBlank(rata.getDescrizione() == null && old != null ? old.getDescrizione() : rata.getDescrizione()));
        if (rata.getImporti() == null) {
            rata.setImporti(old == null || old.getImporti() == null ? Collections.emptyList() : old.getImporti());
        }
        final double due = round2(rata.getImporto() == null ? 0d : rata.getImporto());
        final double paid = round2(rata.getIncassato() == null ? 0d : rata.getIncassato());
        rata.setImporto(due);
        rata.setIncassato(Math.min(due, paid));
        rata.setStato(resolveRataStato(rata.getIncassato(), due, rata.getScadenza()));
        return rata;
    }

    private void validateRata(Condomino.Config.Rata rata) throws ValidationFailedException {
        if (rata.getCodice() == null || rata.getCodice().isBlank()) {
            throw new ValidationFailedException("validation.required.rata.codice");
        }
        if (rata.getImporto() == null || !Double.isFinite(rata.getImporto()) || rata.getImporto() <= 0d) {
            throw new ValidationFailedException("validation.invalid.rata.importo");
        }
        if (rata.getScadenza() == null) {
            throw new ValidationFailedException("validation.required.rata.scadenza");
        }
    }

    private void validateRateTemplate(RatePlanRequest.Template template) throws ValidationFailedException {
        if (template == null) {
            throw new ValidationFailedException("validation.required.ratePlan.template");
        }
        if (template.getCodice() == null || template.getCodice().isBlank()) {
            throw new ValidationFailedException("validation.required.ratePlan.template.codice");
        }
        if (template.getImportoTotale() == null || !Double.isFinite(template.getImportoTotale()) || template.getImportoTotale() <= 0d) {
            throw new ValidationFailedException("validation.invalid.ratePlan.template.importoTotale");
        }
        if (template.getScadenza() == null) {
            throw new ValidationFailedException("validation.required.ratePlan.template.scadenza");
        }
    }

    private Condomino.Config.Rata.Stato resolveRataStato(double incassato, double importo, Instant scadenza) {
        final double due = round2(importo);
        final double paid = round2(incassato);
        if (due <= 0d) {
            return Condomino.Config.Rata.Stato.PAGATA;
        }
        if (paid >= due - 0.01d) {
            return Condomino.Config.Rata.Stato.PAGATA;
        }
        if (paid > 0d) {
            return Condomino.Config.Rata.Stato.PARZIALE;
        }
        if (scadenza != null && scadenza.isBefore(Instant.now())) {
            return Condomino.Config.Rata.Stato.SCADUTA;
        }
        return Condomino.Config.Rata.Stato.APERTA;
    }

    private void ensureConfig(Condomino position) {
        if (position.getConfig() == null) {
            position.setConfig(new Condomino.Config());
        }
    }

    private double sumVersamenti(List<Condomino.Versamento> versamenti) {
        if (versamenti == null || versamenti.isEmpty()) {
            return 0d;
        }
        double total = 0d;
        for (Condomino.Versamento v : versamenti) {
            if (v == null || v.getImporto() == null) {
                continue;
            }
            total += v.getImporto();
        }
        return round2(total);
    }

    private Condomino.Config cloneCondominoConfig(Condomino.Config source) {
        if (source == null) {
            return null;
        }
        Condomino.Config clone = new Condomino.Config();
        if (source.getTabelle() != null) {
            clone.setTabelle(source.getTabelle().stream()
                    .map(this::cloneTabellaConfig)
                    .toList());
        }
        if (source.getRate() != null) {
            clone.setRate(new ArrayList<>(source.getRate()));
        }
        return clone;
    }

    private Condomino.Config.TabellaConfig cloneTabellaConfig(Condomino.Config.TabellaConfig source) {
        Condomino.Config.TabellaConfig clone = new Condomino.Config.TabellaConfig();
        if (source != null && source.getTabella() != null) {
            Condomino.Config.TabellaRef ref = new Condomino.Config.TabellaRef();
            ref.setCodice(source.getTabella().getCodice());
            ref.setDescrizione(source.getTabella().getDescrizione());
            clone.setTabella(ref);
            clone.setNumeratore(source.getNumeratore());
            clone.setDenominatore(source.getDenominatore());
        }
        return clone;
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

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
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

    private double safeAmount(Double value) {
        return value == null ? 0d : value;
    }

    private boolean isSameUtcDay(Instant left, Instant right) {
        final LocalDate leftDay = left.atOffset(ZoneOffset.UTC).toLocalDate();
        final LocalDate rightDay = right.atOffset(ZoneOffset.UTC).toLocalDate();
        return leftDay.equals(rightDay);
    }

    /**
     * In update, il frontend segnala la rimozione unita' inviando:
     * - unitaImmobiliareId vuoto/null
     * - scala e interno vuoti/null
     */
    private boolean isUnitBindingExplicitlyCleared(CondominoResource resource) {
        if (resource == null) {
            return false;
        }
        return isBlank(resource.getUnitaImmobiliareId())
                && isBlank(resource.getScala())
                && isBlank(resource.getInterno());
    }

    private record CondominoAggregate(Condomino position, CondominoRoot root) {
    }

    private record StableRootWriteResult(CondominoRoot root, boolean syncOtherPositions) {
    }

}
