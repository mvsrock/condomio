package it.condomio.controller;

import java.nio.charset.StandardCharsets;
import java.util.List;

import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import it.condomio.controller.model.AsyncJobResource;
import it.condomio.exception.ApiException;
import it.condomio.service.AsyncJobService;
import it.condomio.service.AsyncJobService.JobDownloadPayload;

/**
 * API job asincroni (Fase 8 - punto 1).
 *
 * Contratto:
 * - queue operazioni pesanti
 * - monitor stato job
 * - download risultato quando disponibile
 */
@RestController
@RequestMapping("/jobs")
public class AsyncJobController {

    private final AsyncJobService asyncJobService;

    public AsyncJobController(AsyncJobService asyncJobService) {
        this.asyncJobService = asyncJobService;
    }

    @PostMapping("/report-export")
    public ResponseEntity<AsyncJobResource> queueReportExport(
            @RequestParam String idCondominio,
            @RequestParam String format,
            @RequestParam(required = false) String condominoId,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(asyncJobService.queueReportExport(
                idCondominio,
                format,
                condominoId,
                jwt.getSubject()));
    }

    @PostMapping("/morosita/{idCondominio}/solleciti-automatici")
    public ResponseEntity<AsyncJobResource> queueAutomaticSolleciti(
            @PathVariable String idCondominio,
            @RequestParam(required = false) Integer minDaysOverdue,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(asyncJobService.queueAutomaticSolleciti(
                idCondominio,
                minDaysOverdue,
                jwt.getSubject()));
    }

    @GetMapping("/{jobId}")
    public ResponseEntity<AsyncJobResource> getJob(
            @PathVariable String jobId,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(asyncJobService.getJob(jobId, jwt.getSubject()));
    }

    @GetMapping
    public ResponseEntity<List<AsyncJobResource>> listMyJobs(
            @RequestParam(required = false) Integer limit,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(asyncJobService.listMyJobs(jwt.getSubject(), limit));
    }

    @GetMapping("/{jobId}/download")
    public ResponseEntity<byte[]> downloadJobResult(
            @PathVariable String jobId,
            @AuthenticationPrincipal Jwt jwt) throws Exception {
        JobDownloadPayload payload = asyncJobService.downloadJobResult(jobId, jwt.getSubject());
        return ResponseEntity.ok()
                .header(
                        HttpHeaders.CONTENT_DISPOSITION,
                        ContentDisposition.attachment()
                                .filename(payload.fileName(), StandardCharsets.UTF_8)
                                .build()
                                .toString())
                .contentType(MediaType.parseMediaType(payload.contentType()))
                .body(payload.bytes());
    }
}

