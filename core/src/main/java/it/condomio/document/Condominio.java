package it.condomio.document;

import java.util.List;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.CompoundIndexes;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

@Data
@Document(collection = "condominio")
@CompoundIndexes({
    @CompoundIndex(name = "anno_label_idx", def = "{'anno' : 1, 'label': 1}", unique = true)
})
public class Condominio {
    @Id
    private String id;
    @Version
    private Integer version;

    private String label;
    private Long anno;
    @Indexed
    private String adminKeycloakUserId;
    private List<ConfigurazioneSpesa> configurazioniSpesa;
    private Double residuo;

    @Data
    public static class ConfigurazioneSpesa {
        private String codice;
        private List<TabellaPercentuale> tabelle;
        
        @Data
        public static class TabellaPercentuale {
        	private String codice;
            private String descrizione;
            private Integer percentuale;
        }
    }
}


