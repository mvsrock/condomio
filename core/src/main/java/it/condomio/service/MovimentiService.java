package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Movimenti;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
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

    public Movimenti updateMovimento(String id, Movimenti updatedMovimento) throws ApiException {
        if (!movimentiRepository.existsById(id)) {
            throw new NotFoundException("movimento");
        }
        updatedMovimento.setId(id);
        return movimentiRepository.save(updatedMovimento);
    }

    public void deleteMovimento(String id) throws ApiException {
        if (!movimentiRepository.existsById(id)) {
            throw new NotFoundException("movimento");
        }
        movimentiRepository.deleteById(id);
    }

    public Movimenti patch(String id, JsonNode mergePatch)
            throws IOException, ValidationFailedException, ApiException {
        Optional<Movimenti> optionalMovimenti = movimentiRepository.findById(id);
        if (optionalMovimenti.isEmpty()) {
            throw new NotFoundException("movimento");
        }
        Movimenti movimenti = optionalMovimenti.get();
        Movimenti patchedMovimenti = JsonMergePatchHelper.applyMergePatch(mergePatch, movimenti, Movimenti.class);
        return movimentiRepository.save(patchedMovimenti);
    }
}
