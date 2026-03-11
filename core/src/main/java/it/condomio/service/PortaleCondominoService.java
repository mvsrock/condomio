package it.condomio.service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import it.condomio.controller.model.CondominoResource;
import it.condomio.controller.model.EstrattoContoResource;
import it.condomio.controller.model.PortaleCondominoSnapshotResponse;
import it.condomio.document.Condomino;
import it.condomio.document.Condominio;
import it.condomio.document.DocumentoArchivio;
import it.condomio.document.Movimenti;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominoRepository;
import it.condomio.repository.DocumentoArchivioRepository;
import it.condomio.repository.MovimentiRepository;

/**
 * Servizio self-service del portale condomino (Fase 7).
 *
 * Obiettivi:
 * - riusare logiche di dominio esistenti (estratto conto, tenant guard)
 * - evitare endpoint admin per costruire la vista personale
 * - garantire che il condomino legga solo dati pertinenti alla propria posizione
 */
@Service
public class PortaleCondominoService {

    private static final int MAX_DOCUMENTI_RECENTI = 25;
    private static final String APP_ROLE_STANDARD = "default-roles-condominio";

    private final CondominioRepository condominioRepository;
    private final CondominoRepository condominoRepository;
    private final MovimentiRepository movimentiRepository;
    private final DocumentoArchivioRepository documentoArchivioRepository;
    private final TenantAccessService tenantAccessService;
    private final CondominoService condominoService;

    public PortaleCondominoService(
            CondominioRepository condominioRepository,
            CondominoRepository condominoRepository,
            MovimentiRepository movimentiRepository,
            DocumentoArchivioRepository documentoArchivioRepository,
            TenantAccessService tenantAccessService,
            CondominoService condominoService) {
        this.condominioRepository = condominioRepository;
        this.condominoRepository = condominoRepository;
        this.movimentiRepository = movimentiRepository;
        this.documentoArchivioRepository = documentoArchivioRepository;
        this.tenantAccessService = tenantAccessService;
        this.condominoService = condominoService;
    }

    public PortaleCondominoSnapshotResponse getMySnapshot(
            String idCondominio,
            String requesterKeycloakUserId) throws ApiException {
        final String exerciseId = normalize(idCondominio);
        if (exerciseId == null) {
            throw new ValidationFailedException("validation.required.portale.idCondominio");
        }
        if (requesterKeycloakUserId == null || requesterKeycloakUserId.isBlank()) {
            throw new ForbiddenException();
        }
        final Condominio exercise = condominioRepository.findById(exerciseId)
                .orElseThrow(() -> new NotFoundException("esercizio"));
        if (!tenantAccessService.canViewCondominio(requesterKeycloakUserId, exerciseId)) {
            throw new ForbiddenException();
        }

        final Condomino myPosition = resolveMyPosition(exerciseId, requesterKeycloakUserId);
        final CondominoResource myResource = condominoService
                .getCondominoById(myPosition.getId(), requesterKeycloakUserId)
                .orElseThrow(() -> new NotFoundException("condomino"));
        final EstrattoContoResource estratto = condominoService.getEstrattoConto(
                myPosition.getId(),
                requesterKeycloakUserId);

        PortaleCondominoSnapshotResponse response = new PortaleCondominoSnapshotResponse();
        response.setIdCondominio(exercise.getId());
        response.setLabelCondominio(exercise.getLabel());
        response.setAnno(exercise.getAnno());
        response.setGestioneCodice(exercise.getGestioneCodice());
        response.setGestioneLabel(exercise.getGestioneLabel());
        response.setStatoEsercizio(exercise.getStato());
        response.setResiduoCondominio(round2(safe(exercise.getResiduo())));
        response.setGeneratedAt(Instant.now());

        response.setCondominoId(myResource.getId());
        response.setNominativo(buildNominativo(myResource.getNome(), myResource.getCognome()));
        response.setAppRole(normalizeAppRole(myResource.getAppRole()));
        response.setStatoPosizione(myResource.getStatoPosizione());
        response.setScala(myResource.getScala());
        response.setInterno(myResource.getInterno() == null ? null : String.valueOf(myResource.getInterno()));
        response.setSaldoInizialeCondomino(round2(safe(myResource.getSaldoIniziale())));
        response.setResiduoCondomino(round2(safe(myResource.getResiduo())));

        response.setTotaleRate(round2(estratto.getTotaleRate()));
        response.setTotaleIncassatoRate(round2(estratto.getTotaleIncassatoRate()));
        response.setScopertoRate(round2(estratto.getScopertoRate()));
        response.setTotaleVersamenti(round2(estratto.getTotaleVersamenti()));
        response.setRate(estratto.getRate() == null ? List.of() : estratto.getRate());
        response.setVersamenti(buildVersamentiRows(myResource));
        response.setMovimenti(buildMovimentiRows(exerciseId, myPosition.getId()));
        response.setDocumentiRecenti(buildDocumentiRows(exerciseId));
        return response;
    }

    private Condomino resolveMyPosition(String idCondominio, String keycloakUserId) throws ForbiddenException {
        final List<Condomino> mine = condominoRepository
                .findByIdCondominioAndKeycloakUserIdOrderByDataIngressoDesc(idCondominio, keycloakUserId);
        if (mine.isEmpty()) {
            throw new ForbiddenException();
        }
        Optional<Condomino> active = mine.stream()
                .filter(position -> position.getStatoPosizione() == null
                        || position.getStatoPosizione() == Condomino.PosizioneStato.ATTIVO)
                .findFirst();
        return active.orElse(mine.get(0));
    }

    private List<PortaleCondominoSnapshotResponse.VersamentoRow> buildVersamentiRows(CondominoResource resource) {
        if (resource.getVersamenti() == null || resource.getVersamenti().isEmpty()) {
            return List.of();
        }
        return resource.getVersamenti().stream()
                .sorted(Comparator
                        .comparing(Condomino.Versamento::getDate, Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(Condomino.Versamento::getInsertedAt, Comparator.nullsLast(Comparator.reverseOrder())))
                .map(item -> {
                    PortaleCondominoSnapshotResponse.VersamentoRow row =
                            new PortaleCondominoSnapshotResponse.VersamentoRow();
                    row.setId(item.getId());
                    row.setDescrizione(item.getDescrizione());
                    row.setRataId(item.getRataId());
                    row.setImporto(round2(safe(item.getImporto())));
                    row.setDate(item.getDate());
                    row.setInsertedAt(item.getInsertedAt());
                    return row;
                })
                .toList();
    }

    private List<PortaleCondominoSnapshotResponse.MovimentoQuotaRow> buildMovimentiRows(
            String idCondominio,
            String condominoId) {
        final List<Movimenti> rows = movimentiRepository.findByIdCondominioOrderByDateDesc(idCondominio);
        if (rows.isEmpty()) {
            return List.of();
        }
        final List<PortaleCondominoSnapshotResponse.MovimentoQuotaRow> out = new ArrayList<>();
        for (Movimenti movimento : rows) {
            if (movimento == null) {
                continue;
            }
            final Double quotaCondomino = resolveQuotaCondomino(movimento, condominoId);
            if (quotaCondomino == null) {
                continue;
            }
            PortaleCondominoSnapshotResponse.MovimentoQuotaRow row =
                    new PortaleCondominoSnapshotResponse.MovimentoQuotaRow();
            row.setMovimentoId(movimento.getId());
            row.setDate(movimento.getDate());
            row.setCodiceSpesa(movimento.getCodiceSpesa());
            row.setDescrizione(movimento.getDescrizione());
            row.setImportoTotale(round2(safe(movimento.getImporto())));
            row.setQuotaCondomino(round2(quotaCondomino));
            out.add(row);
        }
        return out;
    }

    private Double resolveQuotaCondomino(Movimenti movimento, String condominoId) {
        if (movimento.getRipartizioneCondomini() == null || movimento.getRipartizioneCondomini().isEmpty()) {
            return null;
        }
        for (Movimenti.RipartizioneCondomino split : movimento.getRipartizioneCondomini()) {
            if (split == null || split.getIdCondomino() == null) {
                continue;
            }
            if (split.getIdCondomino().equals(condominoId)) {
                return safe(split.getImporto());
            }
        }
        return null;
    }

    private List<PortaleCondominoSnapshotResponse.DocumentoRow> buildDocumentiRows(String idCondominio) {
        final List<DocumentoArchivio> rows = documentoArchivioRepository.findByIdCondominioOrderByCreatedAtDesc(idCondominio);
        if (rows.isEmpty()) {
            return List.of();
        }
        return rows.stream()
                .limit(MAX_DOCUMENTI_RECENTI)
                .map(item -> {
                    PortaleCondominoSnapshotResponse.DocumentoRow row =
                            new PortaleCondominoSnapshotResponse.DocumentoRow();
                    row.setDocumentoId(item.getId());
                    row.setTitolo(item.getTitolo());
                    row.setCategoria(item.getCategoria() == null ? "" : item.getCategoria().name());
                    row.setMovimentoId(item.getMovimentoId());
                    row.setVersionNumber(item.getVersionNumber());
                    row.setCreatedAt(item.getCreatedAt());
                    return row;
                })
                .toList();
    }

    private String normalizeAppRole(String appRole) {
        final String normalized = normalize(appRole);
        if (normalized == null || APP_ROLE_STANDARD.equalsIgnoreCase(normalized)) {
            return "standard";
        }
        return normalized;
    }

    private String buildNominativo(String nome, String cognome) {
        final String left = cognome == null ? "" : cognome.trim();
        final String right = nome == null ? "" : nome.trim();
        return (left + " " + right).trim();
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        final String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private double safe(Double value) {
        return value == null ? 0d : value;
    }

    private double round2(double value) {
        return Math.round(value * 100d) / 100d;
    }
}

