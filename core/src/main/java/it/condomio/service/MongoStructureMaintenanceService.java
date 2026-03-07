package it.condomio.service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import org.bson.Document;
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
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import com.mongodb.MongoNamespace;

import it.condomio.document.Condominio;
import it.condomio.document.CondominioRoot;
import it.condomio.document.Condomino;
import it.condomio.document.CondominoRoot;
import it.condomio.document.Movimenti;
import it.condomio.document.Tabella;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominioRootRepository;
import it.condomio.repository.CondominoRootRepository;
import it.condomio.util.CondominioLabelKeyUtil;

/**
 * Manutenzione schema Mongo all'avvio.
 *
 * Responsabilita':
 * - rinominare le collection legacy verso il nuovo dominio `condominio/esercizio`
 * - completare i backfill necessari dopo i refactor del modello
 * - mantenere indici coerenti con i pattern di query reali, senza recreate aggressivi
 */
@Service
public class MongoStructureMaintenanceService implements ApplicationRunner {
    private static final Logger log = LoggerFactory.getLogger(MongoStructureMaintenanceService.class);

    private final MongoTemplate mongoTemplate;
    private final CondominioRepository condominioRepository;
    private final CondominioRootRepository condominioRootRepository;
    private final CondominoRootRepository condominoRootRepository;

    public MongoStructureMaintenanceService(
            MongoTemplate mongoTemplate,
            CondominioRepository condominioRepository,
            CondominioRootRepository condominioRootRepository,
            CondominoRootRepository condominoRootRepository) {
        this.mongoTemplate = mongoTemplate;
        this.condominioRepository = condominioRepository;
        this.condominioRootRepository = condominioRootRepository;
        this.condominoRootRepository = condominoRootRepository;
    }

    @Override
    public void run(ApplicationArguments args) {
        // Ordine importante:
        // 1. rename legacy collections
        // 2. backfill root/esercizi
        // 3. normalizzazione OPEN legacy
        // 4. drop degli indici legacy che bloccano il backfill dei condomini
        // 5. backfill anagrafiche stabili dei condomini
        // 6. indici finali coerenti con il modello corrente
        renameLegacyCollectionsIfNeeded();
        backfillRootsAndExercises();
        normalizeOpenExercisesByRootAndGestione();
        dropLegacyIndexes();
        backfillCondominoRootsAndPositions();
        normalizeCondominoRootOptionalFields();
        ensureFinalIndexes();
    }

    private void renameLegacyCollectionsIfNeeded() {
        renameCollectionIfNeeded("condominio", "esercizio");
        renameCollectionIfNeeded("condominio_root", "condominio");
    }

    private void renameCollectionIfNeeded(String legacyName, String targetName) {
        final boolean legacyExists = collectionExists(legacyName);
        final boolean targetExists = collectionExists(targetName);
        if (!legacyExists) {
            return;
        }
        if (targetExists) {
            log.warn(
                    "[MongoStructureMaintenanceService] skipped rename {} -> {} because target collection already exists",
                    legacyName,
                    targetName);
            return;
        }
        mongoTemplate.getDb()
                .getCollection(legacyName)
                .renameCollection(new MongoNamespace(mongoTemplate.getDb().getName(), targetName));
        log.info("[MongoStructureMaintenanceService] renamed collection {} -> {}", legacyName, targetName);
    }

    private boolean collectionExists(String collectionName) {
        return mongoTemplate.getDb()
                .listCollectionNames()
                .into(new ArrayList<>())
                .contains(collectionName);
    }

    private void dropLegacyIndexes() {
        // Legacy esercizi.
        dropIndexIfExists("esercizio", "anno_label_idx");
        dropIndexIfExists("esercizio", "configurazioniSpesa.codice");
        dropIndexIfExists("esercizio", "configurazioniSpesa.tabelle.codice");
        dropIndexIfExists("esercizio", "root_anno_uidx");
        dropIndexIfExists("esercizio", "root_open_uidx");
        dropIndexIfExists("esercizio", "admin_stato_anno_idx");
        dropIndexIfExists("esercizio", "root_stato_anno_idx");

        // Legacy posizioni condomino.
        dropIndexIfExists("condomino", "email");
        dropIndexIfExists("condomino", "nome_cognome_idx");
        dropIndexIfExists("condomino", "condominio_email_idx");
        dropIndexIfExists("condomino", "config.tabelle.tabella.codice");
    }

    private void ensureFinalIndexes() {
        ensureRootIndexes();
        ensureExerciseIndexes();
        ensureCondominoRootIndexes();
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

    private void ensureExerciseIndexes() {
        IndexOperations ops = mongoTemplate.indexOps(Condominio.class);
        createIndexIfMissing(ops, "root_gestione_anno_uidx", new Index()
                .on("condominioRootId", Sort.Direction.ASC)
                .on("gestioneCodice", Sort.Direction.ASC)
                .on("anno", Sort.Direction.ASC)
                .unique()
                .named("root_gestione_anno_uidx"));
        createIndexIfMissing(ops, "root_gestione_open_uidx", new Index()
                .on("condominioRootId", Sort.Direction.ASC)
                .on("gestioneCodice", Sort.Direction.ASC)
                .unique()
                .partial(PartialIndexFilter.of(Criteria.where("stato").is(Condominio.EsercizioStato.OPEN.name())))
                .named("root_gestione_open_uidx"));
        createIndexIfMissing(ops, "admin_gestione_stato_anno_idx", new Index()
                .on("adminKeycloakUserId", Sort.Direction.ASC)
                .on("gestioneCodice", Sort.Direction.ASC)
                .on("stato", Sort.Direction.ASC)
                .on("anno", Sort.Direction.DESC)
                .named("admin_gestione_stato_anno_idx"));
        createIndexIfMissing(ops, "root_gestione_stato_anno_idx", new Index()
                .on("condominioRootId", Sort.Direction.ASC)
                .on("gestioneCodice", Sort.Direction.ASC)
                .on("stato", Sort.Direction.ASC)
                .on("anno", Sort.Direction.DESC)
                .named("root_gestione_stato_anno_idx"));
    }

    private void ensureCondominoRootIndexes() {
        IndexOperations ops = mongoTemplate.indexOps(CondominoRoot.class);
        createIndexIfMissing(ops, "condominio_email_uidx", new Index()
                .on("condominioRootId", Sort.Direction.ASC)
                .on("email", Sort.Direction.ASC)
                .unique()
                .partial(PartialIndexFilter.of(Criteria.where("email").exists(true)))
                .named("condominio_email_uidx"));
        createIndexIfMissing(ops, "condominio_keycloak_uidx", new Index()
                .on("condominioRootId", Sort.Direction.ASC)
                .on("keycloakUserId", Sort.Direction.ASC)
                .unique()
                .partial(PartialIndexFilter.of(Criteria.where("keycloakUserId").exists(true)))
                .named("condominio_keycloak_uidx"));
        createIndexIfMissing(ops, "condominio_name_idx", new Index()
                .on("condominioRootId", Sort.Direction.ASC)
                .on("cognome", Sort.Direction.ASC)
                .on("nome", Sort.Direction.ASC)
                .named("condominio_name_idx"));
        createIndexIfMissing(ops, "keycloak_user_idx", new Index()
                .on("keycloakUserId", Sort.Direction.ASC)
                .named("keycloak_user_idx"));
    }

    private void ensureCondominoIndexes() {
        IndexOperations ops = mongoTemplate.indexOps(Condomino.class);
        createIndexIfMissing(ops, "exercise_root_uidx", new Index()
                .on("idCondominio", Sort.Direction.ASC)
                .on("condominoRootId", Sort.Direction.ASC)
                .unique()
                .named("exercise_root_uidx"));
        createIndexIfMissing(ops, "exercise_name_idx", new Index()
                .on("idCondominio", Sort.Direction.ASC)
                .on("cognome", Sort.Direction.ASC)
                .on("nome", Sort.Direction.ASC)
                .named("exercise_name_idx"));
        createIndexIfMissing(ops, "keycloak_exercise_idx", new Index()
                .on("keycloakUserId", Sort.Direction.ASC)
                .on("idCondominio", Sort.Direction.ASC)
                .named("keycloak_exercise_idx"));
        createIndexIfMissing(ops, "root_exercise_idx", new Index()
                .on("condominoRootId", Sort.Direction.ASC)
                .on("idCondominio", Sort.Direction.ASC)
                .named("root_exercise_idx"));
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
                Criteria.where("gestioneCodice").exists(false),
                Criteria.where("gestioneCodice").is(null),
                Criteria.where("gestioneLabel").exists(false),
                Criteria.where("gestioneLabel").is(null),
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
            if (isBlank(exercise.getCondominioRootId())) {
                exercise.setCondominioRootId(root.getId());
                changed = true;
            }
            if (isBlank(exercise.getLabel())) {
                exercise.setLabel(root.getLabel());
                changed = true;
            }
            if (isBlank(exercise.getGestioneLabel())) {
                exercise.setGestioneLabel(Condominio.DEFAULT_GESTIONE_LABEL);
                changed = true;
            }
            if (isBlank(exercise.getGestioneCodice())) {
                exercise.setGestioneCodice(CondominioLabelKeyUtil.toLabelKey(exercise.getGestioneLabel()));
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
     * La unique partial index sugli esercizi OPEN richiede dati coerenti:
     * per ogni coppia root+gestione puo' restare OPEN solo l'esercizio piu' recente.
     */
    private void normalizeOpenExercisesByRootAndGestione() {
        Query openExercisesQuery = new Query(Criteria.where("stato").is(Condominio.EsercizioStato.OPEN));
        List<Condominio> openExercises = mongoTemplate.find(openExercisesQuery, Condominio.class);
        if (openExercises.isEmpty()) {
            return;
        }

        Map<String, List<Condominio>> groupedByRootAndGestione = new HashMap<>();
        for (Condominio exercise : openExercises) {
            if (isBlank(exercise.getCondominioRootId())) {
                continue;
            }
            final String gestioneCodice = isBlank(exercise.getGestioneCodice())
                    ? CondominioLabelKeyUtil.toLabelKey(Condominio.DEFAULT_GESTIONE_LABEL)
                    : exercise.getGestioneCodice();
            final String key = exercise.getCondominioRootId() + "::" + gestioneCodice;
            groupedByRootAndGestione.computeIfAbsent(key, ignored -> new ArrayList<>()).add(exercise);
        }

        List<Condominio> toClose = new ArrayList<>();
        for (List<Condominio> exercises : groupedByRootAndGestione.values()) {
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

    /**
     * Trasforma i vecchi documenti `condomino` nel nuovo modello:
     * - crea/riusa `condomino_root`
     * - collega la posizione esercizio con `condominoRootId`
     * - riallinea gli snapshot denormalizzati sulla posizione
     */
    private void backfillCondominoRootsAndPositions() {
        List<Document> legacyPositions = loadCondominoPositionsNeedingBackfill();
        if (legacyPositions.isEmpty()) {
            return;
        }

        Map<String, Condominio> exerciseCache = new HashMap<>();
        Map<String, CondominoRoot> rootCache = new HashMap<>();
        int createdRoots = 0;
        int syncedPositions = 0;

        for (Document rawPosition : legacyPositions) {
            String exerciseId = normalizeBlank(readString(rawPosition, "idCondominio"));
            if (exerciseId == null) {
                log.warn("[MongoStructureMaintenanceService] skipped condomino legacy document without idCondominio. _id={}",
                        rawPosition.get("_id"));
                continue;
            }

            Condominio exercise = exerciseCache.computeIfAbsent(
                    exerciseId,
                    id -> condominioRepository.findById(id).orElse(null));
            if (exercise == null || isBlank(exercise.getCondominioRootId())) {
                log.warn(
                        "[MongoStructureMaintenanceService] skipped condomino legacy document without resolvable exercise root. _id={} exerciseId={}",
                        rawPosition.get("_id"),
                        exerciseId);
                continue;
            }

            LegacyStableFields stableFields = readLegacyStableFields(rawPosition);
            String explicitRootId = normalizeBlank(readString(rawPosition, "condominoRootId"));

            ResolutionResult resolution;
            if (explicitRootId != null) {
                resolution = new ResolutionResult(
                        loadOrCreateExplicitStableRoot(explicitRootId, exercise.getCondominioRootId(), stableFields),
                        false);
            } else {
                resolution = resolveOrCreateCondominoRoot(exercise.getCondominioRootId(), stableFields, rootCache);
            }
            CondominoRoot stableRoot = resolution.root();
            if (stableRoot == null) {
                log.warn(
                        "[MongoStructureMaintenanceService] skipped condomino legacy document without resolvable stable root. _id={} exerciseId={}",
                        rawPosition.get("_id"),
                        exerciseId);
                continue;
            }
            if (resolution.created()) {
                createdRoots++;
            }

            Update update = new Update();
            boolean positionChanged = false;
            if (!stableRoot.getId().equals(explicitRootId)) {
                update.set("condominoRootId", stableRoot.getId());
                positionChanged = true;
            }
            if (!hasAnno(rawPosition) && exercise.getAnno() != null) {
                update.set("anno", exercise.getAnno());
                positionChanged = true;
            }
            positionChanged |= syncPositionSnapshots(rawPosition, update, stableRoot);

            if (positionChanged) {
                Query byId = Query.query(Criteria.where("_id").is(rawPosition.get("_id")));
                mongoTemplate.updateFirst(byId, update, "condomino");
                syncedPositions++;
            }
        }

        if (syncedPositions > 0 || createdRoots > 0) {
            log.info(
                    "[MongoStructureMaintenanceService] migrated condomino positions. createdRoots={} syncedPositions={}",
                    createdRoots,
                    syncedPositions);
        }
    }

    /**
     * Non basta cercare solo documenti con campi mancanti: dopo un refactor
     * parziale possono esistere posizioni formalmente complete ma collegate a un
     * `condominoRootId` che non ha alcun documento reale in `condomino_root`.
     */
    private List<Document> loadCondominoPositionsNeedingBackfill() {
        Map<String, Document> candidatesById = new LinkedHashMap<>();
        for (Document legacyPosition : mongoTemplate.find(buildLegacyCondominoBackfillQuery(), Document.class, "condomino")) {
            candidatesById.put(String.valueOf(legacyPosition.get("_id")), legacyPosition);
        }

        Set<String> missingRootIds = findMissingReferencedCondominoRootIds();
        if (!missingRootIds.isEmpty()) {
            Query missingRootQuery = Query.query(Criteria.where("condominoRootId").in(new ArrayList<>(missingRootIds)));
            for (Document rawPosition : mongoTemplate.find(missingRootQuery, Document.class, "condomino")) {
                candidatesById.putIfAbsent(String.valueOf(rawPosition.get("_id")), rawPosition);
            }
        }
        return new ArrayList<>(candidatesById.values());
    }

    private Query buildLegacyCondominoBackfillQuery() {
        return new Query(new Criteria().orOperator(
                Criteria.where("condominoRootId").exists(false),
                Criteria.where("condominoRootId").is(null),
                Criteria.where("condominoRootId").is(""),
                Criteria.where("anno").exists(false),
                Criteria.where("anno").is(null),
                Criteria.where("nome").exists(false),
                Criteria.where("nome").is(null),
                Criteria.where("cognome").exists(false),
                Criteria.where("cognome").is(null),
                Criteria.where("email").exists(false),
                Criteria.where("email").is(null),
                Criteria.where("cellulare").exists(false),
                Criteria.where("cellulare").is(null),
                Criteria.where("keycloakUserId").exists(false),
                Criteria.where("keycloakUserId").is(null),
                Criteria.where("keycloakUsername").exists(false),
                Criteria.where("keycloakUsername").is(null),
                Criteria.where("appRole").exists(false),
                Criteria.where("appRole").is(null),
                Criteria.where("appEnabled").exists(false),
                Criteria.where("appEnabled").is(null),
                Criteria.where("snapshotUpdatedAt").exists(false),
                Criteria.where("snapshotUpdatedAt").is(null)));
    }

    private Set<String> findMissingReferencedCondominoRootIds() {
        List<String> referencedRootIds = mongoTemplate.getCollection("condomino")
                .distinct("condominoRootId", String.class)
                .into(new ArrayList<>());
        if (referencedRootIds.isEmpty()) {
            return Set.of();
        }

        Set<String> existingRootIds = new LinkedHashSet<>();
        for (Document rawRoot : mongoTemplate.findAll(Document.class, "condomino_root")) {
            Object existingRootId = rawRoot.get("_id");
            if (existingRootId != null) {
                existingRootIds.add(existingRootId.toString());
            }
        }
        Set<String> missingRootIds = new LinkedHashSet<>();
        for (String referencedRootId : referencedRootIds) {
            String normalizedRootId = normalizeBlank(referencedRootId);
            if (normalizedRootId == null) {
                continue;
            }
            if (!existingRootIds.contains(normalizedRootId)) {
                missingRootIds.add(normalizedRootId);
            }
        }
        return missingRootIds;
    }

    /**
     * Gli indici unici parziali su Mongo non possono usare `$ne: null`.
     * Per questo normalizziamo i campi opzionali rimuovendo dal documento i valori
     * null/vuoti prima di creare gli indici finali.
     */
    private void normalizeCondominoRootOptionalFields() {
        List<Document> rawRoots = mongoTemplate.findAll(Document.class, "condomino_root");
        if (rawRoots.isEmpty()) {
            return;
        }

        int updated = 0;
        for (Document rawRoot : rawRoots) {
            Update update = new Update();
            boolean changed = false;

            changed |= normalizeOptionalStringField(rawRoot, update, "email");
            changed |= normalizeOptionalStringField(rawRoot, update, "keycloakUserId");
            changed |= normalizeOptionalStringField(rawRoot, update, "keycloakUsername");
            changed |= normalizeOptionalStringField(rawRoot, update, "cellulare");
            changed |= normalizeOptionalStringField(rawRoot, update, "appRole");

            if (rawRoot.containsKey("appEnabled") && rawRoot.get("appEnabled") == null) {
                update.unset("appEnabled");
                changed = true;
            }

            if (changed) {
                Query byId = Query.query(Criteria.where("_id").is(rawRoot.get("_id")));
                mongoTemplate.updateFirst(byId, update, "condomino_root");
                updated++;
            }
        }

        if (updated > 0) {
            log.info(
                    "[MongoStructureMaintenanceService] normalized optional identity fields on {} condomino_root documents",
                    updated);
        }
    }

    private CondominioRoot resolveRootForLegacyExercise(
            Condominio exercise,
            Map<String, CondominioRoot> rootCache) {
        if (!isBlank(exercise.getCondominioRootId())) {
            return condominioRootRepository.findById(exercise.getCondominioRootId())
                    .orElseGet(() -> createMissingRootWithExplicitId(exercise));
        }

        final String adminKeycloakUserId = exercise.getAdminKeycloakUserId();
        if (isBlank(adminKeycloakUserId)) {
            return null;
        }
        final String normalizedLabel = CondominioLabelKeyUtil.normalizeLabel(exercise.getLabel());
        final String cacheKey = adminKeycloakUserId + "::" + CondominioLabelKeyUtil.toLabelKey(normalizedLabel);
        if (rootCache.containsKey(cacheKey)) {
            return rootCache.get(cacheKey);
        }
        CondominioRoot root = condominioRootRepository
                .findByAdminKeycloakUserIdAndLabelKey(adminKeycloakUserId, CondominioLabelKeyUtil.toLabelKey(normalizedLabel))
                .orElseGet(() -> createRoot(adminKeycloakUserId, normalizedLabel, null));
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

    private CondominoRoot loadOrCreateExplicitStableRoot(
            String explicitRootId,
            String condominioRootId,
            LegacyStableFields stableFields) {
        Optional<CondominoRoot> existing = condominoRootRepository.findById(explicitRootId);
        if (existing.isPresent()) {
            return mergeStableFields(existing.get(), condominioRootId, stableFields);
        }
        CondominoRoot created = new CondominoRoot();
        created.setId(explicitRootId);
        created.setCondominioRootId(condominioRootId);
        created.setCreatedAt(Instant.now());
        created.setUpdatedAt(Instant.now());
        applyStableFields(created, stableFields);
        return condominoRootRepository.save(created);
    }

    private ResolutionResult resolveOrCreateCondominoRoot(
            String condominioRootId,
            LegacyStableFields stableFields,
            Map<String, CondominoRoot> cache) {
        String keycloakCacheKey = cacheKeyByKeycloak(condominioRootId, stableFields.keycloakUserId());
        if (keycloakCacheKey != null && cache.containsKey(keycloakCacheKey)) {
            return new ResolutionResult(mergeStableFields(cache.get(keycloakCacheKey), condominioRootId, stableFields), false);
        }
        String emailCacheKey = cacheKeyByEmail(condominioRootId, stableFields.email());
        if (emailCacheKey != null && cache.containsKey(emailCacheKey)) {
            return new ResolutionResult(mergeStableFields(cache.get(emailCacheKey), condominioRootId, stableFields), false);
        }

        CondominoRoot existing = findExistingCondominoRoot(condominioRootId, stableFields);
        if (existing != null) {
            existing = mergeStableFields(existing, condominioRootId, stableFields);
            cacheStableRoot(cache, existing);
            return new ResolutionResult(existing, false);
        }

        CondominoRoot created = new CondominoRoot();
        created.setCondominioRootId(condominioRootId);
        created.setCreatedAt(Instant.now());
        created.setUpdatedAt(Instant.now());
        applyStableFields(created, stableFields);
        created = condominoRootRepository.save(created);
        cacheStableRoot(cache, created);
        return new ResolutionResult(created, true);
    }

    private CondominoRoot findExistingCondominoRoot(String condominioRootId, LegacyStableFields stableFields) {
        if (stableFields.keycloakUserId() != null) {
            Optional<CondominoRoot> byKeycloak = condominoRootRepository
                    .findByCondominioRootIdAndKeycloakUserId(condominioRootId, stableFields.keycloakUserId());
            if (byKeycloak.isPresent()) {
                return byKeycloak.get();
            }
        }
        if (stableFields.email() != null) {
            return condominoRootRepository.findByCondominioRootIdAndEmail(condominioRootId, stableFields.email())
                    .orElse(null);
        }
        return null;
    }

    private CondominoRoot mergeStableFields(
            CondominoRoot target,
            String condominioRootId,
            LegacyStableFields stableFields) {
        boolean changed = false;
        if (!condominioRootId.equals(target.getCondominioRootId())) {
            target.setCondominioRootId(condominioRootId);
            changed = true;
        }
        if (isBlank(target.getNome()) && stableFields.nome() != null) {
            target.setNome(stableFields.nome());
            changed = true;
        }
        if (isBlank(target.getCognome()) && stableFields.cognome() != null) {
            target.setCognome(stableFields.cognome());
            changed = true;
        }
        if (isBlank(target.getEmail()) && stableFields.email() != null) {
            target.setEmail(stableFields.email());
            changed = true;
        }
        if (isBlank(target.getCellulare()) && stableFields.cellulare() != null) {
            target.setCellulare(stableFields.cellulare());
            changed = true;
        }
        if (isBlank(target.getKeycloakUserId()) && stableFields.keycloakUserId() != null) {
            target.setKeycloakUserId(stableFields.keycloakUserId());
            changed = true;
        }
        if (isBlank(target.getKeycloakUsername()) && stableFields.keycloakUsername() != null) {
            target.setKeycloakUsername(stableFields.keycloakUsername());
            changed = true;
        }
        if (isBlank(target.getAppRole()) && stableFields.appRole() != null) {
            target.setAppRole(stableFields.appRole());
            changed = true;
        }
        if (target.getAppEnabled() == null && stableFields.appEnabled() != null) {
            target.setAppEnabled(stableFields.appEnabled());
            changed = true;
        }
        if (changed) {
            target.setUpdatedAt(Instant.now());
            return condominoRootRepository.save(target);
        }
        return target;
    }

    private void applyStableFields(CondominoRoot target, LegacyStableFields stableFields) {
        target.setNome(stableFields.nome());
        target.setCognome(stableFields.cognome());
        target.setEmail(stableFields.email());
        target.setCellulare(stableFields.cellulare());
        target.setKeycloakUserId(stableFields.keycloakUserId());
        target.setKeycloakUsername(stableFields.keycloakUsername());
        target.setAppRole(stableFields.appRole());
        target.setAppEnabled(stableFields.appEnabled());
    }

    private LegacyStableFields readLegacyStableFields(Document rawPosition) {
        return new LegacyStableFields(
                normalizeBlank(readString(rawPosition, "nome")),
                normalizeBlank(readString(rawPosition, "cognome")),
                normalizeEmail(readString(rawPosition, "email")),
                normalizeBlank(readString(rawPosition, "cellulare")),
                normalizeBlank(readString(rawPosition, "keycloakUserId")),
                normalizeBlank(readString(rawPosition, "keycloakUsername")),
                normalizeRole(readString(rawPosition, "appRole")),
                readBoolean(rawPosition, "appEnabled"));
    }

    private boolean hasAnno(Document rawPosition) {
        return rawPosition.containsKey("anno") && rawPosition.get("anno") != null;
    }

    /**
     * Le posizioni esercizio tengono uno snapshot di lettura dell'anagrafica
     * stabile. Qui lo riallineiamo dal source of truth `condomino_root`.
     */
    private boolean syncPositionSnapshots(Document rawPosition, Update update, CondominoRoot stableRoot) {
        boolean changed = false;
        changed |= syncPositionStringField(rawPosition, update, "nome", normalizeBlank(stableRoot.getNome()));
        changed |= syncPositionStringField(rawPosition, update, "cognome", normalizeBlank(stableRoot.getCognome()));
        changed |= syncPositionStringField(rawPosition, update, "email", normalizeEmail(stableRoot.getEmail()));
        changed |= syncPositionStringField(rawPosition, update, "cellulare", normalizeBlank(stableRoot.getCellulare()));
        changed |= syncPositionStringField(rawPosition, update, "keycloakUserId", normalizeBlank(stableRoot.getKeycloakUserId()));
        changed |= syncPositionStringField(rawPosition, update, "keycloakUsername", normalizeBlank(stableRoot.getKeycloakUsername()));
        changed |= syncPositionStringField(rawPosition, update, "appRole", normalizeRole(stableRoot.getAppRole()));
        changed |= syncPositionBooleanField(rawPosition, update, "appEnabled", stableRoot.getAppEnabled());
        changed |= syncPositionInstantField(
                rawPosition,
                update,
                "snapshotUpdatedAt",
                stableRoot.getUpdatedAt() == null ? Instant.now() : stableRoot.getUpdatedAt());
        return changed;
    }

    private boolean syncPositionStringField(Document rawPosition, Update update, String field, String expectedValue) {
        String currentValue = normalizeRawSnapshotString(field, readString(rawPosition, field));
        if (expectedValue == null) {
            if (rawPosition.containsKey(field)) {
                update.unset(field);
                return true;
            }
            return false;
        }
        if (!expectedValue.equals(currentValue)) {
            update.set(field, expectedValue);
            return true;
        }
        return false;
    }

    private boolean syncPositionBooleanField(Document rawPosition, Update update, String field, Boolean expectedValue) {
        Boolean normalizedExpected = expectedValue == null ? Boolean.FALSE : expectedValue;
        Boolean currentValue = readBoolean(rawPosition, field);
        if (!rawPosition.containsKey(field) || currentValue == null || !normalizedExpected.equals(currentValue)) {
            update.set(field, normalizedExpected);
            return true;
        }
        return false;
    }

    private boolean syncPositionInstantField(Document rawPosition, Update update, String field, Instant expectedValue) {
        Object rawValue = rawPosition.get(field);
        Instant currentValue = null;
        if (rawValue instanceof Instant instantValue) {
            currentValue = instantValue;
        } else if (rawValue instanceof java.util.Date dateValue) {
            currentValue = dateValue.toInstant();
        }
        if (!rawPosition.containsKey(field) || currentValue == null || !expectedValue.equals(currentValue)) {
            update.set(field, expectedValue);
            return true;
        }
        return false;
    }

    private void cacheStableRoot(Map<String, CondominoRoot> cache, CondominoRoot root) {
        String byId = cacheKeyById(root.getId());
        if (byId != null) {
            cache.put(byId, root);
        }
        String byEmail = cacheKeyByEmail(root.getCondominioRootId(), root.getEmail());
        if (byEmail != null) {
            cache.put(byEmail, root);
        }
        String byKeycloak = cacheKeyByKeycloak(root.getCondominioRootId(), root.getKeycloakUserId());
        if (byKeycloak != null) {
            cache.put(byKeycloak, root);
        }
    }

    private String cacheKeyById(String rootId) {
        return rootId == null ? null : "id::" + rootId;
    }

    private String cacheKeyByEmail(String condominioRootId, String email) {
        return condominioRootId == null || email == null ? null : "email::" + condominioRootId + "::" + email;
    }

    private String cacheKeyByKeycloak(String condominioRootId, String keycloakUserId) {
        return condominioRootId == null || keycloakUserId == null
                ? null
                : "keycloak::" + condominioRootId + "::" + keycloakUserId;
    }

    private String readString(Document rawPosition, String key) {
        Object value = rawPosition.get(key);
        return value == null ? null : String.valueOf(value);
    }

    private boolean normalizeOptionalStringField(
            Document source,
            Update update,
            String field) {
        String current = readString(source, field);
        if (current == null) {
            return false;
        }
        String normalized = switch (field) {
            case "email" -> normalizeEmail(current);
            case "appRole" -> normalizeRole(current);
            default -> normalizeBlank(current);
        };
        if (normalized == null) {
            update.unset(field);
            return true;
        }
        if (!normalized.equals(current)) {
            update.set(field, normalized);
            return true;
        }
        return false;
    }

    private String normalizeRawSnapshotString(String field, String current) {
        return switch (field) {
            case "email" -> normalizeEmail(current);
            case "appRole" -> normalizeRole(current);
            default -> normalizeBlank(current);
        };
    }

    private Boolean readBoolean(Document rawPosition, String key) {
        Object value = rawPosition.get(key);
        if (value == null) {
            return null;
        }
        if (value instanceof Boolean boolValue) {
            return boolValue;
        }
        return Boolean.parseBoolean(String.valueOf(value));
    }

    private String normalizeEmail(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim().toLowerCase();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String normalizeBlank(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String normalizeRole(String value) {
        String normalized = normalizeBlank(value);
        return normalized == null ? null : normalized.toLowerCase();
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private Instant toStartOfYear(Long anno) {
        long resolvedYear = (anno == null || anno < 1900L || anno > 2100L) ? LocalDate.now().getYear() : anno;
        return LocalDate.of((int) resolvedYear, 1, 1).atStartOfDay().toInstant(ZoneOffset.UTC);
    }

    private Instant toEndOfYear(Long anno) {
        long resolvedYear = (anno == null || anno < 1900L || anno > 2100L) ? LocalDate.now().getYear() : anno;
        return LocalDate.of((int) resolvedYear, 12, 31)
                .plusDays(1)
                .atStartOfDay()
                .minusNanos(1)
                .toInstant(ZoneOffset.UTC);
    }

    private record LegacyStableFields(
            String nome,
            String cognome,
            String email,
            String cellulare,
            String keycloakUserId,
            String keycloakUsername,
            String appRole,
            Boolean appEnabled) {
    }

    private record ResolutionResult(CondominoRoot root, boolean created) {
    }
}
