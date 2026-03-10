package it.condomio.document;

import java.time.Instant;
import java.util.List;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

/**
 * Snapshot di preventivo per singolo esercizio.
 *
 * Scelta di modellazione:
 * - id documento == id esercizio (`idCondominio`)
 * - una sola istanza preventivo per esercizio
 * - righe granulari per coppia codice spesa + tabella
 */
@Data
@Document(collection = "preventivo")
public class Preventivo {

    /** `_id` Mongo: coincide con l'id dell'esercizio. */
    @Id
    private String idCondominio;

    @Version
    private Integer version;

    /** Timestamp ultimo salvataggio preventivo. */
    private Instant updatedAt;

    /** Righe preventivo granulari per confronto con il consuntivo. */
    private List<Riga> righe;

    @Data
    public static class Riga {
        private String codiceSpesa;
        private String codiceTabella;
        private String descrizioneTabella;
        private Double importoPreventivo;
    }
}

