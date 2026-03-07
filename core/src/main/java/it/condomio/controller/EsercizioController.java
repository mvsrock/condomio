package it.condomio.controller;

import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
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
import org.springframework.web.bind.annotation.RestController;

import it.condomio.document.Condominio;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.service.CondominioService;
import tools.jackson.databind.JsonNode;

/**
 * Endpoint esercizio: il vecchio documento "condominio" ora espone
 * esplicitamente il ruolo di esercizio annuale.
 *
 * Qui vivono tutte le operazioni CRUD e di chiusura sul contesto annuale
 * realmente selezionato dal frontend.
 */
@RestController
@RequestMapping("/esercizi")
public class EsercizioController {

    @Autowired
    private CondominioService condominioService;

    @GetMapping("/{id}")
    public ResponseEntity<Condominio> getEsercizioById(
            @PathVariable String id,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        final Condominio result = condominioService.getCondominioById(id, jwt.getSubject())
                .orElseThrow(() -> new NotFoundException("esercizio"));
        return ResponseEntity.ok(result);
    }

    @GetMapping
    public ResponseEntity<List<Condominio>> getAllEsercizi(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(condominioService.getAllCondomini(jwt.getSubject()));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Condominio> updateEsercizio(
            @PathVariable String id,
            @RequestBody Condominio esercizio,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(condominioService.updateCondominio(id, esercizio, jwt.getSubject()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEsercizio(
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
    public ResponseEntity<Condominio> patchEsercizio(
            @PathVariable String id,
            @RequestBody JsonNode mergePatch,
            @AuthenticationPrincipal Jwt jwt) throws IOException, ValidationFailedException, ApiException {
        return ResponseEntity.ok(condominioService.patch(id, mergePatch, jwt.getSubject()));
    }
}
