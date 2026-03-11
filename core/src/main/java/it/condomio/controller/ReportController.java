package it.condomio.controller;

import java.nio.charset.StandardCharsets;

import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import it.condomio.controller.model.ReportSnapshotResponse;
import it.condomio.exception.ApiException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.service.ReportService;

/**
 * API report professionali esercizio:
 * - snapshot JSON
 * - export PDF/XLSX
 */
@RestController
@RequestMapping("/reports")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/{idCondominio}")
    public ResponseEntity<ReportSnapshotResponse> getSnapshot(
            @PathVariable String idCondominio,
            @RequestParam(required = false) String condominoId,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(reportService.getSnapshot(idCondominio, jwt.getSubject(), condominoId));
    }

    @GetMapping("/{idCondominio}/export")
    public ResponseEntity<byte[]> exportReport(
            @PathVariable String idCondominio,
            @RequestParam String format,
            @RequestParam(required = false) String condominoId,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        final String normalizedFormat = format == null ? "" : format.trim().toLowerCase();
        final String baseFileName = "report_" + idCondominio;
        if ("xlsx".equals(normalizedFormat)) {
            final byte[] payload = reportService.exportXlsx(idCondominio, jwt.getSubject(), condominoId);
            return ResponseEntity.ok()
                    .header(
                            HttpHeaders.CONTENT_DISPOSITION,
                            ContentDisposition.attachment()
                                    .filename(baseFileName + ".xlsx", StandardCharsets.UTF_8)
                                    .build()
                                    .toString())
                    .contentType(MediaType.parseMediaType(
                            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                    .body(payload);
        }
        if ("pdf".equals(normalizedFormat)) {
            final byte[] payload = reportService.exportPdf(idCondominio, jwt.getSubject(), condominoId);
            return ResponseEntity.ok()
                    .header(
                            HttpHeaders.CONTENT_DISPOSITION,
                            ContentDisposition.attachment()
                                    .filename(baseFileName + ".pdf", StandardCharsets.UTF_8)
                                    .build()
                                    .toString())
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(payload);
        }
        throw new ValidationFailedException("validation.invalid.report.format");
    }
}

