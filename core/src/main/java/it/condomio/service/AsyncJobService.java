package it.condomio.service;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.gridfs.GridFsOperations;
import org.springframework.data.mongodb.gridfs.GridFsTemplate;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import com.mongodb.client.gridfs.model.GridFSFile;

import it.condomio.controller.model.AsyncJobResource;
import it.condomio.document.AsyncJob;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.AsyncJobRepository;

/**
 * Orchestratore dei job asincroni (Fase 8 - punto 1).
 *
 * Mantiene il contratto stabile:
 * - queue job
 * - stato job
 * - download risultato (se presente)
 */
@Service
public class AsyncJobService {

    public static final String REPORT_FORMAT_XLSX = "xlsx";
    public static final String REPORT_FORMAT_PDF = "pdf";

    private static final String CONTENT_TYPE_XLSX =
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    private static final String CONTENT_TYPE_PDF = "application/pdf";
    private static final int MAX_LIST_LIMIT = 200;

    private final AsyncJobRepository asyncJobRepository;
    private final EsercizioGuardService esercizioGuardService;
    private final ReportService reportService;
    private final MorositaService morositaService;
    private final GridFsTemplate gridFsTemplate;
    private final GridFsOperations gridFsOperations;
    private final AsyncJobWorker asyncJobWorker;

    public AsyncJobService(
            AsyncJobRepository asyncJobRepository,
            EsercizioGuardService esercizioGuardService,
            ReportService reportService,
            MorositaService morositaService,
            GridFsTemplate gridFsTemplate,
            GridFsOperations gridFsOperations,
            AsyncJobWorker asyncJobWorker) {
        this.asyncJobRepository = asyncJobRepository;
        this.esercizioGuardService = esercizioGuardService;
        this.reportService = reportService;
        this.morositaService = morositaService;
        this.gridFsTemplate = gridFsTemplate;
        this.gridFsOperations = gridFsOperations;
        this.asyncJobWorker = asyncJobWorker;
    }

    /**
     * Accoda export report asincrono.
     */
    public AsyncJobResource queueReportExport(
            String idCondominio,
            String format,
            String condominoId,
            String requesterKeycloakUserId) throws ApiException {
        final String exerciseId = requireNonBlank(idCondominio, "validation.required.job.idCondominio");
        final String normalizedFormat = normalizeReportFormat(format);
        final String normalizedCondominoId = normalize(condominoId);

        // Fail-fast tenant guard: solo owner dell'esercizio puo' accodare.
        esercizioGuardService.requireOwnedExercise(exerciseId, requesterKeycloakUserId);

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
        asyncJobWorker.process(saved.getId());
        return toResource(saved);
    }

    /**
     * Accoda generazione automatica solleciti asincrona.
     */
    public AsyncJobResource queueAutomaticSolleciti(
            String idCondominio,
            Integer minDaysOverdue,
            String requesterKeycloakUserId) throws ApiException {
        final String exerciseId = requireNonBlank(idCondominio, "validation.required.job.idCondominio");
        final int normalizedMinDays = normalizeMinDays(minDaysOverdue);

        // Operazione mutativa: consentita solo su esercizio owned e aperto.
        esercizioGuardService.requireOwnedOpenExercise(exerciseId, requesterKeycloakUserId);

        AsyncJob payload = new AsyncJob();
        payload.setRequesterKeycloakUserId(requesterKeycloakUserId);
        payload.setIdCondominio(exerciseId);
        payload.setType(AsyncJob.Type.MOROSITA_AUTO_SOLLECITI);
        payload.setStatus(AsyncJob.Status.QUEUED);
        payload.setCreatedAt(Instant.now());
        payload.setInputMinDaysOverdue(normalizedMinDays);
        payload.setMessage("Job accodato");

        AsyncJob saved = asyncJobRepository.save(payload);
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
     * Entrypoint usato dal worker asincrono.
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

    private void executeReportExport(AsyncJob job) throws ApiException, IOException {
        final String format = normalizeReportFormat(job.getInputFormat());
        final byte[] bytes;
        final String fileName;
        final String contentType;
        if (REPORT_FORMAT_XLSX.equals(format)) {
            bytes = reportService.exportXlsx(
                    job.getIdCondominio(),
                    job.getRequesterKeycloakUserId(),
                    normalize(job.getInputCondominoId()));
            fileName = "report_" + job.getIdCondominio() + ".xlsx";
            contentType = CONTENT_TYPE_XLSX;
        } else {
            bytes = reportService.exportPdf(
                    job.getIdCondominio(),
                    job.getRequesterKeycloakUserId(),
                    normalize(job.getInputCondominoId()));
            fileName = "report_" + job.getIdCondominio() + ".pdf";
            contentType = CONTENT_TYPE_PDF;
        }
        final String storageObjectId = storeJobResult(job, fileName, contentType, bytes);
        job.setResultFileObjectId(storageObjectId);
        job.setResultFileName(fileName);
        job.setResultContentType(contentType);
        job.setResultSizeBytes((long) bytes.length);
        job.setResultCount(null);
        job.setMessage("Export completato");
        job.setErrorCode(null);
    }

    private void executeAutomaticSolleciti(AsyncJob job) throws ApiException {
        final int minDays = normalizeMinDays(job.getInputMinDaysOverdue());
        final int created = morositaService.generateAutomaticSolleciti(
                job.getIdCondominio(),
                minDays,
                job.getRequesterKeycloakUserId());
        job.setResultCount(created);
        job.setResultFileObjectId(null);
        job.setResultFileName(null);
        job.setResultContentType(null);
        job.setResultSizeBytes(null);
        job.setMessage("Solleciti creati: " + created);
        job.setErrorCode(null);
    }

    private String storeJobResult(AsyncJob job, String fileName, String contentType, byte[] bytes) throws IOException {
        try (InputStream stream = new ByteArrayInputStream(bytes)) {
            Document metadata = new Document();
            metadata.put("jobId", job.getId());
            metadata.put("type", job.getType().name());
            metadata.put("idCondominio", job.getIdCondominio());
            metadata.put("requesterKeycloakUserId", job.getRequesterKeycloakUserId());
            metadata.put("createdAt", Instant.now().toString());
            return gridFsTemplate.store(stream, fileName, contentType, metadata).toHexString();
        }
    }

    private void markRunning(AsyncJob job) {
        job.setStatus(AsyncJob.Status.RUNNING);
        job.setStartedAt(Instant.now());
        job.setFinishedAt(null);
        job.setMessage("Job in esecuzione");
        asyncJobRepository.save(job);
    }

    private void complete(AsyncJob job) {
        job.setStatus(AsyncJob.Status.DONE);
        job.setFinishedAt(Instant.now());
        asyncJobRepository.save(job);
    }

    private void fail(AsyncJob job, String errorCode, String message) {
        job.setStatus(AsyncJob.Status.FAILED);
        job.setFinishedAt(Instant.now());
        job.setErrorCode(errorCode);
        job.setMessage(message);
        asyncJobRepository.save(job);
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

    private String resolveErrorCode(Exception ex) {
        if (ex instanceof ApiException api && api.getErrorCodes() != null && !api.getErrorCodes().isEmpty()) {
            return api.getErrorCodes().get(0);
        }
        return "server.internal";
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
        if (minDaysOverdue == null) {
            return 1;
        }
        if (minDaysOverdue < 0 || minDaysOverdue > 3650) {
            throw new ValidationFailedException("validation.invalid.job.minDaysOverdue");
        }
        return minDaysOverdue;
    }

    private int normalizeLimit(Integer limit) throws ValidationFailedException {
        if (limit == null) {
            return 30;
        }
        if (limit <= 0 || limit > MAX_LIST_LIMIT) {
            throw new ValidationFailedException("validation.invalid.job.limit");
        }
        return limit;
    }

    public record JobDownloadPayload(String fileName, String contentType, byte[] bytes) {
    }
}
