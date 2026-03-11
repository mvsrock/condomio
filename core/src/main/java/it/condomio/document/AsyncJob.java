package it.condomio.document;

import java.time.Instant;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.CompoundIndexes;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

/**
 * Job asincrono persistito su Mongo.
 *
 * Use-case attuali:
 * - export report pesanti (PDF/XLSX)
 * - operazioni massive morosita' (solleciti automatici)
 *
 * Il documento e' tenant-aware via `idCondominio` e isolato per utente
 * richiedente via `requesterKeycloakUserId`.
 */
@Data
@Document(collection = "async_job")
@CompoundIndexes({
    @CompoundIndex(name = "job_requester_created_idx", def = "{'requesterKeycloakUserId':1,'createdAt':-1}"),
    @CompoundIndex(name = "job_condominio_created_idx", def = "{'idCondominio':1,'createdAt':-1}")
})
public class AsyncJob {

    public enum Type {
        REPORT_EXPORT,
        MOROSITA_AUTO_SOLLECITI
    }

    public enum Status {
        QUEUED,
        RUNNING,
        DONE,
        FAILED
    }

    @Id
    private String id;

    @Version
    private Integer version;

    @Indexed
    private String requesterKeycloakUserId;
    @Indexed
    private String idCondominio;

    private Type type;
    private Status status;

    private Instant createdAt;
    private Instant startedAt;
    private Instant finishedAt;

    private String inputFormat;
    private String inputCondominoId;
    private Integer inputMinDaysOverdue;

    private String resultFileObjectId;
    private String resultFileName;
    private String resultContentType;
    private Long resultSizeBytes;
    private Integer resultCount;

    private String message;
    private String errorCode;
}

