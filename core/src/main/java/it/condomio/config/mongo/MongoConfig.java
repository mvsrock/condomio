package it.condomio.config.mongo;

import org.bson.Document;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.MongoTransactionManager;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.SimpleMongoClientDatabaseFactory;

@Configuration
@PropertySource("classpath:mongo-config.properties")
public class MongoConfig {
    private static final Logger LOG = LoggerFactory.getLogger(MongoConfig.class);

	@Bean
    MongoDatabaseFactory mongoDatabaseFactory(Environment env) {
        final String uri = env.getRequiredProperty("spring.data.mongodb.uri");
        return new SimpleMongoClientDatabaseFactory(uri);
    }

	@Bean
    MongoTransactionManager transactionManager(MongoDatabaseFactory dbFactory) {
        return new MongoTransactionManager(dbFactory);
    }

    /**
     * Migrazione indici legacy:
     * - rimuove vecchi indici unici globali che confliggono con il modello multi-condominio
     * - mantiene startup idempotente (safe su riavvii multipli)
     */
    @Bean
    ApplicationRunner mongoIndexMigrationRunner(MongoTemplate mongoTemplate) {
        return args -> {
            dropLegacyUniqueIndexIfPresent(
                    mongoTemplate,
                    "condomino",
                    "email",
                    new Document("email", 1));
            dropLegacyUniqueIndexIfPresent(
                    mongoTemplate,
                    "tabelle",
                    "codice",
                    new Document("codice", 1));
            dropIndexByNameIfPresent(mongoTemplate, "condomino", "anno_email_idx");
        };
    }

    /**
     * Probe startup per capire se le transazioni Mongo multi-documento sono realmente disponibili.
     * Nota: in standalone (senza replica set) @Transactional non garantisce ACID multi-documento.
     */
    @Bean
    ApplicationRunner mongoTransactionCapabilityProbe(MongoTemplate mongoTemplate) {
        return args -> {
            try {
                final Document hello = mongoTemplate.executeCommand(new Document("hello", 1));
                final String setName = hello.getString("setName");
                if (setName == null || setName.isBlank()) {
                    LOG.warn(
                            "[MONGO_TX_PROBE] Replica set NON rilevato: transazioni multi-documento non garantite. " +
                            "Configura Mongo come replica set anche in dev.");
                } else {
                    LOG.info("[MONGO_TX_PROBE] Replica set attivo: {}", setName);
                }
            } catch (Exception e) {
                LOG.warn("[MONGO_TX_PROBE] Impossibile verificare capabilities transazionali: {}", e.getMessage());
            }
        };
    }

    private void dropLegacyUniqueIndexIfPresent(
            MongoTemplate mongoTemplate,
            String collection,
            String indexName,
            Document expectedKey) {
        for (Document idx : mongoTemplate.getCollection(collection).listIndexes()) {
            final String currentName = idx.getString("name");
            final boolean unique = Boolean.TRUE.equals(idx.getBoolean("unique", false));
            final Document key = idx.get("key", Document.class);
            if (indexName.equals(currentName) && unique && expectedKey.equals(key)) {
                LOG.warn("Dropping legacy unique index {} on {}", indexName, collection);
                mongoTemplate.getCollection(collection).dropIndex(indexName);
                return;
            }
        }
    }

    private void dropIndexByNameIfPresent(
            MongoTemplate mongoTemplate,
            String collection,
            String indexName) {
        for (Document idx : mongoTemplate.getCollection(collection).listIndexes()) {
            final String currentName = idx.getString("name");
            if (indexName.equals(currentName)) {
                LOG.warn("Dropping legacy index {} on {}", indexName, collection);
                mongoTemplate.getCollection(collection).dropIndex(indexName);
                return;
            }
        }
    }
}
