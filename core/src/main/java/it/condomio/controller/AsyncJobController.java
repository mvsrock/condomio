package it.condomio.controller;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import feign.FeignException;
import it.condomio.client.operations.OperationsJobClient;
import it.condomio.service.RequestBearerTokenResolver;

/**
 * Facade job su core.
 *
 * Frontend -> core -> operations-service:
 * la UI continua a chiamare core, ma l'esecuzione job e' demandata al
 * microservizio operations.
 */
@RestController
@RequestMapping("/jobs")
public class AsyncJobController {

    private final OperationsJobClient operationsJobClient;
    private final RequestBearerTokenResolver bearerTokenResolver;

    public AsyncJobController(
            OperationsJobClient operationsJobClient,
            RequestBearerTokenResolver bearerTokenResolver) {
        this.operationsJobClient = operationsJobClient;
        this.bearerTokenResolver = bearerTokenResolver;
    }

    @PostMapping("/report-export")
    public ResponseEntity<?> queueReportExport(
            @RequestParam String idCondominio,
            @RequestParam String format,
            @RequestParam(required = false) String condominoId) {
        try {
            return operationsJobClient.queueReportExport(
                    bearerTokenResolver.resolveBearerToken(),
                    idCondominio,
                    format,
                    condominoId);
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @PostMapping("/morosita/{idCondominio}/solleciti-automatici")
    public ResponseEntity<?> queueAutomaticSolleciti(
            @PathVariable String idCondominio,
            @RequestParam(required = false) Integer minDaysOverdue) {
        try {
            return operationsJobClient.queueAutomaticSolleciti(
                    bearerTokenResolver.resolveBearerToken(),
                    idCondominio,
                    minDaysOverdue);
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @PostMapping("/morosita/{idCondominio}/reminder-scadenze")
    public ResponseEntity<?> queueUpcomingReminder(
            @PathVariable String idCondominio,
            @RequestParam(required = false) Integer maxDaysAhead) {
        try {
            return operationsJobClient.queueUpcomingReminder(
                    bearerTokenResolver.resolveBearerToken(),
                    idCondominio,
                    maxDaysAhead);
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @GetMapping("/{jobId}")
    public ResponseEntity<?> getJob(@PathVariable String jobId) {
        try {
            return operationsJobClient.getJob(
                    bearerTokenResolver.resolveBearerToken(),
                    jobId);
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @GetMapping
    public ResponseEntity<?> listMyJobs(@RequestParam(required = false) Integer limit) {
        try {
            return operationsJobClient.listMyJobs(
                    bearerTokenResolver.resolveBearerToken(),
                    limit);
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @GetMapping("/{jobId}/download")
    public ResponseEntity<?> downloadJobResult(@PathVariable String jobId) {
        try {
            ResponseEntity<byte[]> upstream = operationsJobClient.downloadJobResult(
                    bearerTokenResolver.resolveBearerToken(),
                    jobId);
            return ResponseEntity.status(upstream.getStatusCode())
                    .headers(upstream.getHeaders())
                    .body(upstream.getBody());
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    private ResponseEntity<String> mapFeignException(FeignException ex) {
        HttpStatus status = HttpStatus.resolve(ex.status());
        if (status == null) {
            status = HttpStatus.BAD_GATEWAY;
        }
        String body = ex.contentUTF8();
        if (body == null || body.isBlank()) {
            body = "{\"errorCodes\":[\"server.upstream.operations\"],\"timestamp\":null}";
        }
        return ResponseEntity.status(status)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(body);
    }
}
