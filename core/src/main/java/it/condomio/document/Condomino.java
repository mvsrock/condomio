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
    @CompoundIndex(name = "nome_cognome_idx", def = "{'nome' : 1, 'cognome': 1}", unique = true),
    @CompoundIndex(name = "anno_email_idx", def = "{'anno' : 1, 'email': 1}", unique = true)
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
    @Indexed(unique = true)
    private String email;
    private String cellulare;
    private String scala;
    private Long interno;
    private Long anno;
    private Config config;
    private List<Versamento> versamenti;
    private Double residuo;

    @Data
    public static class Config {
        private List<TabellaConfig> tabelle;
        private List<Rata> rate;
        
        @Data
        public static class TabellaConfig {
            private Tabella tabella;
            private Double numeratore;
            private Double denominatore;
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
        	private String codice;         // Codice della tabella (spostato al livello superiore)
            private String descrizione;
            private Double importo;
        }
    }
}
