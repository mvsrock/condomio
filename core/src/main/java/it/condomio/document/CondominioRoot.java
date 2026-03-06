package it.condomio.document;

import java.time.Instant;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

/**
 * Identita' stabile del condominio reale.
 *
 * Non contiene dati contabili annuali: quelli vivono negli esercizi collegati.
 */
@Data
@Document(collection = "condominio_root")
public class CondominioRoot {
    @Id
    private String id;
    @Version
    private Integer version;

    private String label;
    private String labelKey;
    private String adminKeycloakUserId;
    private Instant createdAt;
    private Instant updatedAt;
}
