package it.condomio.service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.Locale;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import it.condomio.document.Condominio;
import it.condomio.document.Condomino;
import it.condomio.document.Tabella;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominoRepository;
import it.condomio.repository.TabellaRepository;
import it.condomio.util.JsonMergePatchHelper;
import tools.jackson.databind.JsonNode;

@Service
public class TabellaService {

    @Autowired
    private TabellaRepository tabellaRepository;

    @Autowired
    private CondominioRepository condominioRepository;

    @Autowired
    private CondominoRepository condominoRepository;

    @Autowired
    private TenantAccessService tenantAccessService;

    @Autowired
    private EsercizioGuardService esercizioGuardService;

    public Tabella createTabella(Tabella tabella, String keycloakUserId) throws ApiException {
        validateTabella(tabella);
        ensureAdminOwnsCondominio(tabella.getIdCondominio(), keycloakUserId);
        ensureUniqueCodice(tabella.getIdCondominio(), tabella.getCodice(), null);
        tabella.setId(null);
        tabella.setVersion(null);
        return tabellaRepository.save(tabella);
    }

    public Optional<Tabella> getTabellaById(String id, String keycloakUserId) {
        List<String> visibleCondominioIds = tenantAccessService.findVisibleCondominioIds(keycloakUserId);
        if (visibleCondominioIds.isEmpty()) {
            return Optional.empty();
        }
        return tabellaRepository.findByIdAndIdCondominioIn(id, visibleCondominioIds);
    }

    public List<Tabella> getAllTabelle(String keycloakUserId, String idCondominio) {
        if (idCondominio != null && !idCondominio.isBlank()) {
            if (!tenantAccessService.canViewCondominio(keycloakUserId, idCondominio)) {
                return List.of();
            }
            return tabellaRepository.findByIdCondominioOrderByCodiceAsc(idCondominio);
        }
        List<String> visibleCondominioIds = tenantAccessService.findVisibleCondominioIds(keycloakUserId);
        if (visibleCondominioIds.isEmpty()) {
            return List.of();
        }
        return tabellaRepository.findByIdCondominioIn(visibleCondominioIds);
    }

    @Transactional
    public Tabella updateTabella(String id, Tabella updatedTabella, String keycloakUserId) throws ApiException {
        Optional<Tabella> existingOpt = tabellaRepository.findById(id);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("tabella");
        }
        Tabella existing = existingOpt.get();
        ensureAdminOwnsCondominio(existing.getIdCondominio(), keycloakUserId);
        final String oldCodice = existing.getCodice();
        final boolean codiceChanged = isCodiceChanged(existing, updatedTabella);
        final boolean descrizioneChanged = isDescrizioneChanged(existing, updatedTabella);
        updatedTabella.setIdCondominio(existing.getIdCondominio());
        updatedTabella.setVersion(existing.getVersion());
        validateTabella(updatedTabella);
        ensureUniqueCodice(existing.getIdCondominio(), updatedTabella.getCodice(), existing.getId());
        updatedTabella.setId(id);
        Tabella saved = tabellaRepository.save(updatedTabella);
        if (codiceChanged) {
            propagateTabellaRename(
                    saved.getIdCondominio(),
                    oldCodice,
                    saved.getCodice(),
                    saved.getDescrizione());
        } else if (descrizioneChanged) {
            propagateTabellaDescription(saved.getIdCondominio(), saved.getCodice(), saved.getDescrizione());
        }
        return saved;
    }

    public void deleteTabella(String id, String keycloakUserId) throws ApiException {
        Optional<Tabella> existingOpt = tabellaRepository.findById(id);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("tabella");
        }
        Tabella existing = existingOpt.get();
        ensureAdminOwnsCondominio(existing.getIdCondominio(), keycloakUserId);
        if (isTabellaCodiceReferenced(existing.getIdCondominio(), existing.getCodice())) {
            throw new ValidationFailedException("validation.inuse.tabella.codice");
        }
        tabellaRepository.deleteById(id);
    }

    @Transactional
    public Tabella patch(String id, JsonNode mergePatch, String keycloakUserId)
            throws IOException, ValidationFailedException, ApiException {
        Optional<Tabella> optionalTabella = tabellaRepository.findById(id);
        if (optionalTabella.isEmpty()) {
            throw new NotFoundException("tabella");
        }
        Tabella existing = optionalTabella.get();
        ensureAdminOwnsCondominio(existing.getIdCondominio(), keycloakUserId);
        Tabella patchedTabella = JsonMergePatchHelper.applyMergePatch(mergePatch, existing, Tabella.class);
        final String oldCodice = existing.getCodice();
        final boolean codiceChanged = isCodiceChanged(existing, patchedTabella);
        final boolean descrizioneChanged = isDescrizioneChanged(existing, patchedTabella);
        patchedTabella.setId(existing.getId());
        patchedTabella.setVersion(existing.getVersion());
        patchedTabella.setIdCondominio(existing.getIdCondominio());
        validateTabella(patchedTabella);
        ensureUniqueCodice(existing.getIdCondominio(), patchedTabella.getCodice(), existing.getId());
        Tabella saved = tabellaRepository.save(patchedTabella);
        if (codiceChanged) {
            propagateTabellaRename(
                    saved.getIdCondominio(),
                    oldCodice,
                    saved.getCodice(),
                    saved.getDescrizione());
        } else if (descrizioneChanged) {
            propagateTabellaDescription(saved.getIdCondominio(), saved.getCodice(), saved.getDescrizione());
        }
        return saved;
    }

    /**
     * Cleanup hard-references e delete tabella.
     * Usato dalla UI quando l'utente sceglie "rimuovi automaticamente".
     */
    public void deleteTabellaWithCleanup(String id, String keycloakUserId) throws ApiException {
        Optional<Tabella> existingOpt = tabellaRepository.findById(id);
        if (existingOpt.isEmpty()) {
            throw new NotFoundException("tabella");
        }
        Tabella existing = existingOpt.get();
        ensureAdminOwnsCondominio(existing.getIdCondominio(), keycloakUserId);
        removeTabellaReferences(existing.getIdCondominio(), existing.getCodice());
        tabellaRepository.deleteById(id);
    }

    private void ensureAdminOwnsCondominio(String condominioId, String keycloakUserId) throws ApiException {
        if (condominioId == null || condominioId.isBlank()) {
            throw new ValidationFailedException("validation.required.tabella.idCondominio");
        }
        esercizioGuardService.requireOwnedOpenExercise(condominioId, keycloakUserId);
    }

    private void validateTabella(Tabella tabella) throws ValidationFailedException {
        if (tabella.getIdCondominio() == null || tabella.getIdCondominio().isBlank()) {
            throw new ValidationFailedException("validation.required.tabella.idCondominio");
        }
        if (tabella.getCodice() == null || tabella.getCodice().isBlank()) {
            throw new ValidationFailedException("validation.required.tabella.codice");
        }
    }

    private void ensureUniqueCodice(String idCondominio, String codice, String excludeId)
            throws ValidationFailedException {
        if (excludeId == null || excludeId.isBlank()) {
            if (tabellaRepository.existsByIdCondominioAndCodiceIgnoreCase(idCondominio, codice)) {
                throw new ValidationFailedException("validation.duplicate.tabella.codice");
            }
            return;
        }
        if (tabellaRepository.existsByIdCondominioAndCodiceIgnoreCaseAndIdNot(idCondominio, codice, excludeId)) {
            throw new ValidationFailedException("validation.duplicate.tabella.codice");
        }
    }

    private boolean isCodiceChanged(Tabella existing, Tabella updated) {
        final String before = normalize(existing.getCodice());
        final String after = normalize(updated.getCodice());
        return !before.equals(after);
    }

    private boolean isDescrizioneChanged(Tabella existing, Tabella updated) {
        final String before = existing.getDescrizione() == null ? "" : existing.getDescrizione().trim();
        final String after = updated.getDescrizione() == null ? "" : updated.getDescrizione().trim();
        return !before.equals(after);
    }

    private boolean isTabellaCodiceReferenced(String idCondominio, String codiceTabella) {
        final String code = normalize(codiceTabella);
        if (code.isBlank()) {
            return false;
        }

        final Optional<Condominio> condominioOpt = condominioRepository.findById(idCondominio);
        if (condominioOpt.isPresent() && condominioOpt.get().getConfigurazioniSpesa() != null) {
            for (Condominio.ConfigurazioneSpesa cfg : condominioOpt.get().getConfigurazioniSpesa()) {
                if (cfg == null || cfg.getTabelle() == null) {
                    continue;
                }
                for (Condominio.ConfigurazioneSpesa.TabellaPercentuale t : cfg.getTabelle()) {
                    if (t != null && code.equals(normalize(t.getCodice()))) {
                        return true;
                    }
                }
            }
        }

        final List<Condomino> condomini = condominoRepository.findByIdCondominio(idCondominio);
        for (Condomino c : condomini) {
            if (c.getConfig() == null || c.getConfig().getTabelle() == null) {
                continue;
            }
            for (Condomino.Config.TabellaConfig tc : c.getConfig().getTabelle()) {
                if (tc == null || tc.getTabella() == null) {
                    continue;
                }
                if (code.equals(normalize(tc.getTabella().getCodice()))) {
                    return true;
                }
            }
        }
        return false;
    }

    private void removeTabellaReferences(String idCondominio, String codiceTabella) {
        final String code = normalize(codiceTabella);

        // 1) Condominio.configurazioniSpesa.tabelle
        Optional<Condominio> condominioOpt = condominioRepository.findById(idCondominio);
        if (condominioOpt.isPresent() && condominioOpt.get().getConfigurazioniSpesa() != null) {
            Condominio condominio = condominioOpt.get();
            List<Condominio.ConfigurazioneSpesa> cleanedConfigurazioni = new java.util.ArrayList<>();
            for (Condominio.ConfigurazioneSpesa cfg : condominio.getConfigurazioniSpesa()) {
                if (cfg == null || cfg.getTabelle() == null) {
                    continue;
                }
                List<Condominio.ConfigurazioneSpesa.TabellaPercentuale> cleanedTabelle = new java.util.ArrayList<>();
                for (Condominio.ConfigurazioneSpesa.TabellaPercentuale t : cfg.getTabelle()) {
                    if (t == null || code.equals(normalize(t.getCodice()))) {
                        continue;
                    }
                    cleanedTabelle.add(t);
                }
                if (!cleanedTabelle.isEmpty()) {
                    cfg.setTabelle(cleanedTabelle);
                    cleanedConfigurazioni.add(cfg);
                }
            }
            condominio.setConfigurazioniSpesa(cleanedConfigurazioni);
            condominioRepository.save(condominio);
        }

        // 2) Condomino.config.tabelle
        List<Condomino> condomini = condominoRepository.findByIdCondominio(idCondominio);
        for (Condomino c : condomini) {
            if (c.getConfig() == null || c.getConfig().getTabelle() == null) {
                continue;
            }
            List<Condomino.Config.TabellaConfig> cleaned = new java.util.ArrayList<>();
            for (Condomino.Config.TabellaConfig tc : c.getConfig().getTabelle()) {
                if (tc == null || tc.getTabella() == null) {
                    continue;
                }
                if (code.equals(normalize(tc.getTabella().getCodice()))) {
                    continue;
                }
                cleaned.add(tc);
            }
            c.getConfig().setTabelle(cleaned);
        }
        condominoRepository.saveAll(condomini);
    }

    private void propagateTabellaDescription(String idCondominio, String codiceTabella, String descrizione) {
        final String code = normalize(codiceTabella);

        Optional<Condominio> condominioOpt = condominioRepository.findById(idCondominio);
        if (condominioOpt.isPresent() && condominioOpt.get().getConfigurazioniSpesa() != null) {
            Condominio condominio = condominioOpt.get();
            for (Condominio.ConfigurazioneSpesa cfg : condominio.getConfigurazioniSpesa()) {
                if (cfg == null || cfg.getTabelle() == null) {
                    continue;
                }
                for (Condominio.ConfigurazioneSpesa.TabellaPercentuale t : cfg.getTabelle()) {
                    if (t != null && code.equals(normalize(t.getCodice()))) {
                        t.setDescrizione(descrizione);
                    }
                }
            }
            condominioRepository.save(condominio);
        }

        List<Condomino> condomini = condominoRepository.findByIdCondominio(idCondominio);
        for (Condomino c : condomini) {
            if (c.getConfig() == null || c.getConfig().getTabelle() == null) {
                continue;
            }
            for (Condomino.Config.TabellaConfig tc : c.getConfig().getTabelle()) {
                if (tc == null || tc.getTabella() == null) {
                    continue;
                }
                if (code.equals(normalize(tc.getTabella().getCodice()))) {
                    tc.getTabella().setDescrizione(descrizione);
                }
            }
        }
        condominoRepository.saveAll(condomini);
    }

    /**
     * Aggiorna in modo coerente tutti i riferimenti alla tabella rinominata:
     * - condominio.configurazioniSpesa.tabelle.{codice,descrizione}
     * - condomino.config.tabelle.tabella.{codice,descrizione}
     */
    private void propagateTabellaRename(
            String idCondominio,
            String oldCodiceTabella,
            String newCodiceTabella,
            String newDescrizione) {
        final String oldCode = normalize(oldCodiceTabella);

        Optional<Condominio> condominioOpt = condominioRepository.findById(idCondominio);
        if (condominioOpt.isPresent() && condominioOpt.get().getConfigurazioniSpesa() != null) {
            Condominio condominio = condominioOpt.get();
            for (Condominio.ConfigurazioneSpesa cfg : condominio.getConfigurazioniSpesa()) {
                if (cfg == null || cfg.getTabelle() == null) {
                    continue;
                }
                for (Condominio.ConfigurazioneSpesa.TabellaPercentuale t : cfg.getTabelle()) {
                    if (t != null && oldCode.equals(normalize(t.getCodice()))) {
                        t.setCodice(newCodiceTabella);
                        t.setDescrizione(newDescrizione);
                    }
                }
            }
            condominioRepository.save(condominio);
        }

        List<Condomino> condomini = condominoRepository.findByIdCondominio(idCondominio);
        for (Condomino c : condomini) {
            if (c.getConfig() == null || c.getConfig().getTabelle() == null) {
                continue;
            }
            for (Condomino.Config.TabellaConfig tc : c.getConfig().getTabelle()) {
                if (tc == null || tc.getTabella() == null) {
                    continue;
                }
                if (oldCode.equals(normalize(tc.getTabella().getCodice()))) {
                    tc.getTabella().setCodice(newCodiceTabella);
                    tc.getTabella().setDescrizione(newDescrizione);
                }
            }
        }
        condominoRepository.saveAll(condomini);
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        return value.trim().toLowerCase(Locale.ROOT);
    }
}
