package it.condomio.service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.Index;
import org.springframework.data.mongodb.core.index.IndexDefinition;
import org.springframework.data.mongodb.core.index.IndexInfo;
import org.springframework.data.mongodb.core.index.IndexOperations;
import org.springframework.data.mongodb.core.index.PartialIndexFilter;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;

import it.condomio.document.Condominio;
import it.condomio.document.CondominioRoot;
import it.condomio.document.Condomino;
import it.condomio.document.Movimenti;
import it.condomio.document.Tabella;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominioRootRepository;
import it.condomio.util.CondominioLabelKeyUtil;

/**
 * Manutenzione schema Mongo all'avvio.
 *
 * Obiettivi:
 * - eliminare indici legacy incompatibili con il nuovo modello root/esercizio
 * - creare gli indici davvero utili ai pattern di query correnti
 * - completare la migrazione dei documenti esercizio gia' esistenti
 */
@Service
public class MongoStructureMaintenanceService implements ApplicationRunner {
    private static final Logger log = LoggerFactory.getLogger(MongoStructureMaintenanceService.class);

    private final MongoTemplate mongoTemplate;
    private final CondominioRepository condominioRepository;
    private final CondominioRootRepository condominioRootRepository;

    public MongoStructureMaintenanceService(
            MongoTemplate mongoTemplate,
            CondominioRepository condominioRepository,
            CondominioRootRepository condominioRootRepository) {
        this.mongoTemplate = mongoTemplate;
        this.condominioRepository = condominioRepository;
        this.condominioRootRepository = condominioRootRepository;
    }

    @Override
    public void run(ApplicationArguments args) {
        backfillRootsAndExercises();
        normalizeOpenExercisesByRoot();
        maintainIndexes();
    }

    private void maintainIndexes() {
        dropIndexIfExists("condominio", "anno_label_idx");
        dropIndexIfExists("condominio", "configurazioniSpesa.codice");
        dropIndexIfExists("condominio", "configurazioniSpesa.tabelle.codice");
        dropIndexIfExists("condomino", "email");
        dropIndexIfExists("condomino", "config.tabelle.tabella.codice");

        ensureRootIndexes();
        ensureExerciseIndexes();
        ensureCondominoIndexes();
        ensureMovimentiIndexes();
        ensureTabellaIndexes();
    }

    private void ensureRootIndexes() {
        IndexOperations ops = mongoTemplate.indexOps(CondominioRoot.class);
        createIndexIfMissing(ops, "admin_label_key_uidx", new Index()
                .on("adminKeycloakUserId", Sort.Direction.ASC)
                .on("labelKey", Sort.Direction.ASC)
                .unique()
                .named("admin_label_key_uidx"));
        createIndexIfMissing(ops, "admin_updated_idx", new Index()
                .on("adminKeycloakUserId", Sort.Direction.ASC)
                .on("updatedAt", Sort.Direction.DESC)
                .named("admin_updated_idx"));
    }

    private void ensureCondominoIndexes() {
        IndexOperations ops = mongoTemplate.indexOps(Condomino.class);
        createIndexIfMissing(ops, "condominio_email_idx", new Index()
                .on("idCondominio", Sort.Direction.ASC)
                .on("email", Sort.Direction.ASC)
                .unique()
                .named("condominio_email_idx"));
        createIndexIfMissing(ops, "exercise_name_idx", new Index()
                .on("idCondominio", Sort.Direction.ASC)
                .on("cognome", Sort.Direction.ASC)
                .on("nome", Sort.Direction.ASC)
                .named("exercise_name_idx"));
        createIndexIfMissing(ops, "keycloak_exercise_idx", new Index()
                .on("keycloakUserId", Sort.Direction.ASC)
                .on("idCondominio", Sort.Direction.ASC)
                .named("keycloak_exercise_idx"));
    }

    private void ensureMovimentiIndexes() {
        IndexOperations ops = mongoTemplate.indexOps(Movimenti.class);
        createIndexIfMissing(ops, "exercise_date_idx", new Index()
                .on("idCondominio", Sort.Direction.ASC)
                .on("date", Sort.Direction.DESC)
                .named("exercise_date_idx"));
        createIndexIfMissing(ops, "exercise_codice_idx", new Index()
                .on("idCondominio", Sort.Direction.ASC)
                .on("codiceSpesa", Sort.Direction.ASC)
                .named("exercise_codice_idx"));
    }

    private void ensureExerciseIndexes() {
        IndexOperations ops = mongoTemplate.indexOps(Condominio.class);
        createIndexIfMissing(ops, "root_anno_uidx", new Index()
                .on("condominioRootId", Sort.Direction.ASC)
                .on("anno", Sort.Direction.ASC)
                .unique()
                .named("root_anno_uidx"));
        createIndexIfMissing(ops, "root_open_uidx", new Index()
                .on("condominioRootId", Sort.Direction.ASC)
                .unique()
                .partial(PartialIndexFilter.of(Criteria.where("stato").is(Condominio.EsercizioStato.OPEN.name())))
                .named("root_open_uidx"));
        createIndexIfMissing(ops, "admin_stato_anno_idx", new Index()
                .on("adminKeycloakUserId", Sort.Direction.ASC)
                .on("stato", Sort.Direction.ASC)
                .on("anno", Sort.Direction.DESC)
                .named("admin_stato_anno_idx"));
        createIndexIfMissing(ops, "root_stato_anno_idx", new Index()
                .on("condominioRootId", Sort.Direction.ASC)
                .on("stato", Sort.Direction.ASC)
                .on("anno", Sort.Direction.DESC)
                .named("root_stato_anno_idx"));
    }

    private void ensureTabellaIndexes() {
        IndexOperations ops = mongoTemplate.indexOps(Tabella.class);
        createIndexIfMissing(ops, "condominio_codice_idx", new Index()
                .on("idCondominio", Sort.Direction.ASC)
                .on("codice", Sort.Direction.ASC)
                .unique()
                .named("condominio_codice_idx"));
    }

    private void dropIndexIfExists(String collectionName, String indexName) {
        try {
            mongoTemplate.indexOps(collectionName).dropIndex(indexName);
            log.info("[MongoStructureMaintenanceService] dropped legacy index {} on {}", indexName, collectionName);
        } catch (Exception ignored) {
            // L'indice potrebbe non esistere: nessuna azione richiesta.
        }
    }

    private void createIndexIfMissing(IndexOperations ops, String indexName, IndexDefinition definition) {
        boolean exists = ops.getIndexInfo().stream()
                .map(IndexInfo::getName)
                .anyMatch(indexName::equals);
        if (!exists) {
            ops.createIndex(definition);
        }
    }

    private void backfillRootsAndExercises() {
        Query query = new Query(new Criteria().orOperator(
                Criteria.where("condominioRootId").exists(false),
                Criteria.where("condominioRootId").is(null),
                Criteria.where("stato").exists(false),
                Criteria.where("dataInizio").exists(false),
                Criteria.where("dataFine").exists(false)));
        List<Condominio> legacyExercises = mongoTemplate.find(query, Condominio.class);
        if (legacyExercises.isEmpty()) {
            return;
        }

        Map<String, CondominioRoot> rootCache = new HashMap<>();
        List<Condominio> toSave = new ArrayList<>();

        for (Condominio exercise : legacyExercises) {
            CondominioRoot root = resolveRootForLegacyExercise(exercise, rootCache);
            if (root == null) {
                log.warn(
                        "[MongoStructureMaintenanceService] skipped legacy exercise without resolvable root. exerciseId={}",
                        exercise.getId());
                continue;
            }
            boolean changed = false;
            if (exercise.getCondominioRootId() == null || exercise.getCondominioRootId().isBlank()) {
                exercise.setCondominioRootId(root.getId());
                changed = true;
            }
            if (exercise.getLabel() == null || exercise.getLabel().isBlank()) {
                exercise.setLabel(root.getLabel());
                changed = true;
            }
            if (exercise.getStato() == null) {
                exercise.setStato(Condominio.EsercizioStato.OPEN);
                changed = true;
            }
            if (exercise.getDataInizio() == null) {
                exercise.setDataInizio(toStartOfYear(exercise.getAnno()));
                changed = true;
            }
            if (exercise.getDataFine() == null) {
                exercise.setDataFine(toEndOfYear(exercise.getAnno()));
                changed = true;
            }
            if (changed) {
                toSave.add(exercise);
            }
        }

        if (!toSave.isEmpty()) {
            condominioRepository.saveAll(toSave);
            log.info("[MongoStructureMaintenanceService] backfilled {} legacy exercises", toSave.size());
        }
    }

    /**
     * La partial unique index sugli esercizi OPEN richiede una normalizzazione
     * preventiva dei dati legacy: per ogni root resta OPEN solo l'anno piu'
     * recente, gli altri vengono chiusi.
     */
    private void normalizeOpenExercisesByRoot() {
        Query openExercisesQuery = new Query(Criteria.where("stato").is(Condominio.EsercizioStato.OPEN));
        List<Condominio> openExercises = mongoTemplate.find(openExercisesQuery, Condominio.class);
        if (openExercises.isEmpty()) {
            return;
        }

        Map<String, List<Condominio>> groupedByRoot = new HashMap<>();
        for (Condominio exercise : openExercises) {
            if (exercise.getCondominioRootId() == null || exercise.getCondominioRootId().isBlank()) {
                continue;
            }
            groupedByRoot.computeIfAbsent(exercise.getCondominioRootId(), ignored -> new ArrayList<>()).add(exercise);
        }

        List<Condominio> toClose = new ArrayList<>();
        for (List<Condominio> exercises : groupedByRoot.values()) {
            if (exercises.size() <= 1) {
                continue;
            }
            exercises.sort(Comparator
                    .comparing(Condominio::getAnno, Comparator.nullsLast(Comparator.reverseOrder()))
                    .thenComparing(Condominio::getId, Comparator.nullsLast(String::compareTo)));
            for (int i = 1; i < exercises.size(); i++) {
                Condominio duplicateOpen = exercises.get(i);
                duplicateOpen.setStato(Condominio.EsercizioStato.CLOSED);
                toClose.add(duplicateOpen);
            }
        }

        if (!toClose.isEmpty()) {
            condominioRepository.saveAll(toClose);
            log.info(
                    "[MongoStructureMaintenanceService] normalized {} legacy open exercises before unique index creation",
                    toClose.size());
        }
    }

    private CondominioRoot resolveRootForLegacyExercise(
            Condominio exercise,
            Map<String, CondominioRoot> rootCache) {
        if (exercise.getCondominioRootId() != null && !exercise.getCondominioRootId().isBlank()) {
            return condominioRootRepository.findById(exercise.getCondominioRootId())
                    .orElseGet(() -> createMissingRootWithExplicitId(exercise));
        }
        final String adminKeycloakUserId = exercise.getAdminKeycloakUserId();
        if (adminKeycloakUserId == null || adminKeycloakUserId.isBlank()) {
            return null;
        }
        final String labelSnapshot = CondominioLabelKeyUtil.normalizeLabel(exercise.getLabel());
        final String cacheKey = adminKeycloakUserId + "::" + CondominioLabelKeyUtil.toLabelKey(labelSnapshot);
        if (rootCache.containsKey(cacheKey)) {
            return rootCache.get(cacheKey);
        }
        CondominioRoot root = condominioRootRepository
                .findByAdminKeycloakUserIdAndLabelKey(adminKeycloakUserId, CondominioLabelKeyUtil.toLabelKey(labelSnapshot))
                .orElseGet(() -> createRoot(adminKeycloakUserId, labelSnapshot, null));
        rootCache.put(cacheKey, root);
        return root;
    }

    private CondominioRoot createMissingRootWithExplicitId(Condominio exercise) {
        CondominioRoot root = new CondominioRoot();
        root.setId(exercise.getCondominioRootId());
        root.setLabel(CondominioLabelKeyUtil.normalizeLabel(exercise.getLabel()));
        root.setLabelKey(CondominioLabelKeyUtil.toLabelKey(exercise.getLabel()));
        root.setAdminKeycloakUserId(exercise.getAdminKeycloakUserId());
        root.setCreatedAt(Instant.now());
        root.setUpdatedAt(Instant.now());
        return condominioRootRepository.save(root);
    }

    private CondominioRoot createRoot(String adminKeycloakUserId, String label, String explicitId) {
        CondominioRoot root = new CondominioRoot();
        root.setId(explicitId);
        root.setLabel(CondominioLabelKeyUtil.normalizeLabel(label));
        root.setLabelKey(CondominioLabelKeyUtil.toLabelKey(label));
        root.setAdminKeycloakUserId(adminKeycloakUserId);
        root.setCreatedAt(Instant.now());
        root.setUpdatedAt(Instant.now());
        return condominioRootRepository.save(root);
    }

    private Instant toStartOfYear(Long anno) {
        long resolvedYear = (anno == null || anno < 1900L || anno > 2100L) ? LocalDate.now().getYear() : anno;
        return LocalDate.of((int) resolvedYear, 1, 1).atStartOfDay().toInstant(ZoneOffset.UTC);
    }

    private Instant toEndOfYear(Long anno) {
        long resolvedYear = (anno == null || anno < 1900L || anno > 2100L) ? LocalDate.now().getYear() : anno;
        return LocalDate.of((int) resolvedYear, 12, 31).plusDays(1).atStartOfDay().minusNanos(1).toInstant(ZoneOffset.UTC);
    }
}
