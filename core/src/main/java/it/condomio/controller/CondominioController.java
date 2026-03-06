package it.condomio.controller;

import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import it.condomio.controller.model.CondominioRootSummaryResponse;
import it.condomio.document.Condominio;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.service.CondominioService;
import tools.jackson.databind.JsonNode;

@RestController
@RequestMapping("/condominio")
public class CondominioController {

    @Autowired
    private CondominioService condominioService;

    @PostMapping
    public ResponseEntity<Condominio> createCondominio(
            @RequestBody Condominio condominio,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return new ResponseEntity<>(
                condominioService.createCondominio(condominio, jwt.getSubject()),
                HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Condominio> getCondominioById(
            @PathVariable String id,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        final Condominio result = condominioService.getCondominioById(id, jwt.getSubject())
                .orElseThrow(() -> new NotFoundException("condominio"));
        return ResponseEntity.ok(result);
    }

    @GetMapping
    public ResponseEntity<List<Condominio>> getAllCondomini(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(condominioService.getAllCondomini(jwt.getSubject()));
    }

    @GetMapping("/roots")
    public ResponseEntity<List<CondominioRootSummaryResponse>> getOwnedRoots(
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(condominioService.getOwnedRoots(jwt.getSubject()));
    }

    @PostMapping("/root/{rootId}/esercizi")
    public ResponseEntity<Condominio> createEsercizio(
            @PathVariable String rootId,
            @RequestBody Condominio esercizio,
            @RequestParam(name = "carryOverBalances", defaultValue = "false") boolean carryOverBalances,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return new ResponseEntity<>(
                condominioService.createEsercizio(rootId, esercizio, carryOverBalances, jwt.getSubject()),
                HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Condominio> updateCondominio(
            @PathVariable String id,
            @RequestBody Condominio condominio,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(condominioService.updateCondominio(id, condominio, jwt.getSubject()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCondominio(
            @PathVariable String id,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        condominioService.deleteCondominio(id, jwt.getSubject());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/close")
    public ResponseEntity<Condominio> closeEsercizio(
            @PathVariable String id,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(condominioService.closeEsercizio(id, jwt.getSubject()));
    }

    /** Update parziale via JSON Merge Patch (validationhandler + errorhandler). */
    @PatchMapping(path = "/{id}", consumes = "application/merge-patch+json")
    public ResponseEntity<Condominio> updateCondominio(
            @PathVariable String id,
            @RequestBody JsonNode mergePatch,
            @AuthenticationPrincipal Jwt jwt) throws IOException, ValidationFailedException, ApiException {
        return ResponseEntity.ok(condominioService.patch(id, mergePatch, jwt.getSubject()));
    }
}

