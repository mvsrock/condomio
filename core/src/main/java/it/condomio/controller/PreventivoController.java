package it.condomio.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import it.condomio.controller.model.PreventivoSnapshotResponse;
import it.condomio.controller.model.PreventivoUpsertRequest;
import it.condomio.exception.ApiException;
import it.condomio.service.PreventivoService;

/**
 * API preventivo/consuntivo per esercizio.
 */
@RestController
@RequestMapping("/preventivi")
public class PreventivoController {

    private final PreventivoService preventivoService;

    public PreventivoController(PreventivoService preventivoService) {
        this.preventivoService = preventivoService;
    }

    @GetMapping("/{idCondominio}")
    public ResponseEntity<PreventivoSnapshotResponse> getSnapshot(
            @PathVariable String idCondominio,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(preventivoService.getSnapshot(idCondominio, jwt.getSubject()));
    }

    @PutMapping("/{idCondominio}")
    public ResponseEntity<PreventivoSnapshotResponse> saveSnapshot(
            @PathVariable String idCondominio,
            @RequestBody PreventivoUpsertRequest request,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(preventivoService.saveSnapshot(idCondominio, request, jwt.getSubject()));
    }
}

