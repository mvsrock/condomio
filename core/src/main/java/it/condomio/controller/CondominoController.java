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

import it.condomio.controller.model.CondominoResource;
import it.condomio.document.Condomino;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.service.CondominoService;
import tools.jackson.databind.JsonNode;

/**
 * Endpoint anagrafica condomini.
 * Ogni operazione usa il subject JWT per delegare al service i controlli tenant-aware.
 */
@RestController
@RequestMapping("/condomino")
public class CondominoController {

    @Autowired
    private CondominoService condominoService;

    /** Create standard. */
    @PostMapping
    public ResponseEntity<CondominoResource> createCondomino(
            @RequestBody CondominoResource condomino,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return new ResponseEntity<>(
                condominoService.createCondomino(condomino, jwt.getSubject()),
                HttpStatus.CREATED);
    }

    /** Compat legacy: alcuni client inviano create via PUT /condomino. */
    @PutMapping
    public ResponseEntity<CondominoResource> createCondominoPut(
            @RequestBody CondominoResource condomino,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return new ResponseEntity<>(
                condominoService.createCondomino(condomino, jwt.getSubject()),
                HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CondominoResource> getCondominoById(
            @PathVariable String id,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        final CondominoResource result = condominoService.getCondominoById(id, jwt.getSubject())
                .orElseThrow(() -> new NotFoundException("condomino"));
        return ResponseEntity.ok(result);
    }

    @GetMapping
    public ResponseEntity<List<CondominoResource>> getAllCondomini(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(name = "idCondominio", required = false) String idCondominio) {
        return ResponseEntity.ok(condominoService.getAllCondomini(jwt.getSubject(), idCondominio));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CondominoResource> updateCondomino(
            @PathVariable String id,
            @RequestBody CondominoResource condomino,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(condominoService.updateCondomino(id, condomino, jwt.getSubject()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCondomino(
            @PathVariable String id,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        condominoService.deleteCondomino(id, jwt.getSubject());
        return ResponseEntity.noContent().build();
    }

    /** Update parziale via JSON Merge Patch. */
    @PatchMapping(path = "/{id}", consumes = "application/merge-patch+json")
    public ResponseEntity<CondominoResource> patchCondomino(
            @PathVariable String id,
            @RequestBody JsonNode mergePatch,
            @AuthenticationPrincipal Jwt jwt) throws IOException, ValidationFailedException, ApiException {
        return ResponseEntity.ok(condominoService.patch(id, mergePatch, jwt.getSubject()));
    }

    /** Add versamento atomico sul condomino target (solo admin condominio). */
    @PostMapping("/{id}/versamenti")
    public ResponseEntity<Void> addVersamento(
            @PathVariable String id,
            @RequestBody Condomino.Versamento versamento,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        condominoService.addVersamento(id, versamento, jwt.getSubject());
        return ResponseEntity.noContent().build();
    }

    /** Update versamento atomico sul condomino target (solo admin condominio). */
    @PatchMapping("/{id}/versamenti/{versamentoId}")
    public ResponseEntity<Void> updateVersamento(
            @PathVariable String id,
            @PathVariable String versamentoId,
            @RequestBody Condomino.Versamento versamento,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        condominoService.updateVersamento(id, versamentoId, versamento, jwt.getSubject());
        return ResponseEntity.noContent().build();
    }

    /** Delete versamento atomico sul condomino target (solo admin condominio). */
    @DeleteMapping("/{id}/versamenti/{versamentoId}")
    public ResponseEntity<Void> deleteVersamento(
            @PathVariable String id,
            @PathVariable String versamentoId,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        condominoService.deleteVersamento(id, versamentoId, jwt.getSubject());
        return ResponseEntity.noContent().build();
    }
}
