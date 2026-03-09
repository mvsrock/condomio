package it.condomio.controller.model;

import java.time.Instant;

import it.condomio.document.Condomino;
import lombok.Data;

/**
 * Riga timeline titolarita' di una unita' immobiliare.
 *
 * Espone solo i campi utili alla UI per leggere lo storico soggetti
 * che hanno occupato la stessa unita' nei vari esercizi.
 */
@Data
public class UnitaTitolaritaResource {
    private String condominoId;
    private String condominoRootId;
    private String idCondominio;
    private String nominativo;
    private Condomino.TitolaritaTipo titolaritaTipo;
    private Condomino.PosizioneStato statoPosizione;
    private Instant dataIngresso;
    private Instant dataUscita;
    private String motivoUscita;
    private Long annoEsercizio;
    private String gestioneCodice;
}

