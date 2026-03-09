package it.condomio.controller.model;

import java.time.Instant;
import java.util.List;

import it.condomio.document.Condomino;
import lombok.Data;

/**
 * Piano rate esercizio applicato in blocco alle posizioni attive.
 *
 * Strategia MVP:
 * - ogni template produce una rata per ciascun condomino attivo
 * - importoTotale viene ripartito in parti uguali con correzione centesimi
 */
@Data
public class RatePlanRequest {
    private List<Template> rate;

    @Data
    public static class Template {
        private String codice;
        private String descrizione;
        private CondominioTipo tipo;
        private Instant scadenza;
        private Double importoTotale;
    }

    public enum CondominioTipo {
        ORDINARIA,
        STRAORDINARIA;

        public Condomino.Config.Rata.Tipo toRateTipo() {
            return this == STRAORDINARIA
                    ? Condomino.Config.Rata.Tipo.STRAORDINARIA
                    : Condomino.Config.Rata.Tipo.ORDINARIA;
        }
    }
}
