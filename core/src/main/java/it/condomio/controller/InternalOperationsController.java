package it.condomio.controller;

import java.util.Locale;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import it.condomio.config.properties.InternalOperationsProperties;
import it.condomio.controller.model.InternalAutomaticSollecitiRequest;
import it.condomio.controller.model.InternalCountResponse;
import it.condomio.controller.model.InternalReminderScadenzeRequest;
import it.condomio.controller.model.InternalReportExportRequest;
import it.condomio.controller.model.InternalReportExportResponse;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.service.MorositaService;
import it.condomio.service.ReportService;

/**
 * Endpoint interni usati esclusivamente da operations-service.
 *
 * Non sono pensati per il frontend: sono protetti da shared key applicativa
 * (`X-Ops-Key`) per evitare accesso anonimo.
 */
@RestController
@RequestMapping("/internal/operations")
public class InternalOperationsController {

    private static final String FORMAT_XLSX = "xlsx";
    private static final String FORMAT_PDF = "pdf";
    private static final String CONTENT_TYPE_XLSX =
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    private static final String CONTENT_TYPE_PDF = "application/pdf";

    private final ReportService reportService;
    private final MorositaService morositaService;
    private final InternalOperationsProperties internalOperationsProperties;

    public InternalOperationsController(
            ReportService reportService,
            MorositaService morositaService,
            InternalOperationsProperties internalOperationsProperties) {
        this.reportService = reportService;
        this.morositaService = morositaService;
        this.internalOperationsProperties = internalOperationsProperties;
    }

    @PostMapping("/report-export")
    public ResponseEntity<InternalReportExportResponse> exportReport(
            @RequestHeader(value = "X-Ops-Key", required = false) String opsKey,
            @RequestBody InternalReportExportRequest request) throws ApiException {
        validateOpsKey(opsKey);
        if (request == null) {
            throw new ValidationFailedException("validation.required.job.request");
        }
        final String idCondominio = requireNonBlank(request.getIdCondominio(), "validation.required.job.idCondominio");
        final String requester = requireNonBlank(
                request.getRequesterKeycloakUserId(),
                "validation.required.job.requesterKeycloakUserId");
        final String format = normalizeReportFormat(request.getFormat());
        final String condominoId = normalize(request.getCondominoId());

        final byte[] payload;
        final String contentType;
        if (FORMAT_XLSX.equals(format)) {
            payload = reportService.exportXlsx(idCondominio, requester, condominoId);
            contentType = CONTENT_TYPE_XLSX;
        } else {
            payload = reportService.exportPdf(idCondominio, requester, condominoId);
            contentType = CONTENT_TYPE_PDF;
        }

        InternalReportExportResponse response = new InternalReportExportResponse();
        response.setFileName("report_" + idCondominio + "." + format);
        response.setContentType(contentType);
        response.setPayload(payload);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/morosita/solleciti-automatici")
    public ResponseEntity<InternalCountResponse> generateAutomaticSolleciti(
            @RequestHeader(value = "X-Ops-Key", required = false) String opsKey,
            @RequestBody InternalAutomaticSollecitiRequest request) throws ApiException {
        validateOpsKey(opsKey);
        if (request == null) {
            throw new ValidationFailedException("validation.required.job.request");
        }
        final String idCondominio = requireNonBlank(request.getIdCondominio(), "validation.required.job.idCondominio");
        final String requester = requireNonBlank(
                request.getRequesterKeycloakUserId(),
                "validation.required.job.requesterKeycloakUserId");
        final int minDays = request.getMinDaysOverdue() == null ? 1 : request.getMinDaysOverdue();

        final int created = morositaService.generateAutomaticSolleciti(idCondominio, minDays, requester);
        InternalCountResponse response = new InternalCountResponse();
        response.setCount(created);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/morosita/reminder-scadenze")
    public ResponseEntity<InternalCountResponse> generateReminderScadenze(
            @RequestHeader(value = "X-Ops-Key", required = false) String opsKey,
            @RequestBody InternalReminderScadenzeRequest request) throws ApiException {
        validateOpsKey(opsKey);
        if (request == null) {
            throw new ValidationFailedException("validation.required.job.request");
        }
        final String idCondominio = requireNonBlank(request.getIdCondominio(), "validation.required.job.idCondominio");
        final String requester = requireNonBlank(
                request.getRequesterKeycloakUserId(),
                "validation.required.job.requesterKeycloakUserId");
        final int maxDaysAhead = request.getMaxDaysAhead() == null ? 7 : request.getMaxDaysAhead();

        final int created = morositaService.generateUpcomingReminders(idCondominio, maxDaysAhead, requester);
        InternalCountResponse response = new InternalCountResponse();
        response.setCount(created);
        return ResponseEntity.ok(response);
    }

    private void validateOpsKey(String opsKey) throws ForbiddenException, ValidationFailedException {
        final String configured = normalize(internalOperationsProperties.getSharedKey());
        if (configured == null) {
            throw new ValidationFailedException("validation.required.internal.ops.sharedKey");
        }
        if (!configured.equals(opsKey)) {
            throw new ForbiddenException();
        }
    }

    private String normalizeReportFormat(String format) throws ValidationFailedException {
        final String normalized = normalize(format);
        if (normalized == null) {
            throw new ValidationFailedException("validation.required.job.format");
        }
        final String lower = normalized.toLowerCase(Locale.ROOT);
        if (!FORMAT_PDF.equals(lower) && !FORMAT_XLSX.equals(lower)) {
            throw new ValidationFailedException("validation.invalid.job.format");
        }
        return lower;
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
}
