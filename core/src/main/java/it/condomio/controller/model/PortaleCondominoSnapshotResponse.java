package it.condomio.controller.model;

import java.time.Instant;
import java.util.List;

import it.condomio.document.Condomino;
import it.condomio.document.Condominio;
import lombok.Data;

/**
 * Snapshot self-service del portale condomino (Fase 7).
 *
 * Espone in un payload unico:
 * - contesto esercizio corrente
 * - posizione personale del condomino autenticato
 * - estratto conto (rate/versamenti)
 * - quota spese imputate
 * - documenti recenti consultabili
 */
@Data
public class PortaleCondominoSnapshotResponse {
    private String idCondominio;
    private String labelCondominio;
    private Long anno;
    private String gestioneCodice;
    private String gestioneLabel;
    private Condominio.EsercizioStato statoEsercizio;
    private Double residuoCondominio;
    private Instant generatedAt;

    private String condominoId;
    private String nominativo;
    private String appRole;
    private Condomino.PosizioneStato statoPosizione;
    private String scala;
    private String interno;
    private Double saldoInizialeCondomino;
    private Double residuoCondomino;

    private Double totaleRate;
    private Double totaleIncassatoRate;
    private Double scopertoRate;
    private Double totaleVersamenti;
    private List<EstrattoContoResource.RataDettaglio> rate;

    private List<VersamentoRow> versamenti;
    private List<MovimentoQuotaRow> movimenti;
    private List<DocumentoRow> documentiRecenti;

    @Data
    public static class VersamentoRow {
        private String id;
        private String descrizione;
        private String rataId;
        private Double importo;
        private Instant date;
        private Instant insertedAt;
    }

    @Data
    public static class MovimentoQuotaRow {
        private String movimentoId;
        private Instant date;
        private String codiceSpesa;
        private String descrizione;
        private Double importoTotale;
        private Double quotaCondomino;
    }

    @Data
    public static class DocumentoRow {
        private String documentoId;
        private String titolo;
        private String categoria;
        private String movimentoId;
        private Integer versionNumber;
        private Instant createdAt;
    }
}

