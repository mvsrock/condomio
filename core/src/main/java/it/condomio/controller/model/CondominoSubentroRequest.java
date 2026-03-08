package it.condomio.controller.model;

import java.time.Instant;

import lombok.Data;

/**
 * Richiesta di subentro sullo stesso esercizio.
 *
 * Il precedente condomino viene cessato alla data richiesta e viene creata una
 * nuova posizione, di norma sulla stessa unita', con quote ereditate.
 */
@Data
public class CondominoSubentroRequest {
    private Instant dataSubentro;
    private Boolean carryOverSaldo;
    private CondominoResource nuovoCondomino;
}
