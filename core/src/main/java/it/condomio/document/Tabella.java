package it.condomio.document;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

@Data
@Document(collection = "tabelle")
public class Tabella {
    @Id
    private String id;
    @Version
    private Integer version;
    @Indexed(unique = true)
    private String codice;
    private String descrizione;
    @Indexed(unique = false)
    private String idCondominio;
}
