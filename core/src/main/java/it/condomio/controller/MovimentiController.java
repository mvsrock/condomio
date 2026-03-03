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

import it.condomio.document.Movimenti;
import it.condomio.exception.ValidationFailedException;
import it.condomio.service.MovimentiService;
import tools.jackson.databind.JsonNode;

@RestController
@RequestMapping("/movimenti")
public class MovimentiController {

    @Autowired
    private MovimentiService movimentiService;

    @PostMapping
    public ResponseEntity<Movimenti> createMovimento(@RequestBody Movimenti movimento) {
        return new ResponseEntity<>(movimentiService.createMovimento(movimento), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Movimenti> getMovimentoById(@PathVariable String id) {
        return movimentiService.getMovimentoById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<Movimenti>> getAllMovimenti() {
        return ResponseEntity.ok(movimentiService.getAllMovimenti());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Movimenti> updateMovimento(@PathVariable String id, @RequestBody Movimenti movimento) {
        try {
            return ResponseEntity.ok(movimentiService.updateMovimento(id, movimento));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMovimento(@PathVariable String id) {
        try {
            movimentiService.deleteMovimento(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Movimenti> updateCondomino(
            @PathVariable String id,
            @RequestBody JsonNode mergePatch) throws IOException, ValidationFailedException {
    	try {
            return ResponseEntity.ok(movimentiService.patch(id, mergePatch));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
}

