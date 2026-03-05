package it.condomio.document;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.CompoundIndexes;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

@Data
@Document(collection = "tabelle")
@CompoundIndexes({
    @CompoundIndex(name = "condominio_codice_idx", def = "{'idCondominio': 1, 'codice': 1}", unique = true)
})
public class Tabella {
    @Id
    private String id;
    @Version
    private Integer version;
    @Indexed(name = "codice_idx", unique = false)
    private String codice;
    private String descrizione;
    @Indexed(unique = false)
    private String idCondominio;
}
