package it.condomio.service;

import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.controller.model.UnitaTitolaritaResource;
import it.condomio.controller.model.UnitaImmobiliareResource;
import it.condomio.document.Condominio;
import it.condomio.document.Condomino;
import it.condomio.document.UnitaImmobiliare;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominoRepository;
import it.condomio.repository.UnitaImmobiliareRepository;

/**
 * Gestione unita' immobiliari stabili per condominio root.
 */
@Service
public class UnitaImmobiliareService {

    @Autowired
    private UnitaImmobiliareRepository repository;

    @Autowired
    private EsercizioGuardService esercizioGuardService;

    @Autowired
    private CondominioRepository condominioRepository;

    @Autowired
    private CondominoRepository condominoRepository;

    public List<UnitaImmobiliareResource> listByExercise(String idCondominio, String keycloakUserId) throws ApiException {
        Condominio exercise = esercizioGuardService.requireOwnedOpenExercise(idCondominio, keycloakUserId);
        return repository.findByCondominioRootIdOrderByScalaAscInternoAsc(exercise.getCondominioRootId())
                .stream()
                .map(this::toResource)
                .toList();
    }

    public UnitaImmobiliareResource create(String idCondominio, UnitaImmobiliareResource payload, String keycloakUserId)
            throws ApiException {
        Condominio exercise = esercizioGuardService.requireOwnedOpenExercise(idCondominio, keycloakUserId);
        validate(payload);
        UnitaImmobiliare unit = new UnitaImmobiliare();
        unit.setCondominioRootId(exercise.getCondominioRootId());
        applyPayload(unit, payload);
        unit.setCreatedAt(Instant.now());
        unit.setUpdatedAt(Instant.now());
        return toResource(repository.save(unit));
    }

    public UnitaImmobiliareResource update(
            String idCondominio,
            String id,
            UnitaImmobiliareResource payload,
            String keycloakUserId) throws ApiException {
        Condominio exercise = esercizioGuardService.requireOwnedOpenExercise(idCondominio, keycloakUserId);
        validate(payload);
        UnitaImmobiliare existing = repository.findByIdAndCondominioRootId(id, exercise.getCondominioRootId())
                .orElseThrow(() -> new NotFoundException("unitaImmobiliare"));
        applyPayload(existing, payload);
        existing.setUpdatedAt(Instant.now());
        return toResource(repository.save(existing));
    }

    public void delete(String idCondominio, String id, String keycloakUserId) throws ApiException {
        Condominio exercise = esercizioGuardService.requireOwnedOpenExercise(idCondominio, keycloakUserId);
        UnitaImmobiliare existing = repository.findByIdAndCondominioRootId(id, exercise.getCondominioRootId())
                .orElseThrow(() -> new NotFoundException("unitaImmobiliare"));
        repository.deleteById(existing.getId());
    }

    /**
     * Timeline titolarita' dell'unita' su tutti gli esercizi della stessa gestione root.
     */
    public List<UnitaTitolaritaResource> listStoricoTitolarita(
            String idCondominio,
            String unitaId,
            String keycloakUserId) throws ApiException {
        Condominio exercise = esercizioGuardService.requireOwnedOpenExercise(idCondominio, keycloakUserId);
        UnitaImmobiliare unit = repository.findByIdAndCondominioRootId(unitaId, exercise.getCondominioRootId())
                .orElseThrow(() -> new NotFoundException("unitaImmobiliare"));

        List<Condominio> exercises = condominioRepository.findByCondominioRootIdOrderByAnnoDesc(
                exercise.getCondominioRootId());
        List<String> exerciseIds = exercises.stream()
                .map(Condominio::getId)
                .filter(value -> value != null && !value.isBlank())
                .toList();
        if (exerciseIds.isEmpty()) {
            return List.of();
        }

        Map<String, Condominio> exerciseById = exercises.stream()
                .filter(item -> item.getId() != null)
                .collect(Collectors.toMap(Condominio::getId, item -> item, (left, right) -> left));

        return condominoRepository.findByIdCondominioInAndUnitaImmobiliareId(exerciseIds, unit.getId())
                .stream()
                .sorted(Comparator.comparing(
                        item -> item.getDataIngresso() == null ? Instant.EPOCH : item.getDataIngresso()))
                .map(item -> toTitolaritaResource(item, exerciseById.get(item.getIdCondominio())))
                .toList();
    }

    private void validate(UnitaImmobiliareResource payload) throws ValidationFailedException {
        if (payload == null) {
            throw new ValidationFailedException("validation.required.unitaImmobiliare");
        }
        if (payload.getScala() == null || payload.getScala().isBlank()) {
            throw new ValidationFailedException("validation.required.unitaImmobiliare.scala");
        }
        if (payload.getInterno() == null || payload.getInterno().isBlank()) {
            throw new ValidationFailedException("validation.required.unitaImmobiliare.interno");
        }
    }

    private void applyPayload(UnitaImmobiliare target, UnitaImmobiliareResource payload) {
        target.setCodice(normalize(payload.getCodice()));
        target.setScala(normalize(payload.getScala()));
        target.setInterno(normalize(payload.getInterno()));
        target.setSubalterno(normalize(payload.getSubalterno()));
        target.setDestinazioneUso(normalize(payload.getDestinazioneUso()));
        target.setMetriQuadri(payload.getMetriQuadri());
    }

    private UnitaImmobiliareResource toResource(UnitaImmobiliare source) {
        UnitaImmobiliareResource out = new UnitaImmobiliareResource();
        out.setId(source.getId());
        out.setVersion(source.getVersion());
        out.setCondominioRootId(source.getCondominioRootId());
        out.setCodice(source.getCodice());
        out.setScala(source.getScala());
        out.setInterno(source.getInterno());
        out.setSubalterno(source.getSubalterno());
        out.setDestinazioneUso(source.getDestinazioneUso());
        out.setMetriQuadri(source.getMetriQuadri());
        return out;
    }

    private UnitaTitolaritaResource toTitolaritaResource(Condomino source, Condominio exercise) {
        UnitaTitolaritaResource out = new UnitaTitolaritaResource();
        out.setCondominoId(source.getId());
        out.setCondominoRootId(source.getCondominoRootId());
        out.setIdCondominio(source.getIdCondominio());
        out.setNominativo(buildNominativo(source.getNome(), source.getCognome()));
        out.setTitolaritaTipo(source.getTitolaritaTipo());
        out.setStatoPosizione(source.getStatoPosizione());
        out.setDataIngresso(source.getDataIngresso());
        out.setDataUscita(source.getDataUscita());
        out.setMotivoUscita(source.getMotivoUscita());
        if (exercise != null) {
            out.setAnnoEsercizio(exercise.getAnno());
            out.setGestioneCodice(exercise.getGestioneCodice());
        }
        return out;
    }

    private String buildNominativo(String nome, String cognome) {
        String first = normalize(nome);
        String last = normalize(cognome);
        if (first == null && last == null) {
            return "";
        }
        if (first == null) {
            return last;
        }
        if (last == null) {
            return first;
        }
        return first + " " + last;
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        final String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
