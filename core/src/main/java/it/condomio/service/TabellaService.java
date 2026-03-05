package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Tabella;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.TabellaRepository;
import it.condomio.util.JsonMergePatchHelper;
import tools.jackson.databind.JsonNode;

@Service
public class TabellaService {

    @Autowired
    private TabellaRepository tabellaRepository;

    public Tabella createTabella(Tabella tabella) {
        return tabellaRepository.save(tabella);
    }

    public Optional<Tabella> getTabellaById(String id) {
        return tabellaRepository.findById(id);
    }

    public List<Tabella> getAllTabelle() {
        return tabellaRepository.findAll();
    }

    public Tabella updateTabella(String id, Tabella updatedTabella) throws ApiException {
        if (!tabellaRepository.existsById(id)) {
            throw new NotFoundException("tabella");
        }
        updatedTabella.setId(id);
        return tabellaRepository.save(updatedTabella);
    }

    public void deleteTabella(String id) throws ApiException {
        if (!tabellaRepository.existsById(id)) {
            throw new NotFoundException("tabella");
        }
        tabellaRepository.deleteById(id);
    }

    public Tabella patch(String id, JsonNode mergePatch)
            throws IOException, ValidationFailedException, ApiException {
        Optional<Tabella> optionalTabella = tabellaRepository.findById(id);
        if (optionalTabella.isEmpty()) {
            throw new NotFoundException("tabella");
        }
        Tabella tabella = optionalTabella.get();
        Tabella patchedTabella = JsonMergePatchHelper.applyMergePatch(mergePatch, tabella, Tabella.class);
        return tabellaRepository.save(patchedTabella);
    }
}
