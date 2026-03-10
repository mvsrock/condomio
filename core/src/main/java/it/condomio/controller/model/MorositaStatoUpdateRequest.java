package it.condomio.controller.model;

import it.condomio.document.Condomino;
import lombok.Data;

@Data
public class MorositaStatoUpdateRequest {
    private Condomino.MorositaStato stato;
}

