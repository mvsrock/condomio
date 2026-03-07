package it.condomio.service;

import java.io.IOException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.controller.model.CondominioRootSummaryResponse;
import it.condomio.document.Condominio;
import it.condomio.document.CondominioRoot;
import it.condomio.document.Condomino;
import it.condomio.document.Tabella;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominioRootRepository;
import it.condomio.repository.CondominoRepository;
import it.condomio.repository.MovimentiRepository;
import it.condomio.repository.TabellaRepository;
import it.condomio.util.CondominioLabelKeyUtil;
import it.condomio.util.JsonMergePatchHelper;
import tools.jackson.databind.JsonNode;

@Service
public class CondominioService {
    private static final Logger log = LoggerFactory.getLogger(CondominioService.class);

    @Autowired
    private CondominioRepository condominioRepository;

    @Autowired
    private CondominioRootRepository condominioRootRepository;

    @Autowired
    private CondominoRepository condominoRepository;

    @Autowired
    private MovimentiRepository movimentiRepository;

    @Autowired
    private TabellaRepository tabellaRepository;

    @Autowired
    private TenantAccessService tenantAccessService;

    @Autowired
    private EsercizioGuardService esercizioGuardService;

    /**
     * Crea un nuovo condominio reale (root) e il suo primo esercizio annuale aperto.
     */
    public Condominio createCondominio(Condominio condominio, String adminKeycloakUserId)
            throws ValidationFailedException {
        validateCreatePayload(condominio);
        final String normalizedLabel = CondominioLabelKeyUtil.normalizeLabel(condominio.getLabel());
        final String labelKey = CondominioLabelKeyUtil.toLabelKey(normalizedLabel);
        if (condominioRootRepository.findByAdminKeycloakUserIdAndLabelKey(adminKeycloakUserId, labelKey).isPresent()) {
            throw new ValidationFailedException("validation.duplicate.condominio.root.label");
        }
        CondominioRoot root = createRoot(adminKeycloakUserId, normalizedLabel);
        return createExerciseForRoot(root, condominio, false, adminKeycloakUserId);
    }

    /**
     * Crea un nuovo esercizio annuale sotto un condominio root gia' esistente.
     */
    public Condominio createEsercizio(
            String rootId,
            Condominio esercizio,
            boolean carryOverBalances,
            String adminKeycloakUserId)
            throws ApiException {
        validateCreatePayload(esercizio);
        CondominioRoot root = condominioRootRepository.findByIdAndAdminKeycloakUserId(rootId, adminKeycloakUserId)
                .orElseThrow(() -> new NotFoundException("condominioRoot"));
        return createExerciseForRoot(root, esercizio, carryOverBalances, adminKeycloakUserId);
    }

    /**
     * Lettura singolo esercizio consentita se l'utente lo puo' visualizzare.
     */
    public Optional<Condominio> getCondominioById(String id, String keycloakUserId) {
        if (!tenantAccessService.canViewCondominio(keycloakUserId, id)) {
            return Optional.empty();
        }
        return condominioRepository.findById(id);
    }

    /**
     * Lista esercizi visibili all'utente, ordinati per label e anno piu' recente.
     */
    public List<Condominio> getAllCondomini(String keycloakUserId) {
        final List<String> ids = tenantAccessService.findVisibleCondominioIds(keycloakUserId);
        if (ids.isEmpty()) {
            return List.of();
        }
        return condominioRepository.findAllById(ids).stream()
                .sorted(Comparator
                        .comparing(Condominio::getLabel, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                        .thenComparing(Condominio::getGestioneLabel, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                        .thenComparing(Condominio::getAnno, Comparator.nullsLast(Comparator.reverseOrder())))
                .toList();
    }

    /** Lista root disponibili per creare nuovi esercizi. */
    public List<CondominioRootSummaryResponse> getOwnedRoots(String adminKeycloakUserId) {
        return condominioRootRepository.findByAdminKeycloakUserIdOrderByLabelKeyAsc(adminKeycloakUserId)
                .stream()
                .map(root -> new CondominioRootSummaryResponse(root.getId(), root.getLabel()))
                .toList();
    }

    /**
     * Update esercizio consentito solo se owned e OPEN.
     * Se il label cambia, viene aggiornato anche il root e il label snapshot di tutti gli esercizi collegati.
     */
    public Condominio updateCondominio(String id, Condominio updatedCondominio, String adminKeycloakUserId)
            throws ApiException {
        Condominio existing = esercizioGuardService.requireOwnedOpenExercise(id, adminKeycloakUserId);
        validateCreatePayload(updatedCondominio);
        ensureUniqueExercise(existing.getCondominioRootId(),
                updatedCondominio.getGestioneCodice(),
                updatedCondominio.getAnno(),
                existing.getId());
        ensureUniqueOpenExercise(existing.getCondominioRootId(), updatedCondominio.getGestioneCodice(), existing.getId());

        final String resolvedLabel = resolveAndMaybePropagateRootRename(existing, updatedCondominio.getLabel(),
                adminKeycloakUserId);
        reconcileAccountingFieldsOnUpdate(existing, updatedCondominio);
        normalizeExerciseForPersist(
                updatedCondominio,
                existing.getCondominioRootId(),
                resolvedLabel,
                adminKeycloakUserId,
                existing.getStato());
        updatedCondominio.setId(id);
        updatedCondominio.setVersion(existing.getVersion());
        validateChangedPercentualiByPosition(existing, updatedCondominio);
        return condominioRepository.save(updatedCondominio);
    }

    /**
     * Delete consentita solo su esercizio OPEN e senza documenti figli.
     * Se era l'ultimo esercizio del root, viene rimosso anche il root.
     */
    public void deleteCondominio(String id, String adminKeycloakUserId) throws ApiException {
        Condominio existing = esercizioGuardService.requireOwnedOpenExercise(id, adminKeycloakUserId);
        ensureExerciseIsEmpty(existing.getId());
        condominioRepository.deleteById(id);
        if (condominioRepository.findByCondominioRootIdOrderByAnnoDesc(existing.getCondominioRootId()).isEmpty()) {
            condominioRootRepository.deleteById(existing.getCondominioRootId());
        }
    }

    public Condominio patch(String id, JsonNode mergePatch, String adminKeycloakUserId)
            throws IOException, ValidationFailedException, ApiException {
        Condominio existing = esercizioGuardService.requireOwnedOpenExercise(id, adminKeycloakUserId);
        Condominio patchedCondominio = JsonMergePatchHelper.applyMergePatch(mergePatch, existing, Condominio.class);
        validateCreatePayload(patchedCondominio);
        ensureUniqueExercise(existing.getCondominioRootId(),
                patchedCondominio.getGestioneCodice(),
                patchedCondominio.getAnno(),
                existing.getId());
        ensureUniqueOpenExercise(existing.getCondominioRootId(), patchedCondominio.getGestioneCodice(), existing.getId());

        final String resolvedLabel = resolveAndMaybePropagateRootRename(existing, patchedCondominio.getLabel(),
                adminKeycloakUserId);
        reconcileAccountingFieldsOnUpdate(existing, patchedCondominio);
        normalizeExerciseForPersist(
                patchedCondominio,
                existing.getCondominioRootId(),
                resolvedLabel,
                adminKeycloakUserId,
                existing.getStato());
        patchedCondominio.setId(existing.getId());
        patchedCondominio.setVersion(existing.getVersion());
        validateChangedPercentualiByPosition(existing, patchedCondominio);
        return condominioRepository.save(patchedCondominio);
    }

    /** Chiusura esplicita dell'esercizio: da qui in poi tutte le scritture vengono bloccate. */
    public Condominio closeEsercizio(String id, String adminKeycloakUserId) throws ApiException {
        Condominio existing = esercizioGuardService.requireOwnedExercise(id, adminKeycloakUserId);
        if (existing.getStato() == Condominio.EsercizioStato.CLOSED) {
            return existing;
        }
        existing.setStato(Condominio.EsercizioStato.CLOSED);
        return condominioRepository.save(existing);
    }

    public void validatePercentuali(Condominio condominio) throws ValidationFailedException {
        if (condominio.getConfigurazioniSpesa() == null) {
            return;
        }

        for (Condominio.ConfigurazioneSpesa configurazione : condominio.getConfigurazioniSpesa()) {
            if (configurazione == null) {
                continue;
            }
            List<Condominio.ConfigurazioneSpesa.TabellaPercentuale> tabelle = configurazione.getTabelle();
            if (tabelle == null || tabelle.isEmpty()) {
                continue;
            }

            long tabelleConPercentuale = tabelle.stream()
                    .filter(tabella -> tabella != null && tabella.getPercentuale() != null)
                    .count();
            if (tabelleConPercentuale == 0) {
                continue;
            }

            int sommaPercentuali = tabelle.stream()
                    .filter(tabella -> tabella != null && tabella.getPercentuale() != null)
                    .mapToInt(Condominio.ConfigurazioneSpesa.TabellaPercentuale::getPercentuale)
                    .sum();

            if (sommaPercentuali != 100) {
                final String codice = configurazione.getCodice() == null ? "" : configurazione.getCodice();
                throw new ValidationFailedException("invalid.percent." + codice);
            }
        }
    }

    private Condominio createExerciseForRoot(
            CondominioRoot root,
            Condominio payload,
            boolean carryOverBalances,
            String adminKeycloakUserId)
            throws ValidationFailedException {
        final String gestioneCodice = payload.getGestioneCodice();
        final Condominio previousExercise = condominioRepository
                .findFirstByCondominioRootIdAndGestioneCodiceOrderByAnnoDesc(root.getId(), gestioneCodice)
                .orElse(null);
        ensureCanCreateNextExercise(previousExercise, root.getId(), gestioneCodice, payload.getAnno());
        ensureUniqueExercise(root.getId(), gestioneCodice, payload.getAnno(), null);
        ensureUniqueOpenExercise(root.getId(), gestioneCodice, null);
        payload.setId(null);
        payload.setVersion(null);
        payload.setConfigurazioniSpesa(resolveInitialConfigurazioni(payload, previousExercise));
        if (carryOverBalances && previousExercise != null) {
            payload.setSaldoIniziale(safeAmount(previousExercise.getResiduo()));
        }
        normalizeExerciseForPersist(payload, root.getId(), root.getLabel(), adminKeycloakUserId,
                Condominio.EsercizioStato.OPEN);
        payload.setResiduo(payload.getSaldoIniziale());
        Condominio saved = condominioRepository.save(payload);
        clonePreviousExerciseStructure(previousExercise, saved, carryOverBalances);
        return saved;
    }

    private CondominioRoot createRoot(String adminKeycloakUserId, String normalizedLabel) {
        CondominioRoot root = new CondominioRoot();
        root.setLabel(normalizedLabel);
        root.setLabelKey(CondominioLabelKeyUtil.toLabelKey(normalizedLabel));
        root.setAdminKeycloakUserId(adminKeycloakUserId);
        root.setCreatedAt(Instant.now());
        root.setUpdatedAt(Instant.now());
        return condominioRootRepository.save(root);
    }

    private void normalizeExerciseForPersist(
            Condominio target,
            String rootId,
            String label,
            String adminKeycloakUserId,
            Condominio.EsercizioStato existingState) {
        target.setCondominioRootId(rootId);
        target.setLabel(CondominioLabelKeyUtil.normalizeLabel(label));
        normalizeGestioneFields(target);
        target.setAdminKeycloakUserId(adminKeycloakUserId);
        target.setStato(existingState == null ? Condominio.EsercizioStato.OPEN : existingState);
        target.setSaldoIniziale(target.getSaldoIniziale() == null ? 0d : target.getSaldoIniziale());
        if (target.getResiduo() == null) {
            target.setResiduo(target.getSaldoIniziale());
        }
        if (target.getDataInizio() == null) {
            target.setDataInizio(toStartOfYear(target.getAnno()));
        }
        if (target.getDataFine() == null) {
            target.setDataFine(toEndOfYear(target.getAnno()));
        }
    }

    private String resolveAndMaybePropagateRootRename(
            Condominio existing,
            String requestedLabel,
            String adminKeycloakUserId) throws ApiException {
        final String normalizedRequested = CondominioLabelKeyUtil.normalizeLabel(
                requestedLabel == null || requestedLabel.isBlank() ? existing.getLabel() : requestedLabel);
        final String currentNormalized = CondominioLabelKeyUtil.normalizeLabel(existing.getLabel());
        if (normalizedRequested.equals(currentNormalized)) {
            return currentNormalized;
        }

        CondominioRoot root = condominioRootRepository.findByIdAndAdminKeycloakUserId(
                existing.getCondominioRootId(),
                adminKeycloakUserId).orElseThrow(() -> new NotFoundException("condominioRoot"));
        final String requestedKey = CondominioLabelKeyUtil.toLabelKey(normalizedRequested);
        Optional<CondominioRoot> duplicateRoot =
                condominioRootRepository.findByAdminKeycloakUserIdAndLabelKey(adminKeycloakUserId, requestedKey);
        if (duplicateRoot.isPresent() && !duplicateRoot.get().getId().equals(root.getId())) {
            throw new ValidationFailedException("validation.duplicate.condominio.root.label");
        }
        root.setLabel(normalizedRequested);
        root.setLabelKey(requestedKey);
        root.setUpdatedAt(Instant.now());
        condominioRootRepository.save(root);
        condominioRepository.setLabelSnapshotByRootId(root.getId(), normalizedRequested);
        return normalizedRequested;
    }

    private void ensureUniqueExercise(String rootId, String gestioneCodice, Long anno, String excludeExerciseId)
            throws ValidationFailedException {
        Optional<Condominio> existing = condominioRepository.findByCondominioRootIdAndGestioneCodiceAndAnno(
                rootId,
                gestioneCodice,
                anno);
        if (existing.isEmpty()) {
            return;
        }
        if (excludeExerciseId != null && excludeExerciseId.equals(existing.get().getId())) {
            return;
        }
        throw new ValidationFailedException("validation.duplicate.esercizio.root_gestione_anno");
    }

    /**
     * Nuovo esercizio consentito solo se la gestione selezionata non ha un altro
     * esercizio OPEN e l'anno richiesto e' progressivo rispetto allo storico
     * della stessa gestione.
     */
    private void ensureCanCreateNextExercise(
            Condominio previousExercise,
            String rootId,
            String gestioneCodice,
            Long requestedAnno)
            throws ValidationFailedException {
        ensureUniqueOpenExercise(rootId, gestioneCodice, null);
        if (previousExercise != null
                && previousExercise.getAnno() != null
                && requestedAnno != null
                && requestedAnno <= previousExercise.getAnno()) {
            throw new ValidationFailedException("validation.invalid.esercizio.annoProgressionGestione");
        }
    }

    private void ensureUniqueOpenExercise(String rootId, String gestioneCodice, String excludeExerciseId)
            throws ValidationFailedException {
        Optional<Condominio> existingOpen = condominioRepository
                .findFirstByCondominioRootIdAndGestioneCodiceAndStatoOrderByAnnoDesc(
                        rootId,
                        gestioneCodice,
                        Condominio.EsercizioStato.OPEN);
        if (existingOpen.isEmpty()) {
            return;
        }
        if (excludeExerciseId != null && excludeExerciseId.equals(existingOpen.get().getId())) {
            return;
        }
        throw new ValidationFailedException("validation.exercise.gestioneOpenAlreadyExists");
    }

    private void ensureExerciseIsEmpty(String exerciseId) throws ValidationFailedException {
        if (condominoRepository.existsByIdCondominio(exerciseId)
                || movimentiRepository.existsByIdCondominio(exerciseId)
                || tabellaRepository.existsByIdCondominio(exerciseId)) {
            throw new ValidationFailedException("validation.inuse.esercizio");
        }
    }

    private List<Condominio.ConfigurazioneSpesa> resolveInitialConfigurazioni(
            Condominio payload,
            Condominio previousExercise) {
        if (payload.getConfigurazioniSpesa() != null && !payload.getConfigurazioniSpesa().isEmpty()) {
            return payload.getConfigurazioniSpesa();
        }
        if (previousExercise == null || previousExercise.getConfigurazioniSpesa() == null) {
            return new ArrayList<>();
        }
        return cloneConfigurazioni(previousExercise.getConfigurazioniSpesa());
    }

    private void clonePreviousExerciseStructure(
            Condominio previousExercise,
            Condominio newExercise,
            boolean carryOverBalances) {
        if (previousExercise == null) {
            return;
        }
        cloneTabelle(previousExercise.getId(), newExercise.getId());
        cloneCondomini(previousExercise, newExercise, carryOverBalances);
    }

    private void cloneTabelle(String previousExerciseId, String newExerciseId) {
        List<Tabella> previousTables = tabellaRepository.findByIdCondominio(previousExerciseId);
        if (previousTables.isEmpty()) {
            return;
        }
        List<Tabella> clones = previousTables.stream()
                .map(table -> {
                    Tabella clone = new Tabella();
                    clone.setId(null);
                    clone.setVersion(null);
                    clone.setIdCondominio(newExerciseId);
                    clone.setCodice(table.getCodice());
                    clone.setDescrizione(table.getDescrizione());
                    return clone;
                })
                .toList();
        tabellaRepository.saveAll(clones);
    }

    private void cloneCondomini(
            Condominio previousExercise,
            Condominio newExercise,
            boolean carryOverBalances) {
        List<Condomino> previousCondomini = condominoRepository.findByIdCondominio(previousExercise.getId());
        if (previousCondomini.isEmpty()) {
            return;
        }
        List<Condomino> clones = previousCondomini.stream()
                .map(condomino -> cloneCondomino(condomino, newExercise, carryOverBalances))
                .toList();
        condominoRepository.saveAll(clones);
    }

    /**
     * Ereditiamo solo la posizione annuale:
     * - stesso collegamento all'anagrafica stabile (`condominoRootId`)
     * - stesse quote tabellari
     *
     * Non duplichiamo l'identita' del condomino tra esercizi.
     * Non ereditiamo movimenti, versamenti e rate annuali.
     * Il carry-over dei saldi e' esplicito e opzionale.
     */
    private Condomino cloneCondomino(Condomino source, Condominio newExercise, boolean carryOverBalances) {
        if (source.getCondominoRootId() == null || source.getCondominoRootId().isBlank()) {
            throw new IllegalStateException(
                    "Cannot clone exercise position without condominoRootId. positionId=" + source.getId());
        }
        Condomino clone = new Condomino();
        clone.setId(null);
        clone.setVersion(null);
        clone.setCondominoRootId(source.getCondominoRootId());
        clone.setIdCondominio(newExercise.getId());
        // Gli snapshot denormalizzati vanno copiati nel nuovo esercizio: in questo
        // modo il read model resta autosufficiente anche dopo l'apertura anno.
        clone.setNome(source.getNome());
        clone.setCognome(source.getCognome());
        clone.setEmail(source.getEmail());
        clone.setCellulare(source.getCellulare());
        clone.setKeycloakUserId(source.getKeycloakUserId());
        clone.setKeycloakUsername(source.getKeycloakUsername());
        clone.setAppRole(source.getAppRole());
        clone.setAppEnabled(source.getAppEnabled());
        clone.setSnapshotUpdatedAt(source.getSnapshotUpdatedAt());
        clone.setScala(source.getScala());
        clone.setInterno(source.getInterno());
        clone.setAnno(newExercise.getAnno());
        clone.setConfig(cloneCondominoConfig(source.getConfig()));
        clone.setVersamenti(new ArrayList<>());
        final double startingBalance = carryOverBalances ? safeAmount(source.getResiduo()) : 0d;
        clone.setSaldoIniziale(startingBalance);
        clone.setResiduo(startingBalance);
        return clone;
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
        return clone;
    }

    private Condomino.Config.TabellaConfig cloneTabellaConfig(Condomino.Config.TabellaConfig source) {
        Condomino.Config.TabellaConfig clone = new Condomino.Config.TabellaConfig();
        if (source.getTabella() != null) {
            Condomino.Config.TabellaRef ref = new Condomino.Config.TabellaRef();
            ref.setCodice(source.getTabella().getCodice());
            ref.setDescrizione(source.getTabella().getDescrizione());
            clone.setTabella(ref);
        }
        clone.setNumeratore(source.getNumeratore());
        clone.setDenominatore(source.getDenominatore());
        return clone;
    }

    private List<Condominio.ConfigurazioneSpesa> cloneConfigurazioni(
            List<Condominio.ConfigurazioneSpesa> source) {
        return source.stream()
                .map(configurazione -> {
                    Condominio.ConfigurazioneSpesa clone = new Condominio.ConfigurazioneSpesa();
                    clone.setCodice(configurazione.getCodice());
                    if (configurazione.getTabelle() != null) {
                        clone.setTabelle(configurazione.getTabelle().stream()
                                .map(tabella -> {
                                    Condominio.ConfigurazioneSpesa.TabellaPercentuale copy =
                                            new Condominio.ConfigurazioneSpesa.TabellaPercentuale();
                                    copy.setCodice(tabella.getCodice());
                                    copy.setDescrizione(tabella.getDescrizione());
                                    copy.setPercentuale(tabella.getPercentuale());
                                    return copy;
                                })
                                .toList());
                    }
                    return clone;
                })
                .toList();
    }

    private void validateChangedPercentualiByPosition(Condominio before, Condominio after)
            throws ValidationFailedException {
        List<Condominio.ConfigurazioneSpesa> beforeList =
                before == null ? null : before.getConfigurazioniSpesa();
        List<Condominio.ConfigurazioneSpesa> afterList =
                after == null ? null : after.getConfigurazioniSpesa();

        int beforeSize = beforeList == null ? 0 : beforeList.size();
        int afterSize = afterList == null ? 0 : afterList.size();
        if (afterSize == 0) {
            return;
        }
        for (int i = 0; i < afterSize; i++) {
            Integer beforeSum = i < beforeSize ? sumPercentuali(beforeList.get(i)) : null;
            Integer afterSum = sumPercentuali(afterList.get(i));
            if (afterSum == null) {
                continue;
            }
            boolean legacyNullToZero = beforeSum == null && afterSum == 0;
            boolean changed = !legacyNullToZero && (beforeSum == null || !beforeSum.equals(afterSum));
            if (changed && afterSum != 100) {
                final Condominio.ConfigurazioneSpesa cfg = afterList.get(i);
                final String codice = cfg == null || cfg.getCodice() == null ? "" : cfg.getCodice();
                final String dettaglioTabelle = cfg == null || cfg.getTabelle() == null
                        ? "[]"
                        : cfg.getTabelle().stream()
                                .map(t -> {
                                    if (t == null) {
                                        return "{codice:null,percentuale:null}";
                                    }
                                    return "{codice:" + t.getCodice() + ",percentuale:" + t.getPercentuale() + "}";
                                })
                                .reduce((a, b) -> a + "," + b)
                                .map(s -> "[" + s + "]")
                                .orElse("[]");
                log.warn(
                        "[CondominioService.validateChangedPercentualiByPosition] invalid percent. idCondominio={} index={} codice={} beforeSum={} afterSum={} tabelle={}",
                        after.getId(), i, codice, beforeSum, afterSum, dettaglioTabelle);
                throw new ValidationFailedException("invalid.percent." + codice);
            }
            if (changed) {
                final Condominio.ConfigurazioneSpesa cfg = afterList.get(i);
                final String codice = cfg == null || cfg.getCodice() == null ? "" : cfg.getCodice();
                log.info(
                        "[CondominioService.validateChangedPercentualiByPosition] percent changed. idCondominio={} index={} codice={} beforeSum={} afterSum={}",
                        after.getId(), i, codice, beforeSum, afterSum);
            }
        }
    }

    private Integer sumPercentuali(Condominio.ConfigurazioneSpesa cfg) {
        if (cfg == null || cfg.getTabelle() == null || cfg.getTabelle().isEmpty()) {
            return null;
        }
        long valued = cfg.getTabelle().stream()
                .filter(tabella -> tabella != null && tabella.getPercentuale() != null)
                .count();
        if (valued == 0) {
            return null;
        }
        return cfg.getTabelle().stream()
                .filter(tabella -> tabella != null && tabella.getPercentuale() != null)
                .mapToInt(Condominio.ConfigurazioneSpesa.TabellaPercentuale::getPercentuale)
                .sum();
    }

    private void validateCreatePayload(Condominio condominio) throws ValidationFailedException {
        if (condominio.getLabel() == null || condominio.getLabel().trim().isEmpty()) {
            throw new ValidationFailedException("validation.required.condominio.label");
        }
        normalizeGestioneFields(condominio);
        if (condominio.getAnno() == null) {
            throw new ValidationFailedException("validation.required.condominio.anno");
        }
        if (condominio.getAnno() < 1900 || condominio.getAnno() > 2100) {
            throw new ValidationFailedException("validation.invalid.condominio.anno");
        }
        if (condominio.getDataInizio() != null && condominio.getDataFine() != null
                && condominio.getDataInizio().isAfter(condominio.getDataFine())) {
            throw new ValidationFailedException("validation.invalid.esercizio.dateRange");
        }
        if (condominio.getSaldoIniziale() != null && !Double.isFinite(condominio.getSaldoIniziale())) {
            throw new ValidationFailedException("validation.invalid.condominio.saldoIniziale");
        }
        validatePercentuali(condominio);
    }

    /**
     * La gestione e' opzionale lato payload, ma obbligatoria lato dominio:
     * se manca, il sistema la tratta come gestione ordinaria.
     */
    private void normalizeGestioneFields(Condominio condominio) {
        String rawGestione = condominio.getGestioneLabel();
        if (rawGestione == null || rawGestione.isBlank()) {
            rawGestione = condominio.getGestioneCodice();
        }
        if (rawGestione == null || rawGestione.isBlank()) {
            rawGestione = Condominio.DEFAULT_GESTIONE_LABEL;
        }
        final String normalizedGestione = CondominioLabelKeyUtil.normalizeLabel(rawGestione);
        condominio.setGestioneLabel(normalizedGestione);
        condominio.setGestioneCodice(CondominioLabelKeyUtil.toLabelKey(normalizedGestione));
    }

    private void reconcileAccountingFieldsOnUpdate(Condominio existing, Condominio target) {
        final double oldSaldo = existing.getSaldoIniziale() == null ? 0d : existing.getSaldoIniziale();
        final double newSaldo = target.getSaldoIniziale() == null ? oldSaldo : target.getSaldoIniziale();
        target.setSaldoIniziale(newSaldo);

        final double currentResiduo = existing.getResiduo() == null ? 0d : existing.getResiduo();
        final double deltaSaldo = newSaldo - oldSaldo;
        target.setResiduo(round2(currentResiduo + deltaSaldo));
    }

    private Instant toStartOfYear(Long anno) {
        return LocalDate.of(anno.intValue(), 1, 1).atStartOfDay().toInstant(ZoneOffset.UTC);
    }

    private Instant toEndOfYear(Long anno) {
        return LocalDate.of(anno.intValue(), 12, 31).plusDays(1).atStartOfDay().minusNanos(1).toInstant(ZoneOffset.UTC);
    }

    private double round2(double value) {
        return Math.round(value * 100d) / 100d;
    }

    private double safeAmount(Double amount) {
        if (amount == null || !Double.isFinite(amount)) {
            return 0d;
        }
        return round2(amount);
    }
}
