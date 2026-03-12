package it.condomio.service;

import java.io.IOException;
import java.io.InputStream;
import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

import org.bson.Document;
import org.bson.types.ObjectId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.gridfs.GridFsOperations;
import org.springframework.data.mongodb.gridfs.GridFsTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import com.mongodb.client.gridfs.model.GridFSFile;

import io.micrometer.core.instrument.MeterRegistry;
import feign.FeignException;
import it.condomio.client.core.CoreOperationsClient;
import it.condomio.client.core.model.CoreAutomaticSollecitiRequest;
import it.condomio.client.core.model.CoreCountResponse;
import it.condomio.client.core.model.CoreReminderScadenzeRequest;
import it.condomio.client.core.model.CoreReportExportRequest;
import it.condomio.client.core.model.CoreReportExportResponse;
import it.condomio.config.properties.CoreInternalBridgeProperties;
import it.condomio.config.properties.JobAutomationProperties;
import it.condomio.controller.model.AsyncJobResource;
import it.condomio.document.AsyncJob;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.AsyncJobRepository;

/**
 * Orchestratore job asincroni di operations-service.
 *
 * Responsabilita':
 * - queue/stato/download job
 * - esecuzione in background via worker
 * - delega della business logic a core tramite endpoint interni signed.
 */
@Service
public class AsyncJobService {
    private static final Logger LOG = LoggerFactory.getLogger(AsyncJobService.class);

    public static final String REPORT_FORMAT_XLSX = "xlsx";
    public static final String REPORT_FORMAT_PDF = "pdf";

    private static final String CONTENT_TYPE_XLSX =
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    private static final String CONTENT_TYPE_PDF = "application/pdf";

    private final AsyncJobRepository asyncJobRepository;
    private final GridFsTemplate gridFsTemplate;
    private final GridFsOperations gridFsOperations;
    private final AsyncJobWorker asyncJobWorker;
    private final CoreOperationsClient coreOperationsClient;
    private final CoreInternalBridgeProperties coreInternalBridgeProperties;
    private final JobAutomationProperties jobAutomationProperties;
    private final MeterRegistry meterRegistry;

    public AsyncJobService(
            AsyncJobRepository asyncJobRepository,
            GridFsTemplate gridFsTemplate,
            GridFsOperations gridFsOperations,
            AsyncJobWorker asyncJobWorker,
            CoreOperationsClient coreOperationsClient,
            CoreInternalBridgeProperties coreInternalBridgeProperties,
            JobAutomationProperties jobAutomationProperties,
            MeterRegistry meterRegistry) {
        this.asyncJobRepository = asyncJobRepository;
        this.gridFsTemplate = gridFsTemplate;
        this.gridFsOperations = gridFsOperations;
        this.asyncJobWorker = asyncJobWorker;
        this.coreOperationsClient = coreOperationsClient;
        this.coreInternalBridgeProperties = coreInternalBridgeProperties;
        this.jobAutomationProperties = jobAutomationProperties;
        this.meterRegistry = meterRegistry;
    }

    public AsyncJobResource queueReportExport(
            String idCondominio,
            String format,
            String condominoId,
            String requesterKeycloakUserId) throws ApiException {
        final String exerciseId = requireNonBlank(idCondominio, "validation.required.job.idCondominio");
        final String normalizedFormat = normalizeReportFormat(format);
        final String normalizedCondominoId = normalize(condominoId);

        AsyncJob payload = new AsyncJob();
        payload.setRequesterKeycloakUserId(requesterKeycloakUserId);
        payload.setIdCondominio(exerciseId);
        payload.setType(AsyncJob.Type.REPORT_EXPORT);
        payload.setStatus(AsyncJob.Status.QUEUED);
        payload.setCreatedAt(Instant.now());
        payload.setInputFormat(normalizedFormat);
        payload.setInputCondominoId(normalizedCondominoId);
        payload.setMessage("Job accodato");

        AsyncJob saved = asyncJobRepository.save(payload);
        recordQueued(saved);
        asyncJobWorker.process(saved.getId());
        return toResource(saved);
    }

    public AsyncJobResource queueAutomaticSolleciti(
            String idCondominio,
            Integer minDaysOverdue,
            String requesterKeycloakUserId) throws ApiException {
        final String exerciseId = requireNonBlank(idCondominio, "validation.required.job.idCondominio");
        final int normalizedMinDays = normalizeMinDays(minDaysOverdue);

        AsyncJob payload = new AsyncJob();
        payload.setRequesterKeycloakUserId(requesterKeycloakUserId);
        payload.setIdCondominio(exerciseId);
        payload.setType(AsyncJob.Type.MOROSITA_AUTO_SOLLECITI);
        payload.setStatus(AsyncJob.Status.QUEUED);
        payload.setCreatedAt(Instant.now());
        payload.setInputMinDaysOverdue(normalizedMinDays);
        payload.setMessage("Job accodato");

        AsyncJob saved = asyncJobRepository.save(payload);
        recordQueued(saved);
        asyncJobWorker.process(saved.getId());
        return toResource(saved);
    }

    public AsyncJobResource queueUpcomingReminder(
            String idCondominio,
            Integer maxDaysAhead,
            String requesterKeycloakUserId) throws ApiException {
        final String exerciseId = requireNonBlank(idCondominio, "validation.required.job.idCondominio");
        final int normalizedMaxDaysAhead = normalizeMaxDaysAhead(maxDaysAhead);

        AsyncJob payload = new AsyncJob();
        payload.setRequesterKeycloakUserId(requesterKeycloakUserId);
        payload.setIdCondominio(exerciseId);
        payload.setType(AsyncJob.Type.MOROSITA_REMINDER_SCADENZE);
        payload.setStatus(AsyncJob.Status.QUEUED);
        payload.setCreatedAt(Instant.now());
        payload.setInputMaxDaysAhead(normalizedMaxDaysAhead);
        payload.setMessage("Job accodato");

        AsyncJob saved = asyncJobRepository.save(payload);
        recordQueued(saved);
        asyncJobWorker.process(saved.getId());
        return toResource(saved);
    }

    public AsyncJobResource getJob(String jobId, String requesterKeycloakUserId) throws ApiException {
        return toResource(loadOwnedJob(jobId, requesterKeycloakUserId));
    }

    public List<AsyncJobResource> listMyJobs(String requesterKeycloakUserId, Integer limit) throws ApiException {
        final int normalizedLimit = normalizeLimit(limit);
        return asyncJobRepository.findByRequesterKeycloakUserIdOrderByCreatedAtDesc(
                        requesterKeycloakUserId,
                        PageRequest.of(0, normalizedLimit))
                .stream()
                .map(this::toResource)
                .toList();
    }

    public JobDownloadPayload downloadJobResult(String jobId, String requesterKeycloakUserId)
            throws ApiException, IOException {
        AsyncJob job = loadOwnedJob(jobId, requesterKeycloakUserId);
        if (job.getStatus() != AsyncJob.Status.DONE || normalize(job.getResultFileObjectId()) == null) {
            throw new ValidationFailedException("validation.invalid.job.downloadNotReady");
        }

        GridFSFile file = gridFsTemplate.findOne(
                Query.query(Criteria.where("_id").is(new ObjectId(job.getResultFileObjectId()))));
        if (file == null) {
            throw new NotFoundException("jobResult");
        }

        try (InputStream in = gridFsOperations.getResource(file).getInputStream()) {
            return new JobDownloadPayload(
                    job.getResultFileName(),
                    job.getResultContentType(),
                    in.readAllBytes());
        }
    }

    /**
     * Entrypoint richiamato dal worker asincrono.
     */
    void executeJob(String jobId) {
        try {
            Optional<AsyncJob> opt = asyncJobRepository.findById(jobId);
            if (opt.isEmpty()) {
                return;
            }
            AsyncJob job = opt.get();
            markRunning(job);
            if (job.getType() == AsyncJob.Type.REPORT_EXPORT) {
                executeReportExport(job);
            } else if (job.getType() == AsyncJob.Type.MOROSITA_AUTO_SOLLECITI) {
                executeAutomaticSolleciti(job);
            } else if (job.getType() == AsyncJob.Type.MOROSITA_REMINDER_SCADENZE) {
                executeReminderScadenze(job);
            } else {
                fail(job, "validation.invalid.job.type", "Tipo job non supportato");
                return;
            }
            complete(job);
        } catch (Exception ex) {
            Optional<AsyncJob> current = asyncJobRepository.findById(jobId);
            if (current.isEmpty()) {
                return;
            }
            final String errorCode = resolveErrorCode(ex);
            fail(current.get(), errorCode, "Esecuzione job fallita: " + ex.getMessage());
        }
    }

    private void executeReportExport(AsyncJob job) throws ApiException {
        final String format = normalizeReportFormat(job.getInputFormat());
        final CoreReportExportRequest request = new CoreReportExportRequest();
        request.setIdCondominio(job.getIdCondominio());
        request.setFormat(format);
        request.setCondominoId(normalize(job.getInputCondominoId()));
        request.setRequesterKeycloakUserId(job.getRequesterKeycloakUserId());

        final ResponseEntity<CoreReportExportResponse> upstream = coreOperationsClient.exportReport(
                resolveOpsKey(),
                request);
        final CoreReportExportResponse body = upstream.getBody();
        if (body == null || body.getPayload() == null) {
            throw new ValidationFailedException("validation.invalid.job.report.emptyPayload");
        }

        final String fileName = normalize(body.getFileName()) == null
                ? "report_" + job.getIdCondominio() + "." + format
                : body.getFileName();
        final String contentType = normalize(body.getContentType()) == null
                ? (REPORT_FORMAT_XLSX.equals(format) ? CONTENT_TYPE_XLSX : CONTENT_TYPE_PDF)
                : body.getContentType();
        final byte[] payload = body.getPayload();

        final String storageObjectId = storeJobResult(job, fileName, contentType, payload);
        job.setResultFileObjectId(storageObjectId);
        job.setResultFileName(fileName);
        job.setResultContentType(contentType);
        job.setResultSizeBytes((long) payload.length);
        job.setResultCount(null);
        job.setMessage("Export completato");
        job.setErrorCode(null);
    }

    private void executeAutomaticSolleciti(AsyncJob job) throws ApiException {
        final int minDays = normalizeMinDays(job.getInputMinDaysOverdue());

        final CoreAutomaticSollecitiRequest request = new CoreAutomaticSollecitiRequest();
        request.setIdCondominio(job.getIdCondominio());
        request.setMinDaysOverdue(minDays);
        request.setRequesterKeycloakUserId(job.getRequesterKeycloakUserId());

        final ResponseEntity<CoreCountResponse> upstream = coreOperationsClient.generateAutomaticSolleciti(
                resolveOpsKey(),
                request);
        final int created = safeCount(upstream.getBody());

        job.setResultCount(created);
        job.setResultFileObjectId(null);
        job.setResultFileName(null);
        job.setResultContentType(null);
        job.setResultSizeBytes(null);
        job.setMessage("Solleciti creati: " + created);
        job.setErrorCode(null);
    }

    private void executeReminderScadenze(AsyncJob job) throws ApiException {
        final int maxDaysAhead = normalizeMaxDaysAhead(job.getInputMaxDaysAhead());

        final CoreReminderScadenzeRequest request = new CoreReminderScadenzeRequest();
        request.setIdCondominio(job.getIdCondominio());
        request.setMaxDaysAhead(maxDaysAhead);
        request.setRequesterKeycloakUserId(job.getRequesterKeycloakUserId());

        final ResponseEntity<CoreCountResponse> upstream = coreOperationsClient.generateReminderScadenze(
                resolveOpsKey(),
                request);
        final int created = safeCount(upstream.getBody());

        job.setResultCount(created);
        job.setResultFileObjectId(null);
        job.setResultFileName(null);
        job.setResultContentType(null);
        job.setResultSizeBytes(null);
        job.setMessage("Reminder creati: " + created);
        job.setErrorCode(null);
    }

    private String storeJobResult(AsyncJob job, String fileName, String contentType, byte[] bytes) {
        final Document metadata = new Document();
        metadata.put("jobId", job.getId());
        metadata.put("type", job.getType().name());
        metadata.put("idCondominio", job.getIdCondominio());
        metadata.put("requesterKeycloakUserId", job.getRequesterKeycloakUserId());
        metadata.put("createdAt", Instant.now().toString());
        return gridFsTemplate.store(
                        new java.io.ByteArrayInputStream(bytes),
                        fileName,
                        contentType,
                        metadata)
                .toHexString();
    }

    private void markRunning(AsyncJob job) {
        job.setStatus(AsyncJob.Status.RUNNING);
        job.setStartedAt(Instant.now());
        job.setFinishedAt(null);
        job.setMessage("Job in esecuzione");
        asyncJobRepository.save(job);
        meterRegistry.counter("condomio.jobs.running", "type", job.getType().name()).increment();
        LOG.info(
                "[OPS_JOBS] RUNNING id={} type={} condominio={} requester={}",
                job.getId(),
                job.getType(),
                job.getIdCondominio(),
                job.getRequesterKeycloakUserId());
    }

    private void complete(AsyncJob job) {
        job.setStatus(AsyncJob.Status.DONE);
        job.setFinishedAt(Instant.now());
        asyncJobRepository.save(job);
        recordTerminalMetrics(job, "done");
        LOG.info(
                "[OPS_JOBS] DONE id={} type={} condominio={} requester={} resultCount={} file={}",
                job.getId(),
                job.getType(),
                job.getIdCondominio(),
                job.getRequesterKeycloakUserId(),
                job.getResultCount(),
                job.getResultFileName());
    }

    private void fail(AsyncJob job, String errorCode, String message) {
        job.setStatus(AsyncJob.Status.FAILED);
        job.setFinishedAt(Instant.now());
        job.setErrorCode(errorCode);
        job.setMessage(message);
        asyncJobRepository.save(job);
        recordTerminalMetrics(job, "failed");
        LOG.warn(
                "[OPS_JOBS] FAILED id={} type={} condominio={} requester={} errorCode={} message={}",
                job.getId(),
                job.getType(),
                job.getIdCondominio(),
                job.getRequesterKeycloakUserId(),
                errorCode,
                message);
    }

    private AsyncJob loadOwnedJob(String jobId, String requesterKeycloakUserId) throws ApiException {
        final String normalizedId = requireNonBlank(jobId, "validation.required.job.id");
        return asyncJobRepository.findByIdAndRequesterKeycloakUserId(normalizedId, requesterKeycloakUserId)
                .orElseThrow(() -> new NotFoundException("job"));
    }

    private AsyncJobResource toResource(AsyncJob job) {
        AsyncJobResource out = new AsyncJobResource();
        out.setId(job.getId());
        out.setIdCondominio(job.getIdCondominio());
        out.setType(job.getType());
        out.setStatus(job.getStatus());
        out.setCreatedAt(job.getCreatedAt());
        out.setStartedAt(job.getStartedAt());
        out.setFinishedAt(job.getFinishedAt());
        out.setInputFormat(job.getInputFormat());
        out.setInputCondominoId(job.getInputCondominoId());
        out.setInputMinDaysOverdue(job.getInputMinDaysOverdue());
        out.setInputMaxDaysAhead(job.getInputMaxDaysAhead());
        out.setResultFileName(job.getResultFileName());
        out.setResultContentType(job.getResultContentType());
        out.setResultSizeBytes(job.getResultSizeBytes());
        out.setResultCount(job.getResultCount());
        out.setMessage(job.getMessage());
        out.setErrorCode(job.getErrorCode());
        out.setResultDownloadAvailable(job.getStatus() == AsyncJob.Status.DONE
                && normalize(job.getResultFileObjectId()) != null);
        return out;
    }

    private int safeCount(CoreCountResponse response) {
        if (response == null || response.getCount() == null) {
            return 0;
        }
        return Math.max(0, response.getCount());
    }

    private String resolveErrorCode(Exception ex) {
        if (ex instanceof ApiException api && api.getErrorCodes() != null && !api.getErrorCodes().isEmpty()) {
            return api.getErrorCodes().get(0);
        }
        if (ex instanceof FeignException feign) {
            if (feign.status() == 403) {
                return "service.forbidden";
            }
            if (feign.status() == 404) {
                return "resource.not.found";
            }
            if (feign.status() >= 400 && feign.status() < 500) {
                return "validation.failed";
            }
            return "server.upstream.core";
        }
        return "server.internal";
    }

    private String resolveOpsKey() throws ValidationFailedException {
        final String key = normalize(coreInternalBridgeProperties.getSharedKey());
        if (key == null) {
            throw new ValidationFailedException("validation.required.internal.ops.sharedKey");
        }
        return key;
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        final String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String requireNonBlank(String value, String errorCode) throws ValidationFailedException {
        final String normalized = normalize(value);
        if (normalized == null) {
            throw new ValidationFailedException(errorCode);
        }
        return normalized;
    }

    private String normalizeReportFormat(String format) throws ValidationFailedException {
        final String normalized = normalize(format);
        if (normalized == null) {
            throw new ValidationFailedException("validation.required.job.format");
        }
        final String lower = normalized.toLowerCase(Locale.ROOT);
        if (!REPORT_FORMAT_PDF.equals(lower) && !REPORT_FORMAT_XLSX.equals(lower)) {
            throw new ValidationFailedException("validation.invalid.job.format");
        }
        return lower;
    }

    private int normalizeMinDays(Integer minDaysOverdue) throws ValidationFailedException {
        final JobAutomationProperties.Solleciti cfg = jobAutomationProperties.getSolleciti();
        final int min = Math.max(0, cfg.getMinDaysOverdueMin());
        final int max = Math.max(min, cfg.getMinDaysOverdueMax());
        final int fallback = clamp(cfg.getDefaultMinDaysOverdue(), min, max);
        if (minDaysOverdue == null) {
            return fallback;
        }
        if (minDaysOverdue < min || minDaysOverdue > max) {
            throw new ValidationFailedException("validation.invalid.job.minDaysOverdue");
        }
        return minDaysOverdue;
    }

    private int normalizeMaxDaysAhead(Integer maxDaysAhead) throws ValidationFailedException {
        final JobAutomationProperties.Reminder cfg = jobAutomationProperties.getReminder();
        final int min = Math.max(0, cfg.getMaxDaysAheadMin());
        final int max = Math.max(min, cfg.getMaxDaysAheadMax());
        final int fallback = clamp(cfg.getDefaultMaxDaysAhead(), min, max);
        if (maxDaysAhead == null) {
            return fallback;
        }
        if (maxDaysAhead < min || maxDaysAhead > max) {
            throw new ValidationFailedException("validation.invalid.job.maxDaysAhead");
        }
        return maxDaysAhead;
    }

    private int normalizeLimit(Integer limit) throws ValidationFailedException {
        final JobAutomationProperties.ListConfig cfg = jobAutomationProperties.getList();
        final int maxLimit = Math.max(1, cfg.getMaxLimit());
        final int fallback = clamp(cfg.getDefaultLimit(), 1, maxLimit);
        if (limit == null) {
            return fallback;
        }
        if (limit <= 0 || limit > maxLimit) {
            throw new ValidationFailedException("validation.invalid.job.limit");
        }
        return limit;
    }

    private int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(max, value));
    }

    private void recordQueued(AsyncJob job) {
        meterRegistry.counter("condomio.jobs.queued", "type", job.getType().name()).increment();
        LOG.info(
                "[OPS_JOBS] QUEUED id={} type={} condominio={} requester={}",
                job.getId(),
                job.getType(),
                job.getIdCondominio(),
                job.getRequesterKeycloakUserId());
    }

    private void recordTerminalMetrics(AsyncJob job, String outcome) {
        meterRegistry.counter("condomio.jobs.completed", "type", job.getType().name(), "outcome", outcome).increment();
        if (job.getStartedAt() == null || job.getFinishedAt() == null) {
            return;
        }
        long durationMs = Math.max(0L, job.getFinishedAt().toEpochMilli() - job.getStartedAt().toEpochMilli());
        meterRegistry.timer("condomio.jobs.duration", "type", job.getType().name(), "outcome", outcome)
                .record(java.time.Duration.ofMillis(durationMs));
    }

    public record JobDownloadPayload(String fileName, String contentType, byte[] bytes) {
    }
}
