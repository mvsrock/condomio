package it.condomio.client.operations;

import java.util.List;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;

import it.condomio.controller.model.AsyncJobResource;

/**
 * Proxy core -> operations-service per API job.
 */
@FeignClient(name = "operations-service", contextId = "operationsJobClient")
public interface OperationsJobClient {

    @PostMapping("/jobs/report-export")
    ResponseEntity<AsyncJobResource> queueReportExport(
            @RequestHeader("Authorization") String authorization,
            @RequestParam String idCondominio,
            @RequestParam String format,
            @RequestParam(required = false) String condominoId);

    @PostMapping("/jobs/morosita/{idCondominio}/solleciti-automatici")
    ResponseEntity<AsyncJobResource> queueAutomaticSolleciti(
            @RequestHeader("Authorization") String authorization,
            @PathVariable String idCondominio,
            @RequestParam(required = false) Integer minDaysOverdue);

    @PostMapping("/jobs/morosita/{idCondominio}/reminder-scadenze")
    ResponseEntity<AsyncJobResource> queueUpcomingReminder(
            @RequestHeader("Authorization") String authorization,
            @PathVariable String idCondominio,
            @RequestParam(required = false) Integer maxDaysAhead);

    @GetMapping("/jobs/{jobId}")
    ResponseEntity<AsyncJobResource> getJob(
            @RequestHeader("Authorization") String authorization,
            @PathVariable String jobId);

    @GetMapping("/jobs")
    ResponseEntity<List<AsyncJobResource>> listMyJobs(
            @RequestHeader("Authorization") String authorization,
            @RequestParam(required = false) Integer limit);

    @GetMapping("/jobs/{jobId}/download")
    ResponseEntity<byte[]> downloadJobResult(
            @RequestHeader("Authorization") String authorization,
            @PathVariable String jobId);
}
