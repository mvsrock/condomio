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
    // Non univoco: piu' persone possono avere stesso nome/cognome.
    @CompoundIndex(name = "nome_cognome_idx", def = "{'nome' : 1, 'cognome': 1}"),
    // Vincolo business: email unica per condominio (non globale).
    @CompoundIndex(name = "condominio_email_idx", def = "{'idCondominio' : 1, 'email': 1}", unique = true)
})
public class Condomino {
    @Id
    private String id;
    @Version
    private Integer version;
    private String nome;
    private String cognome;
    @Indexed(unique = false)
    private String idCondominio;
    @Indexed(name = "email_idx", unique = false)
    private String email;
    private String cellulare;
    private String scala;
    private Long interno;
    private Long anno;

    // Legame applicativo con Keycloak (utente e stato abilitazione accesso app).
    @Indexed(unique = false)
    private String keycloakUserId;
    private String keycloakUsername;
    private String appRole;
    private Boolean appEnabled;

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
