package it.condomio.controller.model;

import java.time.Instant;
import java.util.List;

import it.condomio.document.Condominio;
import lombok.Data;

/**
 * Snapshot reportistico completo dell'esercizio.
 *
 * Include in un payload unico le viste operative richieste in fase 6:
 * - situazione contabile
 * - consuntivo/budget
 * - riparto per tabella
 * - morosita'
 * - estratti conto posizione
 */
@Data
public class ReportSnapshotResponse {
    private String idCondominio;
    private String label;
    private Long anno;
    private String gestioneCodice;
    private String gestioneLabel;
    private Condominio.EsercizioStato statoEsercizio;
    private Instant generatedAt;

    private SituazioneContabile situazioneContabile;
    private List<PreventivoSnapshotResponse.Row> consuntivoRows;
    private List<RipartoTabellaRow> ripartoPerTabella;
    private List<MorositaItemResource> morositaItems;
    private List<EstrattoContoSummaryRow> estrattiConto;
    private List<QuotaCondominoTabellaRow> quotaCondominoTabelle;

    @Data
    public static class SituazioneContabile {
        private Double saldoInizialeCondominio;
        private Double residuoCondominio;
        private Double totaleSpeseRegistrate;
        private Double totaleVersamenti;
        private Double totaleRateEmesse;
        private Double totaleRateIncassate;
        private Double totaleScopertoRate;
        private Integer posizioniAttive;
        private Integer posizioniCessate;
    }

    @Data
    public static class RipartoTabellaRow {
        private String codiceSpesa;
        private String codiceTabella;
        private String descrizioneTabella;
        private Double importoTotale;
    }

    @Data
    public static class EstrattoContoSummaryRow {
        private String condominoId;
        private String nominativo;
        private String statoPosizione;
        private Double saldoIniziale;
        private Double residuo;
        private Double totaleRate;
        private Double totaleIncassatoRate;
        private Double scopertoRate;
        private Double totaleVersamenti;
    }

    /**
     * Dettaglio quota per tabella del condomino selezionato.
     *
     * Serve ad allineare report/export con la vista "Dettaglio + Tabelle"
     * usata in UI (es. 20 + 50 sulla stessa spesa).
     */
    @Data
    public static class QuotaCondominoTabellaRow {
        private String movimentoId;
        private Instant dataMovimento;
        private String codiceSpesa;
        private String descrizioneMovimento;
        private String codiceTabella;
        private String descrizioneTabella;
        private Double importoTabella;
        private Double numeratore;
        private Double denominatore;
        private Double quotaCondominoTabella;
        private Double quotaCondominoMovimento;
    }
}
