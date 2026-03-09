package it.condomio.document;

import java.time.Instant;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.CompoundIndexes;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

/**
 * Unita' immobiliare stabile del condominio root.
 *
 * Rappresenta l'entita' fisica (scala/interno/subalterno) condivisa tra esercizi.
 */
@Data
@Document(collection = "unita_immobiliare")
@CompoundIndexes({
    @CompoundIndex(
            name = "root_scala_interno_uidx",
            def = "{'condominioRootId': 1, 'scala': 1, 'interno': 1}",
            unique = true),
    @CompoundIndex(
            name = "root_codice_uidx",
            def = "{'condominioRootId': 1, 'codice': 1}",
            unique = true)
})
public class UnitaImmobiliare {
    @Id
    private String id;
    @Version
    private Integer version;

    private String condominioRootId;
    private String codice;
    private String scala;
    private String interno;
    private String subalterno;
    private String destinazioneUso;
    private Double metriQuadri;
    private Instant createdAt;
    private Instant updatedAt;
}
