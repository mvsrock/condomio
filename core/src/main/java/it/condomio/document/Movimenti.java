package it.condomio.document;

import java.time.Instant;
import java.util.List;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

@Data
@Document(collection = "movimenti")
public class Movimenti {
    /**
     * Tipo di riparto del movimento:
     * - CONDOMINIALE: usa configurazioniSpesa + tabelle + millesimi.
     * - INDIVIDUALE: usa direttamente ripartizioneCondomini passata dal client.
     */
    public enum RipartoTipo {
        CONDOMINIALE,
        INDIVIDUALE
    }

    @Id
    private String id;
    @Version
    private Integer version;
    @Indexed(unique = false)
    private String idCondominio;
    @Indexed
    private String codiceSpesa;
    private RipartoTipo tipoRiparto;
    private String descrizione;
    private Double importo;
    private Instant date;
    private Instant insertedAt;
    private List<RipartizioneTabella> ripartizioneTabelle;
    private List<RipartizioneCondomino> ripartizioneCondomini;

    @Data
    public static class RipartizioneTabella {
    	@Indexed(unique = false)
    	private String codice;
        private String descrizione;
        private Double importo;
    }

    @Data
    public static class RipartizioneCondomino {
        @Indexed(unique = false)
        private String idCondomino;
        private String nominativo;
        private Double importo;
    }
}


