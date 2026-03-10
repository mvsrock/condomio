package it.condomio.service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import it.condomio.controller.model.PreventivoSnapshotResponse;
import it.condomio.controller.model.PreventivoUpsertRequest;
import it.condomio.document.Condominio;
import it.condomio.document.Movimenti;
import it.condomio.document.Preventivo;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.MovimentiRepository;
import it.condomio.repository.PreventivoRepository;

/**
 * Verticale preventivo/consuntivo esercizio.
 *
 * Regole:
 * - lettura: qualsiasi utente con visibilita' tenant sull'esercizio
 * - scrittura: solo admin proprietario e solo su esercizio OPEN
 * - confronto: consuntivo calcolato dai movimenti gia' registrati
 */
@Service
public class PreventivoService {

    private static final String INDIVIDUALE_TABLE_CODE = "__INDIVIDUALE__";
    private static final String INDIVIDUALE_TABLE_LABEL = "Riparto individuale";

    private final PreventivoRepository preventivoRepository;
    private final CondominioRepository condominioRepository;
    private final MovimentiRepository movimentiRepository;
    private final TenantAccessService tenantAccessService;
    private final EsercizioGuardService esercizioGuardService;

    public PreventivoService(
            PreventivoRepository preventivoRepository,
            CondominioRepository condominioRepository,
            MovimentiRepository movimentiRepository,
            TenantAccessService tenantAccessService,
            EsercizioGuardService esercizioGuardService) {
        this.preventivoRepository = preventivoRepository;
        this.condominioRepository = condominioRepository;
        this.movimentiRepository = movimentiRepository;
        this.tenantAccessService = tenantAccessService;
        this.esercizioGuardService = esercizioGuardService;
    }

    public PreventivoSnapshotResponse getSnapshot(String idCondominio, String keycloakUserId) throws ApiException {
        Condominio esercizio = requireVisibleExercise(idCondominio, keycloakUserId);
        Preventivo preventivo = preventivoRepository.findById(idCondominio).orElse(null);
        return buildSnapshot(esercizio, preventivo);
    }

    @Transactional
    public PreventivoSnapshotResponse saveSnapshot(
            String idCondominio,
            PreventivoUpsertRequest request,
            String keycloakUserId) throws ApiException {
        Condominio esercizio = esercizioGuardService.requireOwnedOpenExercise(idCondominio, keycloakUserId);
        List<Preventivo.Riga> normalizedRows = normalizeRequestRows(esercizio, request == null ? null : request.getRows());
        Preventivo payload = preventivoRepository.findById(idCondominio).orElseGet(Preventivo::new);
        payload.setIdCondominio(idCondominio);
        payload.setUpdatedAt(Instant.now());
        payload.setRighe(normalizedRows);
        Preventivo saved = preventivoRepository.save(payload);
        return buildSnapshot(esercizio, saved);
    }

    private Condominio requireVisibleExercise(String idCondominio, String keycloakUserId) throws ApiException {
        Condominio esercizio = condominioRepository.findById(idCondominio)
                .orElseThrow(() -> new NotFoundException("esercizio"));
        if (!tenantAccessService.canViewCondominio(keycloakUserId, idCondominio)) {
            throw new ForbiddenException();
        }
        return esercizio;
    }

    private List<Preventivo.Riga> normalizeRequestRows(
            Condominio esercizio,
            List<PreventivoUpsertRequest.Row> requestRows) throws ValidationFailedException {
        if (requestRows == null || requestRows.isEmpty()) {
            return List.of();
        }

        Set<RowKey> allowedKeys = configuredKeys(esercizio);
        Map<RowKey, Preventivo.Riga> dedup = new LinkedHashMap<>();

        for (PreventivoUpsertRequest.Row source : requestRows) {
            if (source == null) {
                continue;
            }
            String codiceSpesa = normalizeText(source.getCodiceSpesa());
            String codiceTabella = normalizeText(source.getCodiceTabella());
            String descrizioneTabella = normalizeText(source.getDescrizioneTabella());
            Double preventivo = source.getPreventivo();

            if (codiceSpesa == null) {
                throw new ValidationFailedException("validation.required.preventivo.codiceSpesa");
            }
            if (codiceTabella == null) {
                throw new ValidationFailedException("validation.required.preventivo.codiceTabella");
            }
            if (preventivo == null) {
                throw new ValidationFailedException("validation.required.preventivo.importo");
            }
            if (preventivo < 0) {
                throw new ValidationFailedException("validation.invalid.preventivo.importoNegative");
            }

            RowKey key = new RowKey(codiceSpesa, codiceTabella);
            if (!allowedKeys.contains(key)) {
                throw new ValidationFailedException("validation.invalid.preventivo.rowNotConfigured");
            }

            if (dedup.containsKey(key)) {
                throw new ValidationFailedException("validation.duplicate.preventivo.row");
            }

            Preventivo.Riga target = new Preventivo.Riga();
            target.setCodiceSpesa(codiceSpesa);
            target.setCodiceTabella(codiceTabella);
            target.setDescrizioneTabella(descrizioneTabella == null ? codiceTabella : descrizioneTabella);
            target.setImportoPreventivo(round2(preventivo));
            dedup.put(key, target);
        }

        List<Preventivo.Riga> out = new ArrayList<>(dedup.values());
        out.sort(Comparator
                .comparing(Preventivo.Riga::getCodiceSpesa, String.CASE_INSENSITIVE_ORDER)
                .thenComparing(Preventivo.Riga::getCodiceTabella, String.CASE_INSENSITIVE_ORDER));
        return out;
    }

    private PreventivoSnapshotResponse buildSnapshot(Condominio esercizio, Preventivo preventivo) {
        Map<RowKey, Double> preventivoMap = new LinkedHashMap<>();
        Map<RowKey, String> descrizioni = new LinkedHashMap<>();
        if (preventivo != null && preventivo.getRighe() != null) {
            for (Preventivo.Riga row : preventivo.getRighe()) {
                if (row == null) {
                    continue;
                }
                String codiceSpesa = normalizeText(row.getCodiceSpesa());
                String codiceTabella = normalizeText(row.getCodiceTabella());
                if (codiceSpesa == null || codiceTabella == null) {
                    continue;
                }
                RowKey key = new RowKey(codiceSpesa, codiceTabella);
                preventivoMap.put(key, round2(nullToZero(row.getImportoPreventivo())));
                descrizioni.put(key, normalizeText(row.getDescrizioneTabella()));
            }
        }

        Map<RowKey, Double> consuntivoMap = loadConsuntivoByKey(esercizio.getId());
        mergeConfiguredDescriptions(esercizio, descrizioni);

        Set<RowKey> keys = new LinkedHashSet<>();
        keys.addAll(descrizioni.keySet());
        keys.addAll(preventivoMap.keySet());
        keys.addAll(consuntivoMap.keySet());

        List<PreventivoSnapshotResponse.Row> rows = new ArrayList<>();
        double totalPreventivo = 0;
        double totalConsuntivo = 0;

        for (RowKey key : keys) {
            double preventivoValue = round2(preventivoMap.getOrDefault(key, 0d));
            double consuntivoValue = round2(consuntivoMap.getOrDefault(key, 0d));
            totalPreventivo += preventivoValue;
            totalConsuntivo += consuntivoValue;

            PreventivoSnapshotResponse.Row row = new PreventivoSnapshotResponse.Row();
            row.setCodiceSpesa(key.codiceSpesa());
            row.setCodiceTabella(key.codiceTabella());
            row.setDescrizioneTabella(resolveDescrizione(descrizioni.get(key), key.codiceTabella()));
            row.setPreventivo(preventivoValue);
            row.setConsuntivo(consuntivoValue);
            row.setDelta(round2(consuntivoValue - preventivoValue));
            rows.add(row);
        }

        rows.sort(Comparator
                .comparing(PreventivoSnapshotResponse.Row::getCodiceSpesa, String.CASE_INSENSITIVE_ORDER)
                .thenComparing(PreventivoSnapshotResponse.Row::getCodiceTabella, String.CASE_INSENSITIVE_ORDER));

        PreventivoSnapshotResponse response = new PreventivoSnapshotResponse();
        response.setIdCondominio(esercizio.getId());
        response.setAnno(esercizio.getAnno());
        response.setGestioneCodice(esercizio.getGestioneCodice());
        response.setGestioneLabel(esercizio.getGestioneLabel());
        response.setStatoEsercizio(esercizio.getStato());
        response.setUpdatedAt(preventivo == null ? null : preventivo.getUpdatedAt());
        response.setTotalePreventivo(round2(totalPreventivo));
        response.setTotaleConsuntivo(round2(totalConsuntivo));
        response.setTotaleDelta(round2(totalConsuntivo - totalPreventivo));
        response.setRows(rows);
        return response;
    }

    private Map<RowKey, Double> loadConsuntivoByKey(String idCondominio) {
        Map<RowKey, Double> out = new LinkedHashMap<>();
        List<Movimenti> movimenti = movimentiRepository.findByIdCondominio(idCondominio);
        for (Movimenti movimento : movimenti) {
            if (movimento == null) {
                continue;
            }
            String codiceSpesa = normalizeText(movimento.getCodiceSpesa());
            if (codiceSpesa == null) {
                continue;
            }
            if (movimento.getRipartizioneTabelle() == null || movimento.getRipartizioneTabelle().isEmpty()) {
                RowKey key = new RowKey(codiceSpesa, INDIVIDUALE_TABLE_CODE);
                out.put(key, round2(out.getOrDefault(key, 0d) + nullToZero(movimento.getImporto())));
                continue;
            }
            for (Movimenti.RipartizioneTabella split : movimento.getRipartizioneTabelle()) {
                if (split == null) {
                    continue;
                }
                String codiceTabella = normalizeText(split.getCodice());
                if (codiceTabella == null) {
                    continue;
                }
                RowKey key = new RowKey(codiceSpesa, codiceTabella);
                out.put(key, round2(out.getOrDefault(key, 0d) + nullToZero(split.getImporto())));
            }
        }
        return out;
    }

    private void mergeConfiguredDescriptions(Condominio esercizio, Map<RowKey, String> descrizioni) {
        if (esercizio == null || esercizio.getConfigurazioniSpesa() == null) {
            return;
        }
        for (Condominio.ConfigurazioneSpesa cfg : esercizio.getConfigurazioniSpesa()) {
            if (cfg == null) {
                continue;
            }
            String codiceSpesa = normalizeText(cfg.getCodice());
            if (codiceSpesa == null || cfg.getTabelle() == null) {
                continue;
            }
            descrizioni.putIfAbsent(
                    new RowKey(codiceSpesa, INDIVIDUALE_TABLE_CODE),
                    INDIVIDUALE_TABLE_LABEL);
            for (Condominio.ConfigurazioneSpesa.TabellaPercentuale split : cfg.getTabelle()) {
                if (split == null) {
                    continue;
                }
                String codiceTabella = normalizeText(split.getCodice());
                if (codiceTabella == null) {
                    continue;
                }
                RowKey key = new RowKey(codiceSpesa, codiceTabella);
                descrizioni.putIfAbsent(key, normalizeText(split.getDescrizione()));
            }
        }
    }

    private Set<RowKey> configuredKeys(Condominio esercizio) {
        Set<RowKey> out = new LinkedHashSet<>();
        if (esercizio == null || esercizio.getConfigurazioniSpesa() == null) {
            return out;
        }
        for (Condominio.ConfigurazioneSpesa cfg : esercizio.getConfigurazioniSpesa()) {
            if (cfg == null) {
                continue;
            }
            String codiceSpesa = normalizeText(cfg.getCodice());
            if (codiceSpesa == null || cfg.getTabelle() == null) {
                continue;
            }
            // Bucket opzionale per spese registrate in riparto individuale.
            out.add(new RowKey(codiceSpesa, INDIVIDUALE_TABLE_CODE));
            for (Condominio.ConfigurazioneSpesa.TabellaPercentuale split : cfg.getTabelle()) {
                if (split == null) {
                    continue;
                }
                String codiceTabella = normalizeText(split.getCodice());
                if (codiceTabella == null) {
                    continue;
                }
                out.add(new RowKey(codiceSpesa, codiceTabella));
            }
        }
        return out;
    }

    private String resolveDescrizione(String descrizione, String codiceTabella) {
        if (descrizione != null && !descrizione.isBlank()) {
            return descrizione;
        }
        if (Objects.equals(codiceTabella, INDIVIDUALE_TABLE_CODE)) {
            return INDIVIDUALE_TABLE_LABEL;
        }
        return codiceTabella;
    }

    private String normalizeText(String raw) {
        if (raw == null) {
            return null;
        }
        String trimmed = raw.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private double round2(double value) {
        return Math.round(value * 100d) / 100d;
    }

    private double nullToZero(Double value) {
        return value == null ? 0d : value;
    }

    private record RowKey(String codiceSpesa, String codiceTabella) {
    }
}
