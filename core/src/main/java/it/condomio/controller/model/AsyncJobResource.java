package it.condomio.controller.model;

import java.time.Instant;

import it.condomio.document.AsyncJob;
import lombok.Data;

/**
 * Resource read-only di un job asincrono.
 */
@Data
public class AsyncJobResource {
    private String id;
    private String idCondominio;
    private AsyncJob.Type type;
    private AsyncJob.Status status;
    private Instant createdAt;
    private Instant startedAt;
    private Instant finishedAt;

    private String inputFormat;
    private String inputCondominoId;
    private Integer inputMinDaysOverdue;

    private String resultFileName;
    private String resultContentType;
    private Long resultSizeBytes;
    private Integer resultCount;

    private String message;
    private String errorCode;
    private boolean resultDownloadAvailable;
}

