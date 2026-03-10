package it.condomio.service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import it.condomio.controller.model.MorositaItemResource;
import it.condomio.controller.model.MorositaSollecitoRequest;
import it.condomio.document.Condomino;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominoRepository;

/**
 * Verticale morosita':
 * - vista aging debito per esercizio
 * - gestione stato pratica (`IN_BONIS`, `SOLLECITATO`, `LEGALE`)
 * - storico solleciti manuali/automatici
 */
@Service
public class MorositaService {

    private final CondominoRepository condominoRepository;
    private final TenantAccessService tenantAccessService;
    private final EsercizioGuardService esercizioGuardService;

    public MorositaService(
            CondominoRepository condominoRepository,
            TenantAccessService tenantAccessService,
            EsercizioGuardService esercizioGuardService) {
        this.condominoRepository = condominoRepository;
        this.tenantAccessService = tenantAccessService;
        this.esercizioGuardService = esercizioGuardService;
    }

    public List<MorositaItemResource> listByExercise(String idCondominio, String keycloakUserId) throws ApiException {
        if (idCondominio == null || idCondominio.isBlank()) {
            throw new ValidationFailedException("validation.required.morosita.idCondominio");
        }
        if (!tenantAccessService.canViewCondominio(keycloakUserId, idCondominio)) {
            throw new ForbiddenException();
        }

        final boolean isOwner = tenantAccessService.ownsCondominio(keycloakUserId, idCondominio);
        List<Condomino> positions = condominoRepository.findByIdCondominioOrderByCognomeAscNomeAsc(idCondominio);
        if (!isOwner) {
            positions = positions.stream()
                    .filter(position -> keycloakUserId.equals(position.getKeycloakUserId()))
                    .toList();
        }

        List<MorositaItemResource> rows = new ArrayList<>();
        for (Condomino position : positions) {
            rows.add(toMorositaRow(position));
        }
        rows.sort(Comparator
                .comparing(MorositaItemResource::getDebitoScaduto, Comparator.nullsLast(Comparator.reverseOrder()))
                .thenComparing(MorositaItemResource::getNominativo, String.CASE_INSENSITIVE_ORDER));
        return rows;
    }

    @Transactional
    public void updateStato(
            String condominoId,
            Condomino.MorositaStato stato,
            String keycloakUserId) throws ApiException {
        if (stato == null) {
            throw new ValidationFailedException("validation.required.morosita.stato");
        }
        Condomino position = loadAdminOwnedPosition(condominoId, keycloakUserId);
        long updated = condominoRepository.setMorositaStatoByIdAndCondominio(
                position.getId(),
                position.getIdCondominio(),
                stato);
        if (updated <= 0) {
            position.setMorositaStato(stato);
            condominoRepository.save(position);
        }
    }

    @Transactional
    public void addSollecito(
            String condominoId,
            MorositaSollecitoRequest request,
            String keycloakUserId) throws ApiException {
        Condomino position = loadAdminOwnedPosition(condominoId, keycloakUserId);
        Condomino.Sollecito sollecito = normalizeSollecito(request);
        long updated = condominoRepository.addSollecitoByIdAndCondominio(
                position.getId(),
                position.getIdCondominio(),
                sollecito);
        if (updated <= 0) {
            List<Condomino.Sollecito> fallback = position.getSolleciti() == null
                    ? new ArrayList<>()
                    : new ArrayList<>(position.getSolleciti());
            fallback.add(sollecito);
            position.setSolleciti(fallback);
            condominoRepository.save(position);
        }

        Condomino.MorositaStato current = position.getMorositaStato() == null
                ? Condomino.MorositaStato.IN_BONIS
                : position.getMorositaStato();
        if (current == Condomino.MorositaStato.IN_BONIS) {
            condominoRepository.setMorositaStatoByIdAndCondominio(
                    position.getId(),
                    position.getIdCondominio(),
                    Condomino.MorositaStato.SOLLECITATO);
        }
    }

    @Transactional
    public int generateAutomaticSolleciti(
            String idCondominio,
            int minDaysOverdue,
            String keycloakUserId) throws ApiException {
        esercizioGuardService.requireOwnedOpenExercise(idCondominio, keycloakUserId);
        List<Condomino> positions = condominoRepository.findByIdCondominio(idCondominio);
        int generated = 0;
        for (Condomino position : positions) {
            if (position == null || position.getStatoPosizione() != Condomino.PosizioneStato.ATTIVO) {
                continue;
            }
            DebtSnapshot debt = computeDebt(position);
            if (debt.debitoScaduto <= 0d || debt.maxRitardoGiorni < Math.max(0, minDaysOverdue)) {
                continue;
            }
            if (alreadyAutoSollecitatoToday(position.getSolleciti())) {
                continue;
            }
            Condomino.Sollecito auto = new Condomino.Sollecito();
            auto.setId(UUID.randomUUID().toString());
            auto.setCreatedAt(Instant.now());
            auto.setCanale("email");
            auto.setTitolo("Sollecito automatico");
            auto.setNote("Generato automaticamente per debito scaduto");
            auto.setAutomatico(Boolean.TRUE);
            condominoRepository.addSollecitoByIdAndCondominio(position.getId(), idCondominio, auto);
            Condomino.MorositaStato current = position.getMorositaStato() == null
                    ? Condomino.MorositaStato.IN_BONIS
                    : position.getMorositaStato();
            if (current == Condomino.MorositaStato.IN_BONIS) {
                condominoRepository.setMorositaStatoByIdAndCondominio(
                        position.getId(),
                        idCondominio,
                        Condomino.MorositaStato.SOLLECITATO);
            }
            generated++;
        }
        return generated;
    }

    private MorositaItemResource toMorositaRow(Condomino position) {
        DebtSnapshot debt = computeDebt(position);
        MorositaItemResource row = new MorositaItemResource();
        row.setCondominoId(position.getId());
        row.setIdCondominio(position.getIdCondominio());
        row.setNominativo(((position.getCognome() == null ? "" : position.getCognome()) + " "
                + (position.getNome() == null ? "" : position.getNome())).trim());
        row.setStatoPosizione(position.getStatoPosizione());
        row.setPraticaStato(position.getMorositaStato() == null
                ? Condomino.MorositaStato.IN_BONIS
                : position.getMorositaStato());
        row.setDebitoTotale(round2(debt.debitoTotale));
        row.setDebitoScaduto(round2(debt.debitoScaduto));
        row.setDebitoNonScaduto(round2(debt.debitoNonScaduto));
        row.setScaduto0_30(round2(debt.scaduto0_30));
        row.setScaduto31_60(round2(debt.scaduto31_60));
        row.setScaduto61_90(round2(debt.scaduto61_90));
        row.setScadutoOver90(round2(debt.scadutoOver90));
        row.setMassimoRitardoGiorni(debt.maxRitardoGiorni);
        row.setNumeroSolleciti(position.getSolleciti() == null ? 0 : position.getSolleciti().size());
        row.setUltimoSollecitoAt(lastSollecitoAt(position.getSolleciti()));
        return row;
    }

    private DebtSnapshot computeDebt(Condomino position) {
        double debitoTotale = 0d;
        double debitoScaduto = 0d;
        double debitoNonScaduto = 0d;
        double scaduto0_30 = 0d;
        double scaduto31_60 = 0d;
        double scaduto61_90 = 0d;
        double scadutoOver90 = 0d;
        int maxRitardo = 0;

        List<Condomino.Config.Rata> rate = position.getConfig() == null ? null : position.getConfig().getRate();
        if (rate != null) {
            for (Condomino.Config.Rata rata : rate) {
                if (rata == null) {
                    continue;
                }
                final double due = round2(safe(rata.getImporto()) - safe(rata.getIncassato()));
                if (due <= 0d) {
                    continue;
                }
                debitoTotale += due;
                if (rata.getScadenza() == null || !rata.getScadenza().isBefore(Instant.now())) {
                    debitoNonScaduto += due;
                    continue;
                }

                final int ritardo = (int) ChronoUnit.DAYS.between(
                        rata.getScadenza().atOffset(ZoneOffset.UTC).toLocalDate(),
                        LocalDate.now(ZoneOffset.UTC));
                maxRitardo = Math.max(maxRitardo, ritardo);
                debitoScaduto += due;
                if (ritardo <= 30) {
                    scaduto0_30 += due;
                } else if (ritardo <= 60) {
                    scaduto31_60 += due;
                } else if (ritardo <= 90) {
                    scaduto61_90 += due;
                } else {
                    scadutoOver90 += due;
                }
            }
        }

        return new DebtSnapshot(
                round2(debitoTotale),
                round2(debitoScaduto),
                round2(debitoNonScaduto),
                round2(scaduto0_30),
                round2(scaduto31_60),
                round2(scaduto61_90),
                round2(scadutoOver90),
                maxRitardo);
    }

    private Condomino loadAdminOwnedPosition(String condominoId, String keycloakUserId) throws ApiException {
        Condomino existing = condominoRepository.findById(condominoId)
                .orElseThrow(() -> new NotFoundException("condomino"));
        esercizioGuardService.requireOwnedOpenExercise(existing.getIdCondominio(), keycloakUserId);
        return existing;
    }

    private Condomino.Sollecito normalizeSollecito(MorositaSollecitoRequest request) throws ValidationFailedException {
        if (request == null) {
            throw new ValidationFailedException("validation.required.morosita.sollecito");
        }
        String canale = normalizeBlank(request.getCanale());
        String titolo = normalizeBlank(request.getTitolo());
        String note = normalizeBlank(request.getNote());
        if (canale == null) {
            throw new ValidationFailedException("validation.required.morosita.sollecito.canale");
        }
        if (titolo == null) {
            throw new ValidationFailedException("validation.required.morosita.sollecito.titolo");
        }
        Condomino.Sollecito out = new Condomino.Sollecito();
        out.setId(UUID.randomUUID().toString());
        out.setCreatedAt(Instant.now());
        out.setCanale(canale);
        out.setTitolo(titolo);
        out.setNote(note);
        out.setAutomatico(Boolean.TRUE.equals(request.getAutomatico()));
        return out;
    }

    private boolean alreadyAutoSollecitatoToday(List<Condomino.Sollecito> solleciti) {
        if (solleciti == null || solleciti.isEmpty()) {
            return false;
        }
        final LocalDate today = LocalDate.now(ZoneOffset.UTC);
        for (Condomino.Sollecito row : solleciti) {
            if (row == null || row.getCreatedAt() == null || !Boolean.TRUE.equals(row.getAutomatico())) {
                continue;
            }
            LocalDate day = row.getCreatedAt().atOffset(ZoneOffset.UTC).toLocalDate();
            if (today.equals(day)) {
                return true;
            }
        }
        return false;
    }

    private Instant lastSollecitoAt(List<Condomino.Sollecito> solleciti) {
        if (solleciti == null || solleciti.isEmpty()) {
            return null;
        }
        Instant max = null;
        for (Condomino.Sollecito row : solleciti) {
            if (row == null || row.getCreatedAt() == null) {
                continue;
            }
            if (max == null || row.getCreatedAt().isAfter(max)) {
                max = row.getCreatedAt();
            }
        }
        return max;
    }

    private String normalizeBlank(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private double safe(Double value) {
        return value == null ? 0d : value;
    }

    private double round2(double value) {
        return Math.round(value * 100d) / 100d;
    }

    private record DebtSnapshot(
            double debitoTotale,
            double debitoScaduto,
            double debitoNonScaduto,
            double scaduto0_30,
            double scaduto31_60,
            double scaduto61_90,
            double scadutoOver90,
            int maxRitardoGiorni) {
    }
}

