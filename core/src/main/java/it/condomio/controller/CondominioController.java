package it.condomio.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import it.condomio.controller.model.CondominioRootSummaryResponse;
import it.condomio.document.Condominio;
import it.condomio.exception.ApiException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.service.CondominioService;

/**
 * Endpoint del condominio reale (root).
 *
 * Le operazioni sugli esercizi annuali vivono invece in {@link EsercizioController}.
 */
@RestController
@RequestMapping("/condomini")
public class CondominioController {

    @Autowired
    private CondominioService condominioService;

    @PostMapping
    public ResponseEntity<Condominio> createCondominio(
            @RequestBody Condominio condominio,
            @AuthenticationPrincipal Jwt jwt) throws ValidationFailedException {
        return new ResponseEntity<>(
                condominioService.createCondominio(condominio, jwt.getSubject()),
                HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<CondominioRootSummaryResponse>> getOwnedRoots(
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(condominioService.getOwnedRoots(jwt.getSubject()));
    }

    @PostMapping("/{rootId}/esercizi")
    public ResponseEntity<Condominio> createEsercizio(
            @PathVariable String rootId,
            @RequestBody Condominio esercizio,
            @RequestParam(name = "carryOverBalances", defaultValue = "false") boolean carryOverBalances,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return new ResponseEntity<>(
                condominioService.createEsercizio(rootId, esercizio, carryOverBalances, jwt.getSubject()),
                HttpStatus.CREATED);
    }
}

