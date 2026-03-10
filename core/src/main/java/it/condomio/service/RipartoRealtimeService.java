package it.condomio.service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.BulkOperations;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import it.condomio.document.Condominio;
import it.condomio.document.Condomino;
import it.condomio.document.Movimenti;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.CondominoRepository;
import it.condomio.repository.MovimentiRepository;

/**
 * Motore realtime di riparto:
 * - valorizza ripartizione tabelle + ripartizione condomini sul movimento.
 * - ricalcola residui di tutti i condomini del condominio target.
 * - aggiorna il residuo condominio includendo anche il saldo iniziale contabile.
 */
@Service
public class RipartoRealtimeService {
    private static final Logger log = LoggerFactory.getLogger(RipartoRealtimeService.class);

    @Autowired
    private CondominioRepository condominioRepository;

    @Autowired
    private CondominoRepository condominoRepository;

    @Autowired
    private MovimentiRepository movimentiRepository;

    @Autowired
    private MongoTemplate mongoTemplate;

    public Movimenti enrichMovimentoWithRiparto(Movimenti movimento) throws ValidationFailedException, NotFoundException {
        Condominio condominio = condominioRepository.findById(movimento.getIdCondominio())
                .orElseThrow(() -> new NotFoundException("condominio"));
        if (movimento.getDate() == null) {
            movimento.setDate(Instant.now());
        }
        if (movimento.getInsertedAt() == null) {
            movimento.setInsertedAt(Instant.now());
        }

        final Movimenti.RipartoTipo ripartoTipo = normalizeRipartoTipo(movimento);
        if (ripartoTipo == Movimenti.RipartoTipo.INDIVIDUALE) {
            final List<Condomino> condominiEffettivi = filterPositionsEffectiveAt(
                    condominoRepository.findByIdCondominio(movimento.getIdCondominio()),
                    movimento.getDate());
            final List<Movimenti.RipartizioneCondomino> quoteCondomino = validateAndNormalizeRipartoIndividuale(
                    movimento, condominiEffettivi);
            movimento.setRipartizioneTabelle(List.of());
            movimento.setRipartizioneCondomini(quoteCondomino);
            return movimento;
        }

        Condominio.ConfigurazioneSpesa configurazione = resolveConfigurazioneSpesa(condominio, movimento.getCodiceSpesa());
        final List<Movimenti.RipartizioneTabella> quoteTabella = buildRipartizioneTabella(configurazione, movimento);
        final List<Condomino> condomini = filterPositionsEffectiveAt(
                condominoRepository.findByIdCondominio(movimento.getIdCondominio()),
                movimento.getDate());
        final List<Movimenti.RipartizioneCondomino> quoteCondomino =
                buildRipartizioneCondomini(condomini, quoteTabella);
        movimento.setRipartizioneTabelle(quoteTabella);
        movimento.setRipartizioneCondomini(quoteCondomino);
        return movimento;
    }

    private Movimenti.RipartoTipo normalizeRipartoTipo(Movimenti movimento) {
        if (movimento.getTipoRiparto() == null) {
            movimento.setTipoRiparto(Movimenti.RipartoTipo.CONDOMINIALE);
        }
        return movimento.getTipoRiparto();
    }

    /**
     * Riparto individuale:
     * - il frontend invia direttamente le quote per condomino.
     * - qui validiamo ownership, attivita' alla data e coerenza totale importo.
     * - normalizziamo nominativo/importi per garantire snapshot consistente.
     */
    private List<Movimenti.RipartizioneCondomino> validateAndNormalizeRipartoIndividuale(
            Movimenti movimento,
            List<Condomino> condominiEffettiviAtDate) throws ValidationFailedException {
        final List<Movimenti.RipartizioneCondomino> input = movimento.getRipartizioneCondomini();
        if (input == null || input.isEmpty()) {
            throw new ValidationFailedException("validation.required.movimento.ripartizioneCondomini");
        }
        if (input.size() != 1) {
            throw new ValidationFailedException("validation.invalid.movimento.ripartizioneCondomini.singleRequired");
        }
        final Map<String, Condomino> condominoById = new HashMap<>();
        for (Condomino condomino : condominiEffettiviAtDate) {
            condominoById.put(condomino.getId(), condomino);
        }

        final Set<String> seen = new HashSet<>();
        final List<Movimenti.RipartizioneCondomino> normalized = new ArrayList<>();
        double total = 0d;
        for (Movimenti.RipartizioneCondomino quota : input) {
            if (quota == null || quota.getIdCondomino() == null || quota.getIdCondomino().isBlank()) {
                throw new ValidationFailedException("validation.required.movimento.ripartizioneCondomini.idCondomino");
            }
            final String idCondomino = quota.getIdCondomino().trim();
            if (!seen.add(idCondomino)) {
                throw new ValidationFailedException("validation.invalid.movimento.ripartizioneCondomini.duplicated");
            }
            final Condomino condomino = condominoById.get(idCondomino);
            if (condomino == null) {
                throw new ValidationFailedException("validation.invalid.movimento.ripartizioneCondomini.condominoNotAllowed");
            }
            final double importo = quota.getImporto() == null ? 0d : round2(quota.getImporto());
            if (importo < 0d) {
                throw new ValidationFailedException("validation.invalid.movimento.ripartizioneCondomini.importo");
            }
            total += importo;

            final Movimenti.RipartizioneCondomino normalizedQuota = new Movimenti.RipartizioneCondomino();
            normalizedQuota.setIdCondomino(idCondomino);
            normalizedQuota.setNominativo(buildNominativo(condomino));
            normalizedQuota.setImporto(importo);
            normalized.add(normalizedQuota);
        }
        final double expected = round2(movimento.getImporto() == null ? 0d : movimento.getImporto());
        if (Math.abs(round2(total) - expected) > 0.01d) {
            throw new ValidationFailedException(
                    "validation.invalid.movimento.ripartizioneCondomini.sumMismatch.expected="
                            + expected + ".actual=" + round2(total));
        }
        return normalized;
    }

    public void recomputeCondominioResidui(String idCondominio) throws NotFoundException {
        Condominio condominio = condominioRepository.findById(idCondominio)
                .orElseThrow(() -> new NotFoundException("condominio"));

        final List<Condomino> condomini = condominoRepository.findByIdCondominio(idCondominio);
        final List<Movimenti> movimenti = movimentiRepository.findByIdCondominio(idCondominio);
        final Map<String, Double> dovutoByCondomino = new HashMap<>();

        for (Movimenti mov : movimenti) {
            if (mov.getRipartizioneCondomini() == null) {
                continue;
            }
            for (Movimenti.RipartizioneCondomino quota : mov.getRipartizioneCondomini()) {
                if (quota == null || quota.getIdCondomino() == null || quota.getIdCondomino().isBlank()) {
                    continue;
                }
                final double importo = quota.getImporto() != null ? quota.getImporto() : 0d;
                dovutoByCondomino.merge(quota.getIdCondomino(), importo, Double::sum);
            }
        }

        double dovutoTotaleCondominio = 0d;
        double versatoTotaleCondominio = 0d;
        final BulkOperations condominoBulk = mongoTemplate.bulkOps(BulkOperations.BulkMode.UNORDERED, Condomino.class);
        int updatesCount = 0;
        for (Condomino condomino : condomini) {
            final double dovuto = dovutoByCondomino.getOrDefault(condomino.getId(), 0d);
            final double versato = sumVersamenti(condomino);
            final double saldoIniziale = condomino.getSaldoIniziale() == null ? 0d : condomino.getSaldoIniziale();
            // Saldo: positivo se ha versato piu' del dovuto, negativo se deve ancora pagare.
            // Include il saldo iniziale contabile del condomino.
            final double residuo = round2(saldoIniziale + versato - dovuto);
            // Update mirato: tocca solo il campo residuo del condomino atteso nel condominio corretto.
            final Query q = new Query(
                    Criteria.where("_id").is(condomino.getId())
                            .and("idCondominio").is(idCondominio));
            final Update u = new Update().set("residuo", residuo);
            condominoBulk.updateOne(q, u);
            updatesCount++;
            dovutoTotaleCondominio += dovuto;
            versatoTotaleCondominio += versato;
        }
        if (updatesCount > 0) {
            condominoBulk.execute();
        }

        final double saldoInizialeCondominio = condominio.getSaldoIniziale() == null ? 0d : condominio.getSaldoIniziale();
        // Regola condominio:
        // residuo = saldoInizialeCondominio + versatoTotaleCondomini - dovutoTotaleMovimenti.
        final double newCondominioResiduo = round2(
                saldoInizialeCondominio + versatoTotaleCondominio - dovutoTotaleCondominio);
        // Caso singolo e update omogeneo: usiamo repository @Query/@Update.
        condominioRepository.setResiduoById(idCondominio, newCondominioResiduo);
        condominio.setResiduo(newCondominioResiduo);
    }

    /**
     * Applica il delta residui dovuto alla variazione di un singolo movimento.
     *
     * Regola saldo: residuo = versato - dovuto
     * Quindi, per ogni condomino:
     * residuo += quotaVecchiaMovimento - quotaNuovaMovimento
     */
    public void applyMovimentoDelta(String idCondominio, Movimenti before, Movimenti after) throws NotFoundException {
        Condominio condominio = condominioRepository.findById(idCondominio)
                .orElseThrow(() -> new NotFoundException("condominio"));

        final Map<String, Double> beforeByCondomino = ripartoByCondomino(before);
        final Map<String, Double> afterByCondomino = ripartoByCondomino(after);
        final Map<String, Double> deltaByCondomino = new HashMap<>();
        for (String id : beforeByCondomino.keySet()) {
            deltaByCondomino.put(id, beforeByCondomino.getOrDefault(id, 0d));
        }
        for (String id : afterByCondomino.keySet()) {
            final double current = deltaByCondomino.getOrDefault(id, 0d);
            deltaByCondomino.put(id, current - afterByCondomino.getOrDefault(id, 0d));
        }

        // Update mirati su soli condomini realmente impattati dal movimento.
        final BulkOperations condominoBulk = mongoTemplate.bulkOps(BulkOperations.BulkMode.UNORDERED, Condomino.class);
        int updatesCount = 0;
        for (Map.Entry<String, Double> entry : deltaByCondomino.entrySet()) {
            final double delta = round2(entry.getValue());
            if (Math.abs(delta) <= 0.000001d) {
                continue;
            }
            final Query q = new Query(
                    Criteria.where("_id").is(entry.getKey())
                            .and("idCondominio").is(idCondominio));
            // Delta incrementale: residuo += (quotaVecchia - quotaNuova)
            final Update u = new Update().inc("residuo", delta);
            condominoBulk.updateOne(q, u);
            updatesCount++;
        }
        if (updatesCount > 0) {
            condominoBulk.execute();
        }

        final double oldTotal = sumMovimentoShares(beforeByCondomino);
        final double newTotal = sumMovimentoShares(afterByCondomino);
        final double condominioDelta = oldTotal - newTotal;
        if (Math.abs(condominioDelta) > 0.000001d) {
            // Caso singolo e update omogeneo: repository @Query/@Update con $inc.
            condominioRepository.incResiduoById(idCondominio, round2(condominioDelta));
        }
        final double currentCondominioResiduo = condominio.getResiduo() == null ? 0d : condominio.getResiduo();
        condominio.setResiduo(round2(currentCondominioResiduo + condominioDelta));
    }

    /**
     * Rebuild storico completo su un condominio:
     * - ricalcola ripartizione di TUTTI i movimenti con configurazioni/quote correnti
     * - poi ricalcola i residui globali.
     *
     * Nota "per anno":
     * nel dominio attuale ogni condominio e' gia' specifico per anno; quindi
     * l'operazione sul singolo idCondominio e' intrinsecamente scoped all'anno.
     */
    public void rebuildStoricoCondominio(String idCondominio) throws NotFoundException, ValidationFailedException {
        condominioRepository.findById(idCondominio)
                .orElseThrow(() -> new NotFoundException("condominio"));

        final List<Movimenti> movimenti = movimentiRepository.findByIdCondominio(idCondominio);
        if (!movimenti.isEmpty()) {
            final List<Movimenti> rebuilt = new ArrayList<>(movimenti.size());
            for (Movimenti m : movimenti) {
                rebuilt.add(enrichMovimentoWithRiparto(m));
            }
            movimentiRepository.saveAll(rebuilt);
            logRipartoCoerenza(idCondominio, rebuilt);
        }
        recomputeCondominioResidui(idCondominio);
    }

    private Condominio.ConfigurazioneSpesa resolveConfigurazioneSpesa(
            Condominio condominio,
            String codiceSpesa) throws ValidationFailedException {
        if (codiceSpesa == null || codiceSpesa.isBlank()) {
            throw new ValidationFailedException("validation.required.movimento.codiceSpesa");
        }
        if (condominio.getConfigurazioniSpesa() == null || condominio.getConfigurazioniSpesa().isEmpty()) {
            throw new ValidationFailedException("validation.required.condominio.configurazioniSpesa");
        }
        final String normalizedCode = codiceSpesa.trim().toLowerCase(Locale.ROOT);
        for (Condominio.ConfigurazioneSpesa c : condominio.getConfigurazioniSpesa()) {
            if (c == null || c.getCodice() == null) {
                continue;
            }
            if (normalizedCode.equals(c.getCodice().trim().toLowerCase(Locale.ROOT))) {
                if (c.getTabelle() == null || c.getTabelle().isEmpty()) {
                    throw new ValidationFailedException("validation.required.movimento.tabelleRiparto");
                }
                return c;
            }
        }
        throw new ValidationFailedException("validation.notfound.movimento.configurazioneSpesa");
    }

    private List<Movimenti.RipartizioneTabella> buildRipartizioneTabella(
            Condominio.ConfigurazioneSpesa configurazione,
            Movimenti movimento) {
        final List<Movimenti.RipartizioneTabella> result = new ArrayList<>();
        final List<Condominio.ConfigurazioneSpesa.TabellaPercentuale> tabelle = configurazione.getTabelle();
        double allocated = 0d;
        for (int i = 0; i < tabelle.size(); i++) {
            final Condominio.ConfigurazioneSpesa.TabellaPercentuale tabella = tabelle.get(i);
            if (tabella == null) {
                continue;
            }
            final double quota;
            if (i == tabelle.size() - 1) {
                // Correzione centesimi: garantisce che la somma quote tabella
                // sia sempre uguale all'importo del movimento.
                quota = round2(movimento.getImporto() - allocated);
            } else {
                final int percentuale = tabella.getPercentuale() != null ? tabella.getPercentuale() : 0;
                quota = round2((movimento.getImporto() * percentuale) / 100d);
                allocated += quota;
            }
            Movimenti.RipartizioneTabella rt = new Movimenti.RipartizioneTabella();
            rt.setCodice(tabella.getCodice());
            rt.setDescrizione(tabella.getDescrizione());
            rt.setImporto(quota);
            result.add(rt);
        }
        return result;
    }

    private List<Movimenti.RipartizioneCondomino> buildRipartizioneCondomini(
            List<Condomino> condomini,
            List<Movimenti.RipartizioneTabella> quoteTabella) throws ValidationFailedException {
        if (condomini.isEmpty()) {
            throw new ValidationFailedException("validation.required.riparto.condominiAttivi");
        }
        final Map<String, Double> quoteByCondomino = new HashMap<>();
        final Map<String, String> nominativi = new HashMap<>();

        for (Condomino condomino : condomini) {
            quoteByCondomino.put(condomino.getId(), 0d);
            nominativi.put(condomino.getId(), buildNominativo(condomino));
        }

        for (Movimenti.RipartizioneTabella quotaTabella : quoteTabella) {
            final String codiceTabella = quotaTabella.getCodice();
            if (codiceTabella == null || codiceTabella.isBlank()) {
                continue;
            }

            final Map<String, Condomino.Config.TabellaConfig> configByCondomino = new HashMap<>();
            final List<Condomino> partecipanti = new ArrayList<>();
            for (Condomino condomino : condomini) {
                Condomino.Config.TabellaConfig cfg = findConfigForTabella(condomino, codiceTabella);
                if (cfg != null && cfg.getNumeratore() != null && cfg.getDenominatore() != null
                        && cfg.getNumeratore() > 0d && cfg.getDenominatore() > 0d) {
                    configByCondomino.put(condomino.getId(), cfg);
                    partecipanti.add(condomino);
                }
            }
            // Regola dominio: un condomino puo' non partecipare a una specifica tabella.
            // In quel caso resta semplicemente a quota 0 per questa tabella.
            if (partecipanti.isEmpty()) {
                throw new ValidationFailedException(
                        "validation.required.riparto.quotaTabella." + codiceTabella + ".noPartecipanti");
            }

            // Riparto sui soli partecipanti: usiamo il peso reale num/den.
            // Non imponiamo piu' che tutti i condomini abbiano quote su questa tabella.
            final Map<String, Double> weightByCondomino = new HashMap<>();
            double totalWeight = 0d;
            for (Condomino condomino : partecipanti) {
                Condomino.Config.TabellaConfig cfg = configByCondomino.get(condomino.getId());
                final double num = cfg.getNumeratore();
                final double den = cfg.getDenominatore();
                final double weight = num / den;
                if (weight <= 0d || Double.isNaN(weight) || Double.isInfinite(weight)) {
                    continue;
                }
                weightByCondomino.put(condomino.getId(), weight);
                totalWeight += weight;
            }
            if (totalWeight <= 0d) {
                throw new ValidationFailedException(
                        "validation.required.riparto.quotaTabella." + codiceTabella + ".noPartecipanti");
            }

            // Riparto deterministico con correzione centesimi sull'ultimo partecipante.
            double allocated = 0d;
            for (int i = 0; i < partecipanti.size(); i++) {
                final Condomino condomino = partecipanti.get(i);
                final double weight = weightByCondomino.getOrDefault(condomino.getId(), 0d);
                if (weight <= 0d) {
                    continue;
                }
                final double share;
                if (i == partecipanti.size() - 1) {
                    share = round2(quotaTabella.getImporto() - allocated);
                } else {
                    share = round2(quotaTabella.getImporto() * (weight / totalWeight));
                    allocated += share;
                }
                quoteByCondomino.merge(condomino.getId(), share, Double::sum);
            }
        }

        final List<Movimenti.RipartizioneCondomino> result = new ArrayList<>();
        for (Condomino condomino : condomini) {
            Movimenti.RipartizioneCondomino rc = new Movimenti.RipartizioneCondomino();
            rc.setIdCondomino(condomino.getId());
            rc.setNominativo(nominativi.get(condomino.getId()));
            rc.setImporto(round2(quoteByCondomino.getOrDefault(condomino.getId(), 0d)));
            result.add(rc);
        }
        return result;
    }

    private Condomino.Config.TabellaConfig findConfigForTabella(Condomino condomino, String codiceTabella) {
        if (condomino.getConfig() == null || condomino.getConfig().getTabelle() == null) {
            return null;
        }
        for (Condomino.Config.TabellaConfig tc : condomino.getConfig().getTabelle()) {
            if (tc == null || tc.getTabella() == null || tc.getTabella().getCodice() == null) {
                continue;
            }
            if (!codiceTabella.equalsIgnoreCase(tc.getTabella().getCodice())) {
                continue;
            }
            return tc;
        }
        return null;
    }

    private double sumVersamenti(Condomino condomino) {
        if (condomino.getVersamenti() == null || condomino.getVersamenti().isEmpty()) {
            return 0d;
        }
        double total = 0d;
        for (Condomino.Versamento v : condomino.getVersamenti()) {
            if (v != null && v.getImporto() != null) {
                total += v.getImporto();
            }
        }
        return total;
    }

    /**
     * Il nominativo mostrato nei riparti usa lo snapshot sulla posizione: in
     * questo modo i rebuild storici restano autosufficienti senza join addizionali.
     */
    private String buildNominativo(Condomino condomino) {
        final String nome = condomino.getNome() != null ? condomino.getNome().trim() : "";
        final String cognome = condomino.getCognome() != null ? condomino.getCognome().trim() : "";
        final String full = (nome + " " + cognome).trim();
        return full.isEmpty() ? condomino.getId() : full;
    }

    private double round2(double value) {
        return Math.round(value * 100d) / 100d;
    }

    /**
     * Il riparto di un movimento deve considerare solo le posizioni valide alla
     * data del movimento, altrimenti un subentro nello stesso esercizio
     * riscriverebbe il passato durante il rebuild storico.
     */
    private List<Condomino> filterPositionsEffectiveAt(List<Condomino> source, Instant effectiveAt) {
        if (source == null || source.isEmpty()) {
            return List.of();
        }
        final Instant reference = effectiveAt == null ? Instant.now() : effectiveAt;
        final List<Condomino> result = new ArrayList<>();
        for (Condomino position : source) {
            if (position == null || !isPositionEffectiveAt(position, reference)) {
                continue;
            }
            result.add(position);
        }
        return result;
    }

    private boolean isPositionEffectiveAt(Condomino position, Instant effectiveAt) {
        if (position.getDataIngresso() != null && effectiveAt.isBefore(position.getDataIngresso())) {
            return false;
        }
        if (position.getDataUscita() != null && effectiveAt.isAfter(position.getDataUscita())) {
            return false;
        }
        return position.getStatoPosizione() == null
                || position.getStatoPosizione() == Condomino.PosizioneStato.ATTIVO
                || position.getDataUscita() != null;
    }

    private Map<String, Double> ripartoByCondomino(Movimenti movimento) {
        if (movimento == null || movimento.getRipartizioneCondomini() == null) {
            return Collections.emptyMap();
        }
        final Map<String, Double> result = new HashMap<>();
        for (Movimenti.RipartizioneCondomino r : movimento.getRipartizioneCondomini()) {
            if (r == null || r.getIdCondomino() == null || r.getIdCondomino().isBlank()) {
                continue;
            }
            final double importo = r.getImporto() == null ? 0d : r.getImporto();
            result.merge(r.getIdCondomino(), importo, Double::sum);
        }
        return result;
    }

    private double sumMovimentoShares(Map<String, Double> shares) {
        double total = 0d;
        for (double v : shares.values()) {
            total += v;
        }
        return round2(total);
    }

    /**
     * Check diagnostico post-rebuild:
     * somma importi movimento deve coincidere con somma quote condomini.
     * Se c'e' mismatch logghiamo warning dettagliato.
     */
    private void logRipartoCoerenza(String idCondominio, List<Movimenti> movimenti) {
        for (Movimenti movimento : movimenti) {
            final double totaleMovimento = round2(movimento.getImporto() == null ? 0d : movimento.getImporto());
            final double totaleQuote = sumMovimentoShares(ripartoByCondomino(movimento));
            if (Math.abs(totaleMovimento - totaleQuote) > 0.01d) {
                log.warn(
                        "[RipartoRealtimeService.rebuildStoricoCondominio] incoerenza quote movimento. idCondominio={} movimentoId={} importo={} sommaQuote={}",
                        idCondominio, movimento.getId(), totaleMovimento, totaleQuote);
            }
        }
    }
}
