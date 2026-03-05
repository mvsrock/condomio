package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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
    private static final Logger log = LoggerFactory.getLogger(CondominioService.class);

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
        validateChangedPercentualiByPosition(condominio, patchedCondominio);
        return condominioRepository.save(patchedCondominio);
    }

    public void validatePercentuali(Condominio condominio) throws ValidationFailedException {
        if (condominio.getConfigurazioniSpesa() == null) {
            return;
        }

        for (Condominio.ConfigurazioneSpesa configurazione : condominio.getConfigurazioniSpesa()) {
            if (configurazione == null) {
                continue;
            }
            List<Condominio.ConfigurazioneSpesa.TabellaPercentuale> tabelle = configurazione.getTabelle();
            if (tabelle == null || tabelle.isEmpty()) {
                // Configurazione vuota: non blocca patch correlate (es. rename tabella).
                continue;
            }

            long tabelleConPercentuale = tabelle.stream()
                    .filter(tabella -> tabella != null && tabella.getPercentuale() != null)
                    .count();
            if (tabelleConPercentuale == 0) {
                continue;
            }

            int sommaPercentuali = tabelle.stream()
                    .filter(tabella -> tabella != null && tabella.getPercentuale() != null)
                    .mapToInt(Condominio.ConfigurazioneSpesa.TabellaPercentuale::getPercentuale)
                    .sum();

            if (sommaPercentuali != 100) {
                final String codice = configurazione.getCodice() == null ? "" : configurazione.getCodice();
                throw new ValidationFailedException("invalid.percent." + codice);
            }
        }
    }

    private void validateChangedPercentualiByPosition(Condominio before, Condominio after)
            throws ValidationFailedException {
        List<Condominio.ConfigurazioneSpesa> beforeList =
                before == null ? null : before.getConfigurazioniSpesa();
        List<Condominio.ConfigurazioneSpesa> afterList =
                after == null ? null : after.getConfigurazioniSpesa();

        int beforeSize = beforeList == null ? 0 : beforeList.size();
        int afterSize = afterList == null ? 0 : afterList.size();
        if (afterSize == 0) {
            return;
        }
        for (int i = 0; i < afterSize; i++) {
            Integer beforeSum = i < beforeSize ? sumPercentuali(beforeList.get(i)) : null;
            Integer afterSum = sumPercentuali(afterList.get(i));
            if (afterSum == null) {
                continue;
            }
            // Caso legacy: valori null serializzati dal client come 0.
            // Non va considerato una modifica funzionale delle percentuali.
            boolean legacyNullToZero = beforeSum == null && afterSum == 0;
            boolean changed = !legacyNullToZero && (beforeSum == null || !beforeSum.equals(afterSum));
            if (changed && afterSum != 100) {
                final Condominio.ConfigurazioneSpesa cfg = afterList.get(i);
                final String codice = cfg == null || cfg.getCodice() == null ? "" : cfg.getCodice();
                final String dettaglioTabelle = cfg == null || cfg.getTabelle() == null
                        ? "[]"
                        : cfg.getTabelle().stream()
                                .map(t -> {
                                    if (t == null) {
                                        return "{codice:null,percentuale:null}";
                                    }
                                    return "{codice:" + t.getCodice() + ",percentuale:" + t.getPercentuale() + "}";
                                })
                                .reduce((a, b) -> a + "," + b)
                                .map(s -> "[" + s + "]")
                                .orElse("[]");
                log.warn(
                        "[CondominioService.validateChangedPercentualiByPosition] invalid percent. idCondominio={} index={} codice={} beforeSum={} afterSum={} tabelle={}",
                        after.getId(), i, codice, beforeSum, afterSum, dettaglioTabelle);
                throw new ValidationFailedException("invalid.percent." + codice);
            }
            if (changed) {
                final Condominio.ConfigurazioneSpesa cfg = afterList.get(i);
                final String codice = cfg == null || cfg.getCodice() == null ? "" : cfg.getCodice();
                log.info(
                        "[CondominioService.validateChangedPercentualiByPosition] percent changed. idCondominio={} index={} codice={} beforeSum={} afterSum={}",
                        after.getId(), i, codice, beforeSum, afterSum);
            }
        }
    }

    private Integer sumPercentuali(Condominio.ConfigurazioneSpesa cfg) {
        if (cfg == null || cfg.getTabelle() == null || cfg.getTabelle().isEmpty()) {
            return null;
        }
        long valued = cfg.getTabelle().stream()
                .filter(tabella -> tabella != null && tabella.getPercentuale() != null)
                .count();
        if (valued == 0) {
            return null;
        }
        return cfg.getTabelle().stream()
                .filter(tabella -> tabella != null && tabella.getPercentuale() != null)
                .mapToInt(Condominio.ConfigurazioneSpesa.TabellaPercentuale::getPercentuale)
                .sum();
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
