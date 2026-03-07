package it.condomio.document;

import java.time.Instant;
import java.util.List;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.CompoundIndexes;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

@Data
@Document(collection = "condomino")
@CompoundIndexes({
    /**
     * Una stessa anagrafica stabile puo' comparire una sola volta per esercizio.
     * Questo indice evita posizioni duplicate sullo stesso esercizio.
     */
    @CompoundIndex(name = "exercise_root_uidx", def = "{'idCondominio' : 1, 'condominoRootId': 1}", unique = true),
    /**
     * Read path principale per liste e paginazione ordinata per nominativo.
     * Lo snapshot su posizione evita lookup o merge applicativi per l'anagrafica.
     */
    @CompoundIndex(name = "exercise_name_idx", def = "{'idCondominio' : 1, 'cognome': 1, 'nome': 1}"),
    /**
     * Supporta accesso tenant diretto da utente applicativo alle posizioni visibili.
     */
    @CompoundIndex(name = "keycloak_exercise_idx", def = "{'keycloakUserId' : 1, 'idCondominio': 1}"),
    /**
     * Indice di join stabile: dato un condomino root recuperiamo rapidamente tutte
     * le sue posizioni sui diversi esercizi.
     */
    @CompoundIndex(name = "root_exercise_idx", def = "{'condominoRootId' : 1, 'idCondominio': 1}")
})
public class Condomino {
    @Id
    private String id;
    @Version
    private Integer version;

    /**
     * Riferimento all'anagrafica stabile del condomino.
     * La collection `condomino` rappresenta solo la posizione nel singolo esercizio.
     */
    @Indexed(unique = false)
    private String condominoRootId;

    @Indexed(unique = false)
    private String idCondominio;
    /**
     * Snapshot denormalizzato dell'anagrafica stabile.
     *
     * Source of truth:
     * - `condomino_root`
     *
     * Read model:
     * - `condomino`
     *
     * Questo consente query calde su anagrafica, ordinamento e tenant visibility
     * senza join/lookup lato Mongo o merge applicativi a ogni richiesta.
     */
    private String nome;
    private String cognome;
    private String email;
    private String cellulare;
    private String keycloakUserId;
    private String keycloakUsername;
    private String appRole;
    private Boolean appEnabled;
    /** Ultimo timestamp di sincronizzazione dello snapshot stabile sulla posizione. */
    private Instant snapshotUpdatedAt;
    private String scala;
    private Long interno;
    private Long anno;

    private Config config;
    private List<Versamento> versamenti;
    private Double saldoIniziale;
    private Double residuo;

    @Data
    public static class Config {
        private List<TabellaConfig> tabelle;
        private List<Rata> rate;

        @Data
        public static class TabellaConfig {
            // Non usare qui il tipo document `Tabella` (ha index unici):
            // nel documento annidato serve solo una reference leggera.
            private TabellaRef tabella;
            private Double numeratore;
            private Double denominatore;
        }

        @Data
        public static class TabellaRef {
            private String codice;
            private String descrizione;
        }

        @Data
        public static class Rata {
            @Indexed(unique = false)
            private String codice;
            private String descrizione;
            private List<Importo> importi;

            @Data
            public static class Importo {
                private String codice;
                private Double importo;
            }
        }
    }

    @Data
    public static class Versamento {
        /** Identificatore stabile per update/delete atomici del singolo versamento. */
        private String id;
        private String descrizione;
        private Double importo;
        private Instant date;
        private Instant insertedAt;
        private List<Ripartizione> ripartizioneTabelle;

        @Data
        public static class Ripartizione {
            @Indexed(unique = false)
            private String codice;
            private String descrizione;
            private Double importo;
        }
    }
}
