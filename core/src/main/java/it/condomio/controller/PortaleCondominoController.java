package it.condomio.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import it.condomio.controller.model.PortaleCondominoSnapshotResponse;
import it.condomio.exception.ApiException;
import it.condomio.service.PortaleCondominoService;

/**
 * API self-service del portale condomino.
 *
 * Il client mobile/web del condomino usa questi endpoint in sola lettura,
 * separati dai flussi amministrativi.
 */
@RestController
@RequestMapping("/portale")
public class PortaleCondominoController {

    private final PortaleCondominoService service;

    public PortaleCondominoController(PortaleCondominoService service) {
        this.service = service;
    }

    @GetMapping("/me")
    public ResponseEntity<PortaleCondominoSnapshotResponse> getMyPortalSnapshot(
            @RequestParam String idCondominio,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(service.getMySnapshot(idCondominio, jwt.getSubject()));
    }
}

