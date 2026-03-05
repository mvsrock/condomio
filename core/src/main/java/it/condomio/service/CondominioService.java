package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

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

    @Autowired
    private TenantAccessService tenantAccessService;

    /**
     * Crea un condominio e imposta il proprietario applicativo
     * con il subject JWT dell'utente autenticato.
     */
    public Condominio createCondominio(Condominio condominio, String adminKeycloakUserId)
            throws ValidationFailedException {
        validateCreatePayload(condominio);
        if (condominioRepository.existsByAnnoAndLabelIgnoreCase(condominio.getAnno(), condominio.getLabel())) {
            throw new ValidationFailedException("validation.duplicate.condominio.anno_label");
        }
        condominio.setId(null);
        condominio.setVersion(null);
        condominio.setAdminKeycloakUserId(adminKeycloakUserId);
        return condominioRepository.save(condominio);
    }

    /**
     * Lettura singolo condominio consentita se:
     * - utente admin proprietario del condominio, oppure
     * - utente collegato come condomino (keycloakUserId associato).
     */
    public Optional<Condominio> getCondominioById(String id, String keycloakUserId) {
        if (!tenantAccessService.canViewCondominio(keycloakUserId, id)) {
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
        final List<String> ids = tenantAccessService.findVisibleCondominioIds(keycloakUserId);
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
        validateCreatePayload(updatedCondominio);
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
        validateCreatePayload(patchedCondominio);
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

    private void validateCreatePayload(Condominio condominio) throws ValidationFailedException {
        if (condominio.getLabel() == null || condominio.getLabel().trim().isEmpty()) {
            throw new ValidationFailedException("validation.required.condominio.label");
        }
        if (condominio.getAnno() == null) {
            throw new ValidationFailedException("validation.required.condominio.anno");
        }
        if (condominio.getAnno() < 1900 || condominio.getAnno() > 2100) {
            throw new ValidationFailedException("validation.invalid.condominio.anno");
        }
    }
}
