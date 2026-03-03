package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Condominio;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.util.JsonMergePatchHelper;
import tools.jackson.databind.JsonNode;

@Service
public class CondominioService {

    @Autowired
    private CondominioRepository condominioRepository;

    public Condominio createCondominio(Condominio condominio) {
        return condominioRepository.save(condominio);
    }

    public Optional<Condominio> getCondominioById(String id) {
        return condominioRepository.findById(id);
    }

    public List<Condominio> getAllCondomini() {
        return condominioRepository.findAll();
    }

    public Condominio updateCondominio(String id, Condominio updatedCondominio) {
        if (!condominioRepository.existsById(id)) {
            throw new IllegalArgumentException("Condominio con ID " + id + " non trovato.");
        }
        updatedCondominio.setId(id);
        return condominioRepository.save(updatedCondominio);
    }

    public void deleteCondominio(String id) {
        if (!condominioRepository.existsById(id)) {
            throw new IllegalArgumentException("Condominio con ID " + id + " non trovato.");
        }
        condominioRepository.deleteById(id);
    }
    
    public Condominio patch(String id, JsonNode mergePatch) throws IOException, ValidationFailedException {
        Optional<Condominio> optionalCondominio = condominioRepository.findById(id);
        if (!optionalCondominio.isPresent()) {
            throw new IllegalArgumentException("Condominio con ID " + id + " non trovato.");
        }
        Condominio condominio = optionalCondominio.get();
        Condominio patchedCondominio = JsonMergePatchHelper.applyMergePatch(mergePatch, condominio, Condominio.class);
        validatePercentuali(patchedCondominio);
        return condominioRepository.save(patchedCondominio);
    }
    
    public void validatePercentuali(Condominio condominio) throws ValidationFailedException{
        if (condominio.getConfigurazioniSpesa() == null) {
            return; // Se non ci sono configurazioni, consideriamo il dato valido
        }

        for (Condominio.ConfigurazioneSpesa configurazione : condominio.getConfigurazioniSpesa()) {
            List<Condominio.ConfigurazioneSpesa.TabellaPercentuale> tabelle = configurazione.getTabelle();

            if (tabelle != null) {
                int sommaPercentuali = tabelle.stream()
                    .filter(tabella -> tabella != null && tabella.getPercentuale() != null) // Filtra gli elementi null
                    .mapToInt(Condominio.ConfigurazioneSpesa.TabellaPercentuale::getPercentuale)
                    .sum();

                if (sommaPercentuali != 100) {
                    throw new ValidationFailedException("invalid.percent." + configurazione.getCodice()); // La somma delle percentuali non è valida
                }
            }
        }

    }

}

