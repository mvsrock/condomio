package it.condomio.controller;

import java.io.IOException;
import java.util.Collections;
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
import org.springframework.web.bind.annotation.RestController;

import it.condomio.document.Condominio;
import it.condomio.exception.ValidationFailedException;
import it.condomio.service.CondominioService;
import tools.jackson.databind.JsonNode;

@RestController
@RequestMapping("/condominio")
public class CondominioController {

    @Autowired
    private CondominioService condominioService;

    @PostMapping
    public ResponseEntity<Condominio> createCondominio(@RequestBody Condominio condominio) {
        return new ResponseEntity<>(condominioService.createCondominio(condominio), HttpStatus.CREATED);
    }
    
    @SuppressWarnings("unchecked")
	@GetMapping("/ping")
    public ResponseEntity<String> ping(@AuthenticationPrincipal Jwt jwt) {
    	List<String> roles = jwt.getClaimAsMap("realm_access") != null
				? (List<String>) jwt.getClaimAsMap("realm_access").get("roles")
				: Collections.emptyList();
    	System.out.println(roles);
        return ResponseEntity.ok("pong");
    }

    @GetMapping("/{id}")
    public ResponseEntity<Condominio> getCondominioById(@PathVariable String id) {
        return condominioService.getCondominioById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<Condominio>> getAllCondomini() {
        return ResponseEntity.ok(condominioService.getAllCondomini());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Condominio> updateCondominio(@PathVariable String id, @RequestBody Condominio condominio) {
        try {
            return ResponseEntity.ok(condominioService.updateCondominio(id, condominio));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCondominio(@PathVariable String id) {
        try {
            condominioService.deleteCondominio(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

//    @PatchMapping("/{id}")
//    public ResponseEntity<Condominio> patchCondominio(@PathVariable String id, @RequestBody Map<String, Object> updates) {
//        try {
//            return ResponseEntity.ok(condominioService.patchCondominio(id, updates));
//        } catch (IllegalArgumentException e) {
//            return ResponseEntity.notFound().build();
//        }
//    }
    
//    @PatchMapping(path = "/{id}", consumes = "application/merge-patch+json")
    @PatchMapping("/{id}")
    public ResponseEntity<Condominio> updateCondominio(
            @PathVariable String id,
            @RequestBody JsonNode mergePatch) throws IOException, ValidationFailedException {
    	try {
            return ResponseEntity.ok(condominioService.patch(id, mergePatch));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
}

