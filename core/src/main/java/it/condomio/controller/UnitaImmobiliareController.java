package it.condomio.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import it.condomio.controller.model.UnitaTitolaritaResource;
import it.condomio.controller.model.UnitaImmobiliareResource;
import it.condomio.exception.ApiException;
import it.condomio.service.UnitaImmobiliareService;

@RestController
@RequestMapping("/unita-immobiliari")
public class UnitaImmobiliareController {

    @Autowired
    private UnitaImmobiliareService service;

    @GetMapping
    public ResponseEntity<List<UnitaImmobiliareResource>> list(
            @RequestParam(name = "idCondominio") String idCondominio,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(service.listByExercise(idCondominio, jwt.getSubject()));
    }

    @GetMapping("/{id}/titolarita")
    public ResponseEntity<List<UnitaTitolaritaResource>> listTitolaritaStorico(
            @PathVariable String id,
            @RequestParam(name = "idCondominio") String idCondominio,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(service.listStoricoTitolarita(idCondominio, id, jwt.getSubject()));
    }

    @PostMapping
    public ResponseEntity<UnitaImmobiliareResource> create(
            @RequestParam(name = "idCondominio") String idCondominio,
            @RequestBody UnitaImmobiliareResource payload,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return new ResponseEntity<>(
                service.create(idCondominio, payload, jwt.getSubject()),
                HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<UnitaImmobiliareResource> update(
            @PathVariable String id,
            @RequestParam(name = "idCondominio") String idCondominio,
            @RequestBody UnitaImmobiliareResource payload,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        return ResponseEntity.ok(service.update(idCondominio, id, payload, jwt.getSubject()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable String id,
            @RequestParam(name = "idCondominio") String idCondominio,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        service.delete(idCondominio, id, jwt.getSubject());
        return ResponseEntity.noContent().build();
    }
}
