package it.condomio.controller.model;

import java.util.List;

import it.condomio.document.Condomino;
import lombok.Data;

/**
 * Resource flatten usata al bordo API.
 *
 * Espone in un unico payload:
 * - dati stabili del condomino (anagrafica, accesso applicativo)
 * - dati annuali della posizione nell'esercizio
 *
 * In questo modo il frontend mantiene un contratto semplice, mentre il backend
 * separa internamente anagrafica stabile e posizione per esercizio.
 */
@Data
public class CondominoResource {
    private String id;
    private Integer version;

    private String condominoRootId;
    private String nome;
    private String cognome;
    private String email;
    private String cellulare;

    private String idCondominio;
    private String scala;
    private Long interno;
    private Long anno;

    private String keycloakUserId;
    private String keycloakUsername;
    private String appRole;
    private Boolean appEnabled;

    private Condomino.Config config;
    private List<Condomino.Versamento> versamenti;
    private Double saldoIniziale;
    private Double residuo;
}
