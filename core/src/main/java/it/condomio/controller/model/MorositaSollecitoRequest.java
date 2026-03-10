package it.condomio.controller.model;

import lombok.Data;

@Data
public class MorositaSollecitoRequest {
    private String canale;
    private String titolo;
    private String note;
    private Boolean automatico;
}

