package it.condomio.client.core;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;

import it.condomio.client.core.model.CoreAutomaticSollecitiRequest;
import it.condomio.client.core.model.CoreCountResponse;
import it.condomio.client.core.model.CoreReminderScadenzeRequest;
import it.condomio.client.core.model.CoreReportExportRequest;
import it.condomio.client.core.model.CoreReportExportResponse;

/**
 * Bridge interno operations -> core.
 *
 * Chiamate signed con header `X-Ops-Key` per endpoint non esposti al frontend.
 */
@FeignClient(name = "core", contextId = "coreOperationsClient")
public interface CoreOperationsClient {

    @PostMapping("/internal/operations/report-export")
    ResponseEntity<CoreReportExportResponse> exportReport(
            @RequestHeader("X-Ops-Key") String opsKey,
            @RequestBody CoreReportExportRequest request);

    @PostMapping("/internal/operations/morosita/solleciti-automatici")
    ResponseEntity<CoreCountResponse> generateAutomaticSolleciti(
            @RequestHeader("X-Ops-Key") String opsKey,
            @RequestBody CoreAutomaticSollecitiRequest request);

    @PostMapping("/internal/operations/morosita/reminder-scadenze")
    ResponseEntity<CoreCountResponse> generateReminderScadenze(
            @RequestHeader("X-Ops-Key") String opsKey,
            @RequestBody CoreReminderScadenzeRequest request);
}
