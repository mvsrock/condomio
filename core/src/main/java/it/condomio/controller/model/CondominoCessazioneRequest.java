package it.condomio.controller.model;

import java.time.Instant;

import lombok.Data;

/**
 * Richiesta di cessazione della sola posizione esercizio.
 *
 * Uso:
 * - errore di appartenenza all'esercizio
 * - uscita dal condominio senza subentro immediato
 */
@Data
public class CondominoCessazioneRequest {
    private Instant dataCessazione;
    private String motivo;
}
