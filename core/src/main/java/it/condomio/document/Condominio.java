package it.condomio.document;

import java.time.Instant;
import java.util.List;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

@Data
@Document(collection = "condominio")
public class Condominio {
    @Id
    private String id;
    @Version
    private Integer version;

    /**
     * Riferimento al condominio "stabile" (root/master document).
     *
     * Il documento corrente rappresenta l'esercizio annuale del root.
     */
    private String condominioRootId;
    private String label;
    private Long anno;
    private Instant dataInizio;
    private Instant dataFine;
    private EsercizioStato stato;
    private String adminKeycloakUserId;
    private List<ConfigurazioneSpesa> configurazioniSpesa;
    /**
     * Saldo contabile di partenza del condominio (anno specifico).
     * Viene sommato al saldo aggregato dei condomini nel ricalcolo residui.
     */
    private Double saldoIniziale;
    private Double residuo;

    public enum EsercizioStato {
        OPEN,
        CLOSED
    }

    @Data
    public static class ConfigurazioneSpesa {
        private String codice;
        private List<TabellaPercentuale> tabelle;
        
        @Data
        public static class TabellaPercentuale {
        	private String codice;
            private String descrizione;
            private Integer percentuale;
        }
    }
}


