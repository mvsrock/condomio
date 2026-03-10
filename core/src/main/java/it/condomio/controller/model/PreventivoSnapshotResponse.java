package it.condomio.controller.model;

import java.time.Instant;
import java.util.List;

import it.condomio.document.Condominio;
import lombok.Data;

/**
 * Snapshot completo preventivo/consuntivo per esercizio selezionato.
 */
@Data
public class PreventivoSnapshotResponse {
    private String idCondominio;
    private Long anno;
    private String gestioneCodice;
    private String gestioneLabel;
    private Condominio.EsercizioStato statoEsercizio;
    private Instant updatedAt;
    private Double totalePreventivo;
    private Double totaleConsuntivo;
    private Double totaleDelta;
    private List<Row> rows;

    @Data
    public static class Row {
        private String codiceSpesa;
        private String codiceTabella;
        private String descrizioneTabella;
        private Double preventivo;
        private Double consuntivo;
        private Double delta;
    }
}

