package it.condomio.controller.model;

import lombok.Data;

@Data
public class UnitaImmobiliareResource {
    private String id;
    private Integer version;
    private String condominioRootId;
    private String codice;
    private String scala;
    private String interno;
    private String subalterno;
    private String destinazioneUso;
    private Double metriQuadri;
}
