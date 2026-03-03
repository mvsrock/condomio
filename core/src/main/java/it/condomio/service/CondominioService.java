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

    public Condominio createCondominio(Condominio condominio, String adminKeycloakUserId) {
        condominio.setAdminKeycloakUserId(adminKeycloakUserId);
        return condominioRepository.save(condominio);
    }

    public Optional<Condominio> getCondominioById(String id, String adminKeycloakUserId) {
        return condominioRepository.findByIdAndAdminKeycloakUserId(id, adminKeycloakUserId);
    }

    public List<Condominio> getAllCondomini(String adminKeycloakUserId) {
        return condominioRepository.findByAdminKeycloakUserId(adminKeycloakUserId);
    }

    public Condominio updateCondominio(String id, Condominio updatedCondominio, String adminKeycloakUserId) {
        if (!condominioRepository.existsByIdAndAdminKeycloakUserId(id, adminKeycloakUserId)) {
            throw new IllegalArgumentException("Condominio con ID " + id + " non trovato.");
        }
        updatedCondominio.setId(id);
        updatedCondominio.setAdminKeycloakUserId(adminKeycloakUserId);
        return condominioRepository.save(updatedCondominio);
    }

    public void deleteCondominio(String id, String adminKeycloakUserId) {
        if (!condominioRepository.existsByIdAndAdminKeycloakUserId(id, adminKeycloakUserId)) {
            throw new IllegalArgumentException("Condominio con ID " + id + " non trovato.");
        }
        condominioRepository.deleteById(id);
    }
    
    public Condominio patch(String id, JsonNode mergePatch, String adminKeycloakUserId) throws IOException, ValidationFailedException {
        Optional<Condominio> optionalCondominio = condominioRepository.findByIdAndAdminKeycloakUserId(id, adminKeycloakUserId);
        if (!optionalCondominio.isPresent()) {
            throw new IllegalArgumentException("Condominio con ID " + id + " non trovato.");
        }
        Condominio condominio = optionalCondominio.get();
        Condominio patchedCondominio = JsonMergePatchHelper.applyMergePatch(mergePatch, condominio, Condominio.class);
        patchedCondominio.setAdminKeycloakUserId(adminKeycloakUserId);
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

