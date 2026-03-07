package it.condomio.document;

import java.time.Instant;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

/**
 * Identita' stabile del condomino all'interno di un condominio root.
 *
 * Questa collection contiene solo i dati anagrafici e di accesso applicativo
 * che non devono essere duplicati a ogni apertura di esercizio.
 */
@Data
@Document(collection = "condomino_root")
public class CondominoRoot {
    @Id
    private String id;

    @Version
    private Integer version;

    /** Condominio reale a cui appartiene l'anagrafica del condomino. */
    private String condominioRootId;

    private String nome;
    private String cognome;
    private String email;
    private String cellulare;

    /** Collegamento stabile al profilo applicativo/Keycloak del condomino. */
    private String keycloakUserId;
    private String keycloakUsername;
    private String appRole;
    private Boolean appEnabled;

    private Instant createdAt;
    private Instant updatedAt;
}
