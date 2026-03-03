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
    @Id
    private String id;
    @Version
    private Integer version;
    @Indexed(unique = false)
    private String idCondominio;
    @Indexed
    private String codiceSpesa;
    private String descrizione;
    private Double importo;
    private Instant date;
    private Instant insertedAt;
    private List<RipartizioneTabella> ripartizioneTabelle;

    @Data
    public static class RipartizioneTabella {
    	@Indexed(unique = false)
    	private String codice;
        private String descrizione;
        private Double importo;
    }
}


