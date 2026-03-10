package it.condomio.controller.model;

import java.time.Instant;

import it.condomio.document.Condomino;
import lombok.Data;

/**
 * Riga operativa vista morosita' per esercizio.
 */
@Data
public class MorositaItemResource {
    private String condominoId;
    private String idCondominio;
    private String nominativo;
    private Condomino.PosizioneStato statoPosizione;
    private Condomino.MorositaStato praticaStato;
    private Double debitoTotale;
    private Double debitoScaduto;
    private Double debitoNonScaduto;
    private Double scaduto0_30;
    private Double scaduto31_60;
    private Double scaduto61_90;
    private Double scadutoOver90;
    private Integer massimoRitardoGiorni;
    private Integer numeroSolleciti;
    private Instant ultimoSollecitoAt;
}

