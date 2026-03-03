package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Movimenti;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.MovimentiRepository;
import it.condomio.util.JsonMergePatchHelper;
import tools.jackson.databind.JsonNode;

@Service
public class MovimentiService {

    @Autowired
    private MovimentiRepository movimentiRepository;

    public Movimenti createMovimento(Movimenti movimento) {
        return movimentiRepository.save(movimento);
    }

    public Optional<Movimenti> getMovimentoById(String id) {
        return movimentiRepository.findById(id);
    }

    public List<Movimenti> getAllMovimenti() {
        return movimentiRepository.findAll();
    }

    public Movimenti updateMovimento(String id, Movimenti updatedMovimento) {
        if (!movimentiRepository.existsById(id)) {
            throw new IllegalArgumentException("Movimento con ID " + id + " non trovato.");
        }
        updatedMovimento.setId(id);
        return movimentiRepository.save(updatedMovimento);
    }

    public void deleteMovimento(String id) {
        if (!movimentiRepository.existsById(id)) {
            throw new IllegalArgumentException("Movimento con ID " + id + " non trovato.");
        }
        movimentiRepository.deleteById(id);
    }

    public Movimenti patch(String id, JsonNode mergePatch) throws IOException, ValidationFailedException {
        Optional<Movimenti> optionalMovimenti = movimentiRepository.findById(id);
        if (!optionalMovimenti.isPresent()) {
            throw new IllegalArgumentException("Tabella con ID " + id + " non trovato.");
        }
        Movimenti movimenti = optionalMovimenti.get();
        Movimenti patchedMovimenti = JsonMergePatchHelper.applyMergePatch(mergePatch, movimenti, Movimenti.class);
        return movimentiRepository.save(patchedMovimenti);
    }
}
