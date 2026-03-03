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

import it.condomio.document.Condomino;
import it.condomio.exception.ValidationFailedException;
import it.condomio.service.CondominoService;
import tools.jackson.databind.JsonNode;

@RestController
@RequestMapping("/condomino")
public class CondominoController {

    @Autowired
    private CondominoService condominoService;

    @PostMapping
    public ResponseEntity<Condomino> createCondomino(@RequestBody Condomino condomino) {
        return new ResponseEntity<>(condominoService.createCondomino(condomino), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Condomino> getCondominoById(@PathVariable String id) {
        return condominoService.getCondominoById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<Condomino>> getAllCondomini() {
        return ResponseEntity.ok(condominoService.getAllCondomini());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Condomino> updateCondomino(@PathVariable String id, @RequestBody Condomino condomino) {
        try {
            return ResponseEntity.ok(condominoService.updateCondomino(id, condomino));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCondomino(@PathVariable String id) {
        try {
            condominoService.deleteCondomino(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @PatchMapping("/{id}")
    public ResponseEntity<Condomino> updateCondomino(
            @PathVariable String id,
            @RequestBody JsonNode mergePatch) throws IOException, ValidationFailedException {
    	try {
            return ResponseEntity.ok(condominoService.patch(id, mergePatch));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
}

