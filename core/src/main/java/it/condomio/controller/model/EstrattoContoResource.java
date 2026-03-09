package it.condomio.controller.model;

import java.util.List;

import lombok.Data;

/**
 * Estratto conto operativo della posizione:
 * - dovuto da rate
 * - versato
 * - scoperto residuo sulle rate
 */
@Data
public class EstrattoContoResource {
    private String condominoId;
    private String idCondominio;
    private double totaleRate;
    private double totaleIncassatoRate;
    private double scopertoRate;
    private double totaleVersamenti;
    private List<RataDettaglio> rate;

    @Data
    public static class RataDettaglio {
        private String id;
        private String codice;
        private String descrizione;
        private String tipo;
        private String stato;
        private String scadenza;
        private double importo;
        private double incassato;
        private double scoperto;
    }
}
