package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Condomino;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominoRepository;
import it.condomio.util.JsonMergePatchHelper;
import tools.jackson.databind.JsonNode;

@Service
public class CondominoService {

    @Autowired
    private CondominoRepository condominoRepository;

    public Condomino createCondomino(Condomino condomino) {
        return condominoRepository.save(condomino);
    }

    public Optional<Condomino> getCondominoById(String id) {
        return condominoRepository.findById(id);
    }

    public List<Condomino> getAllCondomini() {
        return condominoRepository.findAll();
    }

    public Condomino updateCondomino(String id, Condomino updatedCondomino) {
        if (!condominoRepository.existsById(id)) {
            throw new IllegalArgumentException("Condomino con ID " + id + " non trovato.");
        }
        updatedCondomino.setId(id);
        return condominoRepository.save(updatedCondomino);
    }

    public void deleteCondomino(String id) {
        if (!condominoRepository.existsById(id)) {
            throw new IllegalArgumentException("Condomino con ID " + id + " non trovato.");
        }
        condominoRepository.deleteById(id);
    }

    public Condomino patch(String id, JsonNode mergePatch) throws IOException, ValidationFailedException {
        Optional<Condomino> optionalCondomino = condominoRepository.findById(id);
        if (!optionalCondomino.isPresent()) {
            throw new IllegalArgumentException("Tabella con ID " + id + " non trovato.");
        }
        Condomino condomino = optionalCondomino.get();
        Condomino patchedCondomino = JsonMergePatchHelper.applyMergePatch(mergePatch, condomino, Condomino.class);
        return condominoRepository.save(patchedCondomino);
    }
}

