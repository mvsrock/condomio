package it.condomio.service;

import java.io.IOException;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Condominio;
import it.condomio.document.Condomino;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominoRepository;
import it.condomio.util.JsonMergePatchHelper;
import tools.jackson.databind.JsonNode;

@Service
public class CondominioService {

    @Autowired
    private CondominioRepository condominioRepository;

    @Autowired
    private CondominoRepository condominoRepository;

    /**
     * Crea un condominio e imposta il proprietario applicativo
     * con il subject JWT dell'utente autenticato.
     */
    public Condominio createCondominio(Condominio condominio, String adminKeycloakUserId) {
        condominio.setAdminKeycloakUserId(adminKeycloakUserId);
        return condominioRepository.save(condominio);
    }

    /**
     * Lettura singolo condominio consentita se:
     * - utente admin proprietario del condominio, oppure
     * - utente collegato come condomino (keycloakUserId associato).
     */
    public Optional<Condominio> getCondominioById(String id, String keycloakUserId) {
        Optional<Condominio> asAdmin = condominioRepository.findByIdAndAdminKeycloakUserId(id, keycloakUserId);
        if (asAdmin.isPresent()) {
            return asAdmin;
        }
        boolean asCondomino = condominoRepository.existsByIdCondominioAndKeycloakUserId(id, keycloakUserId);
        if (!asCondomino) {
            return Optional.empty();
        }
        return condominioRepository.findById(id);
    }

    /**
     * Lista condomini visibili all'utente:
     * - condomini dove e' admin
     * - condomini dove e' associato come condomino via keycloakUserId
     */
    public List<Condominio> getAllCondomini(String keycloakUserId) {
        final List<Condominio> adminCondomini = condominioRepository.findByAdminKeycloakUserId(keycloakUserId);
        final List<Condomino> linkedCondomini = condominoRepository.findByKeycloakUserId(keycloakUserId);

        Set<String> ids = new LinkedHashSet<>();
        for (Condominio c : adminCondomini) {
            if (c.getId() != null && !c.getId().isBlank()) {
                ids.add(c.getId());
            }
        }
        for (Condomino c : linkedCondomini) {
            if (c.getIdCondominio() != null && !c.getIdCondominio().isBlank()) {
                ids.add(c.getIdCondominio());
            }
        }

        if (ids.isEmpty()) {
            return List.of();
        }
        return condominioRepository.findAllById(ids);
    }

    /** Update consentito solo all'admin proprietario del condominio. */
    public Condominio updateCondominio(String id, Condominio updatedCondominio, String adminKeycloakUserId)
            throws ApiException {
        if (!condominioRepository.existsByIdAndAdminKeycloakUserId(id, adminKeycloakUserId)) {
            throw new ForbiddenException();
        }
        updatedCondominio.setId(id);
        updatedCondominio.setAdminKeycloakUserId(adminKeycloakUserId);
        return condominioRepository.save(updatedCondominio);
    }

    /** Delete consentita solo all'admin proprietario del condominio. */
    public void deleteCondominio(String id, String adminKeycloakUserId) throws ApiException {
        if (!condominioRepository.existsByIdAndAdminKeycloakUserId(id, adminKeycloakUserId)) {
            throw new ForbiddenException();
        }
        condominioRepository.deleteById(id);
    }

    public Condominio patch(String id, JsonNode mergePatch, String adminKeycloakUserId)
            throws IOException, ValidationFailedException, ApiException {
        Optional<Condominio> optionalCondominio =
                condominioRepository.findByIdAndAdminKeycloakUserId(id, adminKeycloakUserId);
        if (optionalCondominio.isEmpty()) {
            throw new NotFoundException("condominio");
        }
        Condominio condominio = optionalCondominio.get();
        Condominio patchedCondominio = JsonMergePatchHelper.applyMergePatch(mergePatch, condominio, Condominio.class);
        patchedCondominio.setAdminKeycloakUserId(adminKeycloakUserId);
        validatePercentuali(patchedCondominio);
        return condominioRepository.save(patchedCondominio);
    }

    public void validatePercentuali(Condominio condominio) throws ValidationFailedException {
        if (condominio.getConfigurazioniSpesa() == null) {
            return;
        }

        for (Condominio.ConfigurazioneSpesa configurazione : condominio.getConfigurazioniSpesa()) {
            List<Condominio.ConfigurazioneSpesa.TabellaPercentuale> tabelle = configurazione.getTabelle();

            if (tabelle != null) {
                int sommaPercentuali = tabelle.stream()
                        .filter(tabella -> tabella != null && tabella.getPercentuale() != null)
                        .mapToInt(Condominio.ConfigurazioneSpesa.TabellaPercentuale::getPercentuale)
                        .sum();

                if (sommaPercentuali != 100) {
                    throw new ValidationFailedException("invalid.percent." + configurazione.getCodice());
                }
            }
        }
    }
}
