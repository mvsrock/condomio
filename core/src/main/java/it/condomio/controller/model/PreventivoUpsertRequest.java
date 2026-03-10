package it.condomio.controller.model;

import java.util.List;

import lombok.Data;

/**
 * Payload di salvataggio preventivo esercizio.
 *
 * Il client invia la fotografia completa delle righe che vuole mantenere.
 */
@Data
public class PreventivoUpsertRequest {
    private List<Row> rows;

    @Data
    public static class Row {
        private String codiceSpesa;
        private String codiceTabella;
        private String descrizioneTabella;
        private Double preventivo;
    }
}

