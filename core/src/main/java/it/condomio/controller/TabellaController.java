package it.condomio.controller;

import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import it.condomio.document.Tabella;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.service.TabellaService;
import tools.jackson.databind.JsonNode;

@RestController
@RequestMapping("/tabelle")
public class TabellaController {

    @Autowired
    private TabellaService tabellaService;

    @PostMapping
    public ResponseEntity<Tabella> createTabella(@RequestBody Tabella tabella) {
        return new ResponseEntity<>(tabellaService.createTabella(tabella), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Tabella> getTabellaById(@PathVariable String id) throws ApiException {
        return ResponseEntity.ok(
                tabellaService.getTabellaById(id).orElseThrow(() -> new NotFoundException("tabella")));
    }

    @GetMapping
    public ResponseEntity<List<Tabella>> getAllTabelle() {
        return ResponseEntity.ok(tabellaService.getAllTabelle());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Tabella> updateTabella(
            @PathVariable String id,
            @RequestBody Tabella tabella) throws ApiException {
        return ResponseEntity.ok(tabellaService.updateTabella(id, tabella));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTabella(@PathVariable String id) throws ApiException {
        tabellaService.deleteTabella(id);
        return ResponseEntity.noContent().build();
    }

    /** Update parziale via JSON Merge Patch, con mapping errori delegato a errorhandler. */
    @PatchMapping(path = "/{id}", consumes = "application/merge-patch+json")
    public ResponseEntity<Tabella> patchTabella(
            @PathVariable String id,
            @RequestBody JsonNode mergePatch) throws IOException, ValidationFailedException, ApiException {
        return ResponseEntity.ok(tabellaService.patch(id, mergePatch));
    }
}

