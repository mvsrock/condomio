package it.condomio.controller.model;

import java.time.Instant;

import lombok.Data;

/**
 * Resource read-only di un job asincrono.
 *
 * Nota:
 * - nel core viene usata come DTO di facciata verso operations-service.
 * - non dipende dal documento Mongo interno del servizio owner dei job.
 */
@Data
public class AsyncJobResource {
    public enum Type {
        REPORT_EXPORT,
        MOROSITA_AUTO_SOLLECITI,
        MOROSITA_REMINDER_SCADENZE
    }

    public enum Status {
        QUEUED,
        RUNNING,
        DONE,
        FAILED
    }

    private String id;
    private String idCondominio;
    private Type type;
    private Status status;
    private Instant createdAt;
    private Instant startedAt;
    private Instant finishedAt;

    private String inputFormat;
    private String inputCondominoId;
    private Integer inputMinDaysOverdue;
    private Integer inputMaxDaysAhead;

    private String resultFileName;
    private String resultContentType;
    private Long resultSizeBytes;
    private Integer resultCount;

    private String message;
    private String errorCode;
    private boolean resultDownloadAvailable;
}
