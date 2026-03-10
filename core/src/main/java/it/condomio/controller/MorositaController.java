package it.condomio.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import it.condomio.controller.model.MorositaItemResource;
import it.condomio.controller.model.MorositaSollecitoRequest;
import it.condomio.controller.model.MorositaStatoUpdateRequest;
import it.condomio.exception.ApiException;
import it.condomio.service.MorositaService;

/**
 * API operative per morosita', solleciti e stato pratica.
 */
@RestController
@RequestMapping("/morosita")
public class MorositaController {

    private final MorositaService morositaService;

    public MorositaController(MorositaService morositaService) {
        this.morositaService = morositaService;
    }

    @GetMapping
    public ResponseEntity<List<MorositaItemResource>> listByExercise(
            @RequestParam(name = "idCondominio") String idCondominio,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(morositaService.listByExercise(idCondominio, jwt.getSubject()));
    }

    @PatchMapping("/{condominoId}/stato")
    public ResponseEntity<Void> updateStato(
            @PathVariable String condominoId,
            @RequestBody MorositaStatoUpdateRequest request,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        morositaService.updateStato(condominoId, request == null ? null : request.getStato(), jwt.getSubject());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{condominoId}/solleciti")
    public ResponseEntity<Void> addSollecito(
            @PathVariable String condominoId,
            @RequestBody MorositaSollecitoRequest request,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        morositaService.addSollecito(condominoId, request, jwt.getSubject());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/solleciti/automatici/{idCondominio}")
    public ResponseEntity<Integer> generateAutomaticSolleciti(
            @PathVariable String idCondominio,
            @RequestParam(name = "minDaysOverdue", defaultValue = "0") int minDaysOverdue,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(
                morositaService.generateAutomaticSolleciti(idCondominio, minDaysOverdue, jwt.getSubject()));
    }
}

