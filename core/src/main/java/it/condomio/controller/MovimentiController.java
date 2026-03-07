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

import it.condomio.document.Movimenti;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.service.MovimentiService;
import tools.jackson.databind.JsonNode;

@RestController
@RequestMapping("/movimenti")
public class MovimentiController {

    @Autowired
    private MovimentiService movimentiService;

    @PostMapping
    public ResponseEntity<Movimenti> createMovimento(
            @RequestBody Movimenti movimento,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return new ResponseEntity<>(movimentiService.createMovimento(movimento, jwt.getSubject()), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Movimenti> getMovimentoById(
            @PathVariable String id,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(
                movimentiService.getMovimentoById(id, jwt.getSubject())
                        .orElseThrow(() -> new NotFoundException("movimento")));
    }

    @GetMapping
    public ResponseEntity<List<Movimenti>> getAllMovimenti(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(name = "idCondominio", required = false) String idCondominio) {
        return ResponseEntity.ok(movimentiService.getAllMovimenti(jwt.getSubject(), idCondominio));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Movimenti> updateMovimento(
            @PathVariable String id,
            @RequestBody Movimenti movimento,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(movimentiService.updateMovimento(id, movimento, jwt.getSubject()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMovimento(
            @PathVariable String id,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        movimentiService.deleteMovimento(id, jwt.getSubject());
        return ResponseEntity.noContent().build();
    }

    /** Update parziale via JSON Merge Patch, con mapping errori delegato a errorhandler. */
    @PatchMapping(path = "/{id}", consumes = "application/merge-patch+json")
    public ResponseEntity<Movimenti> patchMovimento(
            @PathVariable String id,
            @RequestBody JsonNode mergePatch,
            @AuthenticationPrincipal Jwt jwt) throws IOException, ValidationFailedException, ApiException {
        return ResponseEntity.ok(movimentiService.patch(id, mergePatch, jwt.getSubject()));
    }

    /** Rebuild completo residui del condominio (utility operativa). */
    @PostMapping("/rebuild-residui/{idCondominio}")
    public ResponseEntity<Void> rebuildResidui(
            @PathVariable String idCondominio,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        movimentiService.rebuildResidui(idCondominio, jwt.getSubject());
        return ResponseEntity.noContent().build();
    }

    /** Rebuild storico completo su condominio (movimenti + residui). */
    @PostMapping("/rebuild-storico/{idCondominio}")
    public ResponseEntity<Void> rebuildStorico(
            @PathVariable String idCondominio,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        movimentiService.rebuildStorico(idCondominio, jwt.getSubject());
        return ResponseEntity.noContent().build();
    }
}

