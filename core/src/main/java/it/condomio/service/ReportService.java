package it.condomio.service;

import java.io.ByteArrayOutputStream;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

import it.condomio.controller.model.EstrattoContoResource;
import it.condomio.controller.model.MorositaItemResource;
import it.condomio.controller.model.PreventivoSnapshotResponse;
import it.condomio.controller.model.ReportSnapshotResponse;
import it.condomio.document.Condominio;
import it.condomio.document.Condomino;
import it.condomio.document.Movimenti;
import it.condomio.exception.ApiException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominoRepository;
import it.condomio.repository.MovimentiRepository;

/**
 * Servizio reportistica professionale (fase 6).
 *
 * Contratto:
 * - tenant guard lato server (owner admin) prima di ogni elaborazione
 * - snapshot coerente e riutilizzabile sia per UI che per export
 * - export nativi PDF/XLSX senza dipendenze da strumenti esterni
 */
@Service
public class ReportService {

    private static final String INDIVIDUALE_TABLE_CODE = "__INDIVIDUALE__";
    private static final String INDIVIDUALE_TABLE_LABEL = "Riparto individuale";

    private final EsercizioGuardService esercizioGuardService;
    private final CondominoRepository condominoRepository;
    private final MovimentiRepository movimentiRepository;
    private final PreventivoService preventivoService;
    private final MorositaService morositaService;

    public ReportService(
            EsercizioGuardService esercizioGuardService,
            CondominoRepository condominoRepository,
            MovimentiRepository movimentiRepository,
            PreventivoService preventivoService,
            MorositaService morositaService) {
        this.esercizioGuardService = esercizioGuardService;
        this.condominoRepository = condominoRepository;
        this.movimentiRepository = movimentiRepository;
        this.preventivoService = preventivoService;
        this.morositaService = morositaService;
    }

    public ReportSnapshotResponse getSnapshot(
            String idCondominio,
            String requesterKeycloakUserId,
            String condominoId) throws ApiException {
        if (idCondominio == null || idCondominio.isBlank()) {
            throw new ValidationFailedException("validation.required.report.idCondominio");
        }
        final Condominio esercizio = esercizioGuardService.requireOwnedExercise(idCondominio, requesterKeycloakUserId);
        final String normalizedCondominoId = normalizeBlank(condominoId);

        final List<Condomino> allPositions = condominoRepository.findByIdCondominioOrderByCognomeAscNomeAsc(idCondominio);
        final Condomino selectedPosition = findSelectedPosition(allPositions, normalizedCondominoId);
        final List<Condomino> positionsForEstratto = selectedPosition == null
                ? allPositions
                : List.of(selectedPosition);
        final List<Movimenti> movimenti = movimentiRepository.findByIdCondominio(idCondominio);
        final PreventivoSnapshotResponse preventivoSnapshot = preventivoService.getSnapshot(idCondominio, requesterKeycloakUserId);
        final List<MorositaItemResource> morositaItems = morositaService.listByExercise(idCondominio, requesterKeycloakUserId);

        ReportSnapshotResponse response = new ReportSnapshotResponse();
        response.setIdCondominio(esercizio.getId());
        response.setLabel(esercizio.getLabel());
        response.setAnno(esercizio.getAnno());
        response.setGestioneCodice(esercizio.getGestioneCodice());
        response.setGestioneLabel(esercizio.getGestioneLabel());
        response.setStatoEsercizio(esercizio.getStato());
        response.setGeneratedAt(Instant.now());
        response.setSituazioneContabile(buildSituazioneContabile(esercizio, allPositions, movimenti));
        response.setConsuntivoRows(
                preventivoSnapshot.getRows() == null
                        ? List.of()
                        : List.copyOf(preventivoSnapshot.getRows()));
        response.setRipartoPerTabella(buildRipartoPerTabellaRows(movimenti));
        response.setMorositaItems(filterMorositaItems(morositaItems, normalizedCondominoId));
        response.setEstrattiConto(buildEstrattoRows(positionsForEstratto));
        response.setQuotaCondominoTabelle(buildQuotaCondominoTabelle(movimenti, selectedPosition));
        return response;
    }

    public byte[] exportXlsx(
            String idCondominio,
            String requesterKeycloakUserId,
            String condominoId) throws ApiException {
        ReportSnapshotResponse snapshot = getSnapshot(idCondominio, requesterKeycloakUserId, condominoId);
        try (XSSFWorkbook workbook = new XSSFWorkbook();
                ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            buildXlsxWorkbook(workbook, snapshot);
            workbook.write(out);
            return out.toByteArray();
        } catch (Exception ex) {
            throw new ValidationFailedException("validation.invalid.report.exportXlsx");
        }
    }

    public byte[] exportPdf(
            String idCondominio,
            String requesterKeycloakUserId,
            String condominoId) throws ApiException {
        ReportSnapshotResponse snapshot = getSnapshot(idCondominio, requesterKeycloakUserId, condominoId);
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Document document = new Document(PageSize.A4.rotate(), 24f, 24f, 24f, 24f);
            PdfWriter.getInstance(document, out);
            document.open();
            appendPdfSections(document, snapshot);
            document.close();
            return out.toByteArray();
        } catch (DocumentException ex) {
            throw new ValidationFailedException("validation.invalid.report.exportPdf");
        } catch (Exception ex) {
            throw new ValidationFailedException("validation.invalid.report.exportPdf");
        }
    }

    private Condomino findSelectedPosition(List<Condomino> allPositions, String condominoId)
            throws NotFoundException {
        if (condominoId == null) {
            return null;
        }
        for (Condomino row : allPositions) {
            if (row != null && Objects.equals(condominoId, row.getId())) {
                return row;
            }
        }
        throw new NotFoundException("condomino");
    }

    private List<MorositaItemResource> filterMorositaItems(List<MorositaItemResource> rows, String condominoId) {
        if (rows == null || rows.isEmpty()) {
            return List.of();
        }
        if (condominoId == null) {
            return List.copyOf(rows);
        }
        return rows.stream()
                .filter(row -> Objects.equals(condominoId, row.getCondominoId()))
                .toList();
    }

    private ReportSnapshotResponse.SituazioneContabile buildSituazioneContabile(
            Condominio esercizio,
            List<Condomino> positions,
            List<Movimenti> movimenti) {
        double totaleSpese = 0d;
        for (Movimenti movimento : movimenti) {
            totaleSpese += safe(movimento == null ? null : movimento.getImporto());
        }

        double totaleVersamenti = 0d;
        double totaleRateEmesse = 0d;
        double totaleRateIncassate = 0d;
        int posizioniAttive = 0;
        int posizioniCessate = 0;

        for (Condomino position : positions) {
            if (position == null) {
                continue;
            }
            if (position.getStatoPosizione() == Condomino.PosizioneStato.CESSATO) {
                posizioniCessate++;
            } else {
                posizioniAttive++;
            }
            totaleVersamenti += sumVersamenti(position.getVersamenti());
            if (position.getConfig() != null && position.getConfig().getRate() != null) {
                for (Condomino.Config.Rata rata : position.getConfig().getRate()) {
                    if (rata == null) {
                        continue;
                    }
                    totaleRateEmesse += safe(rata.getImporto());
                    totaleRateIncassate += safe(rata.getIncassato());
                }
            }
        }

        ReportSnapshotResponse.SituazioneContabile out = new ReportSnapshotResponse.SituazioneContabile();
        out.setSaldoInizialeCondominio(round2(safe(esercizio.getSaldoIniziale())));
        out.setResiduoCondominio(round2(safe(esercizio.getResiduo())));
        out.setTotaleSpeseRegistrate(round2(totaleSpese));
        out.setTotaleVersamenti(round2(totaleVersamenti));
        out.setTotaleRateEmesse(round2(totaleRateEmesse));
        out.setTotaleRateIncassate(round2(totaleRateIncassate));
        out.setTotaleScopertoRate(round2(Math.max(0d, totaleRateEmesse - totaleRateIncassate)));
        out.setPosizioniAttive(posizioniAttive);
        out.setPosizioniCessate(posizioniCessate);
        return out;
    }

    private List<ReportSnapshotResponse.RipartoTabellaRow> buildRipartoPerTabellaRows(List<Movimenti> movimenti) {
        Map<RipartoRowKey, Double> acc = new LinkedHashMap<>();
        Map<RipartoRowKey, String> descrizioni = new LinkedHashMap<>();
        for (Movimenti movimento : movimenti) {
            if (movimento == null) {
                continue;
            }
            final String codiceSpesa = normalizeBlank(movimento.getCodiceSpesa());
            if (codiceSpesa == null) {
                continue;
            }
            if (movimento.getRipartizioneTabelle() == null || movimento.getRipartizioneTabelle().isEmpty()) {
                RipartoRowKey key = new RipartoRowKey(codiceSpesa, INDIVIDUALE_TABLE_CODE);
                descrizioni.putIfAbsent(key, INDIVIDUALE_TABLE_LABEL);
                acc.put(key, round2(acc.getOrDefault(key, 0d) + safe(movimento.getImporto())));
                continue;
            }
            for (Movimenti.RipartizioneTabella split : movimento.getRipartizioneTabelle()) {
                if (split == null) {
                    continue;
                }
                String codiceTabella = normalizeBlank(split.getCodice());
                if (codiceTabella == null) {
                    continue;
                }
                RipartoRowKey key = new RipartoRowKey(codiceSpesa, codiceTabella);
                descrizioni.putIfAbsent(key, normalizeBlank(split.getDescrizione()));
                acc.put(key, round2(acc.getOrDefault(key, 0d) + safe(split.getImporto())));
            }
        }

        List<ReportSnapshotResponse.RipartoTabellaRow> rows = new ArrayList<>();
        for (Map.Entry<RipartoRowKey, Double> entry : acc.entrySet()) {
            ReportSnapshotResponse.RipartoTabellaRow row = new ReportSnapshotResponse.RipartoTabellaRow();
            row.setCodiceSpesa(entry.getKey().codiceSpesa());
            row.setCodiceTabella(entry.getKey().codiceTabella());
            row.setDescrizioneTabella(resolveTabellaDescrizione(descrizioni.get(entry.getKey()), entry.getKey().codiceTabella()));
            row.setImportoTotale(round2(entry.getValue()));
            rows.add(row);
        }
        rows.sort(Comparator
                .comparing(ReportSnapshotResponse.RipartoTabellaRow::getCodiceSpesa, String.CASE_INSENSITIVE_ORDER)
                .thenComparing(ReportSnapshotResponse.RipartoTabellaRow::getCodiceTabella, String.CASE_INSENSITIVE_ORDER));
        return rows;
    }

    private List<ReportSnapshotResponse.EstrattoContoSummaryRow> buildEstrattoRows(List<Condomino> positions) {
        List<ReportSnapshotResponse.EstrattoContoSummaryRow> rows = new ArrayList<>();
        for (Condomino position : positions) {
            if (position == null) {
                continue;
            }
            EstrattoContoResource estratto = computeEstratto(position);
            ReportSnapshotResponse.EstrattoContoSummaryRow row = new ReportSnapshotResponse.EstrattoContoSummaryRow();
            row.setCondominoId(position.getId());
            row.setNominativo(buildNominativo(position.getNome(), position.getCognome()));
            row.setStatoPosizione(position.getStatoPosizione() == null ? "ATTIVO" : position.getStatoPosizione().name());
            row.setSaldoIniziale(round2(safe(position.getSaldoIniziale())));
            row.setResiduo(round2(safe(position.getResiduo())));
            row.setTotaleRate(round2(estratto.getTotaleRate()));
            row.setTotaleIncassatoRate(round2(estratto.getTotaleIncassatoRate()));
            row.setScopertoRate(round2(estratto.getScopertoRate()));
            row.setTotaleVersamenti(round2(estratto.getTotaleVersamenti()));
            rows.add(row);
        }
        rows.sort(Comparator.comparing(ReportSnapshotResponse.EstrattoContoSummaryRow::getNominativo, String.CASE_INSENSITIVE_ORDER));
        return rows;
    }

    private List<ReportSnapshotResponse.QuotaCondominoTabellaRow> buildQuotaCondominoTabelle(
            List<Movimenti> movimenti,
            Condomino selectedPosition) {
        if (selectedPosition == null) {
            return List.of();
        }
        List<ReportSnapshotResponse.QuotaCondominoTabellaRow> rows = new ArrayList<>();
        for (Movimenti movimento : movimenti) {
            if (movimento == null) {
                continue;
            }
            Movimenti.RipartizioneCondomino quotaMovimento = findQuotaMovimento(
                    movimento.getRipartizioneCondomini(),
                    selectedPosition.getId());
            if (quotaMovimento == null) {
                continue;
            }

            if (movimento.getRipartizioneTabelle() == null || movimento.getRipartizioneTabelle().isEmpty()) {
                ReportSnapshotResponse.QuotaCondominoTabellaRow row = new ReportSnapshotResponse.QuotaCondominoTabellaRow();
                row.setMovimentoId(movimento.getId());
                row.setDataMovimento(movimento.getDate());
                row.setCodiceSpesa(defaultString(movimento.getCodiceSpesa()));
                row.setDescrizioneMovimento(defaultString(movimento.getDescrizione()));
                row.setCodiceTabella(INDIVIDUALE_TABLE_CODE);
                row.setDescrizioneTabella(INDIVIDUALE_TABLE_LABEL);
                row.setImportoTabella(round2(safe(movimento.getImporto())));
                row.setNumeratore(1d);
                row.setDenominatore(1d);
                row.setQuotaCondominoTabella(round2(safe(quotaMovimento.getImporto())));
                row.setQuotaCondominoMovimento(round2(safe(quotaMovimento.getImporto())));
                rows.add(row);
                continue;
            }

            for (Movimenti.RipartizioneTabella split : movimento.getRipartizioneTabelle()) {
                if (split == null) {
                    continue;
                }
                final Condomino.Config.TabellaConfig cfg = findTabellaConfig(selectedPosition, split.getCodice());
                final double numeratore = safe(cfg == null ? null : cfg.getNumeratore());
                final double denominatore = safe(cfg == null ? null : cfg.getDenominatore());
                final double quotaTabella = denominatore <= 0d
                        ? 0d
                        : round2(safe(split.getImporto()) * (numeratore / denominatore));

                ReportSnapshotResponse.QuotaCondominoTabellaRow row = new ReportSnapshotResponse.QuotaCondominoTabellaRow();
                row.setMovimentoId(movimento.getId());
                row.setDataMovimento(movimento.getDate());
                row.setCodiceSpesa(defaultString(movimento.getCodiceSpesa()));
                row.setDescrizioneMovimento(defaultString(movimento.getDescrizione()));
                row.setCodiceTabella(defaultString(split.getCodice()));
                row.setDescrizioneTabella(resolveTabellaDescrizione(split.getDescrizione(), split.getCodice()));
                row.setImportoTabella(round2(safe(split.getImporto())));
                row.setNumeratore(round2(numeratore));
                row.setDenominatore(round2(denominatore));
                row.setQuotaCondominoTabella(quotaTabella);
                row.setQuotaCondominoMovimento(round2(safe(quotaMovimento.getImporto())));
                rows.add(row);
            }
        }
        rows.sort(Comparator
                .comparing(ReportSnapshotResponse.QuotaCondominoTabellaRow::getDataMovimento, Comparator.nullsLast(Comparator.reverseOrder()))
                .thenComparing(ReportSnapshotResponse.QuotaCondominoTabellaRow::getCodiceSpesa, String.CASE_INSENSITIVE_ORDER)
                .thenComparing(ReportSnapshotResponse.QuotaCondominoTabellaRow::getCodiceTabella, String.CASE_INSENSITIVE_ORDER));
        return rows;
    }

    private Movimenti.RipartizioneCondomino findQuotaMovimento(
            List<Movimenti.RipartizioneCondomino> rows,
            String condominoId) {
        if (rows == null || rows.isEmpty() || condominoId == null) {
            return null;
        }
        for (Movimenti.RipartizioneCondomino row : rows) {
            if (row != null && Objects.equals(condominoId, row.getIdCondomino())) {
                return row;
            }
        }
        return null;
    }

    private Condomino.Config.TabellaConfig findTabellaConfig(Condomino position, String codiceTabella) {
        if (position == null
                || position.getConfig() == null
                || position.getConfig().getTabelle() == null
                || codiceTabella == null) {
            return null;
        }
        final String expected = codiceTabella.trim().toLowerCase();
        for (Condomino.Config.TabellaConfig row : position.getConfig().getTabelle()) {
            if (row == null || row.getTabella() == null || row.getTabella().getCodice() == null) {
                continue;
            }
            if (expected.equals(row.getTabella().getCodice().trim().toLowerCase())) {
                return row;
            }
        }
        return null;
    }

    private EstrattoContoResource computeEstratto(Condomino position) {
        double totaleRate = 0d;
        double totaleIncassatoRate = 0d;
        List<Condomino.Config.Rata> rate = position.getConfig() == null ? null : position.getConfig().getRate();
        if (rate != null) {
            for (Condomino.Config.Rata rata : rate) {
                if (rata == null) {
                    continue;
                }
                totaleRate += safe(rata.getImporto());
                totaleIncassatoRate += safe(rata.getIncassato());
            }
        }
        EstrattoContoResource out = new EstrattoContoResource();
        out.setCondominoId(position.getId());
        out.setIdCondominio(position.getIdCondominio());
        out.setTotaleRate(round2(totaleRate));
        out.setTotaleIncassatoRate(round2(totaleIncassatoRate));
        out.setScopertoRate(round2(Math.max(0d, totaleRate - totaleIncassatoRate)));
        out.setTotaleVersamenti(round2(sumVersamenti(position.getVersamenti())));
        out.setRate(List.of());
        return out;
    }

    private void buildXlsxWorkbook(XSSFWorkbook workbook, ReportSnapshotResponse snapshot) {
        Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        CellStyle headerStyle = workbook.createCellStyle();
        headerStyle.setFont(headerFont);

        buildXlsxSituazioneSheet(workbook, headerStyle, snapshot);
        buildXlsxConsuntivoSheet(workbook, headerStyle, snapshot.getConsuntivoRows());
        buildXlsxRipartoSheet(workbook, headerStyle, snapshot.getRipartoPerTabella());
        buildXlsxMorositaSheet(workbook, headerStyle, snapshot.getMorositaItems());
        buildXlsxEstrattiSheet(workbook, headerStyle, snapshot.getEstrattiConto());
        buildXlsxQuoteCondominoSheet(workbook, headerStyle, snapshot.getQuotaCondominoTabelle());
    }

    private void buildXlsxSituazioneSheet(XSSFWorkbook workbook, CellStyle headerStyle, ReportSnapshotResponse snapshot) {
        Sheet sheet = workbook.createSheet("Situazione");
        int rowIndex = 0;
        rowIndex = writeSectionHeader(sheet, rowIndex, headerStyle, "Condominio", "Valore");
        rowIndex = writeKvRow(sheet, rowIndex, "Condominio", snapshot.getLabel());
        rowIndex = writeKvRow(sheet, rowIndex, "Anno", String.valueOf(snapshot.getAnno()));
        rowIndex = writeKvRow(sheet, rowIndex, "Gestione", defaultString(snapshot.getGestioneLabel()));
        rowIndex = writeKvRow(sheet, rowIndex, "Stato esercizio", snapshot.getStatoEsercizio() == null ? "" : snapshot.getStatoEsercizio().name());
        rowIndex = writeKvRow(sheet, rowIndex, "Generato il", formatInstant(snapshot.getGeneratedAt()));
        rowIndex += 1;

        ReportSnapshotResponse.SituazioneContabile s = snapshot.getSituazioneContabile();
        rowIndex = writeSectionHeader(sheet, rowIndex, headerStyle, "Indicatore", "Valore");
        rowIndex = writeKvRow(sheet, rowIndex, "Saldo iniziale condominio", euro(s == null ? null : s.getSaldoInizialeCondominio()));
        rowIndex = writeKvRow(sheet, rowIndex, "Residuo condominio", euro(s == null ? null : s.getResiduoCondominio()));
        rowIndex = writeKvRow(sheet, rowIndex, "Totale spese registrate", euro(s == null ? null : s.getTotaleSpeseRegistrate()));
        rowIndex = writeKvRow(sheet, rowIndex, "Totale versamenti", euro(s == null ? null : s.getTotaleVersamenti()));
        rowIndex = writeKvRow(sheet, rowIndex, "Totale rate emesse", euro(s == null ? null : s.getTotaleRateEmesse()));
        rowIndex = writeKvRow(sheet, rowIndex, "Totale rate incassate", euro(s == null ? null : s.getTotaleRateIncassate()));
        rowIndex = writeKvRow(sheet, rowIndex, "Totale scoperto rate", euro(s == null ? null : s.getTotaleScopertoRate()));
        rowIndex = writeKvRow(sheet, rowIndex, "Posizioni attive", String.valueOf(s == null ? 0 : s.getPosizioniAttive()));
        writeKvRow(sheet, rowIndex, "Posizioni cessate", String.valueOf(s == null ? 0 : s.getPosizioniCessate()));

        sheet.setColumnWidth(0, 9000);
        sheet.setColumnWidth(1, 5200);
    }

    private void buildXlsxConsuntivoSheet(
            XSSFWorkbook workbook,
            CellStyle headerStyle,
            List<PreventivoSnapshotResponse.Row> rows) {
        Sheet sheet = workbook.createSheet("Consuntivo");
        int rowIndex = 0;
        rowIndex = writeHeader(
                sheet,
                rowIndex,
                headerStyle,
                "Codice spesa",
                "Codice tabella",
                "Descrizione tabella",
                "Preventivo",
                "Consuntivo",
                "Delta");
        for (PreventivoSnapshotResponse.Row row : safeList(rows)) {
            Row target = sheet.createRow(rowIndex++);
            writeCell(target, 0, defaultString(row.getCodiceSpesa()));
            writeCell(target, 1, defaultString(row.getCodiceTabella()));
            writeCell(target, 2, defaultString(row.getDescrizioneTabella()));
            writeCell(target, 3, euro(row.getPreventivo()));
            writeCell(target, 4, euro(row.getConsuntivo()));
            writeCell(target, 5, euro(row.getDelta()));
        }
        sheet.setColumnWidth(0, 6000);
        sheet.setColumnWidth(1, 5000);
        sheet.setColumnWidth(2, 8000);
        sheet.setColumnWidth(3, 4200);
        sheet.setColumnWidth(4, 4200);
        sheet.setColumnWidth(5, 4200);
    }

    private void buildXlsxRipartoSheet(
            XSSFWorkbook workbook,
            CellStyle headerStyle,
            List<ReportSnapshotResponse.RipartoTabellaRow> rows) {
        Sheet sheet = workbook.createSheet("Riparto Tabelle");
        int rowIndex = 0;
        rowIndex = writeHeader(
                sheet,
                rowIndex,
                headerStyle,
                "Codice spesa",
                "Codice tabella",
                "Descrizione tabella",
                "Importo totale");
        for (ReportSnapshotResponse.RipartoTabellaRow row : safeList(rows)) {
            Row target = sheet.createRow(rowIndex++);
            writeCell(target, 0, defaultString(row.getCodiceSpesa()));
            writeCell(target, 1, defaultString(row.getCodiceTabella()));
            writeCell(target, 2, defaultString(row.getDescrizioneTabella()));
            writeCell(target, 3, euro(row.getImportoTotale()));
        }
        sheet.setColumnWidth(0, 6000);
        sheet.setColumnWidth(1, 5000);
        sheet.setColumnWidth(2, 8000);
        sheet.setColumnWidth(3, 4200);
    }

    private void buildXlsxMorositaSheet(
            XSSFWorkbook workbook,
            CellStyle headerStyle,
            List<MorositaItemResource> rows) {
        Sheet sheet = workbook.createSheet("Morosita");
        int rowIndex = 0;
        rowIndex = writeHeader(
                sheet,
                rowIndex,
                headerStyle,
                "Condomino",
                "Stato pratica",
                "Debito totale",
                "Debito scaduto",
                "Scaduto 0-30",
                "Scaduto 31-60",
                "Scaduto 61-90",
                "Scaduto >90",
                "Solleciti");
        for (MorositaItemResource row : safeList(rows)) {
            Row target = sheet.createRow(rowIndex++);
            writeCell(target, 0, defaultString(row.getNominativo()));
            writeCell(target, 1, row.getPraticaStato() == null ? "" : row.getPraticaStato().name());
            writeCell(target, 2, euro(row.getDebitoTotale()));
            writeCell(target, 3, euro(row.getDebitoScaduto()));
            writeCell(target, 4, euro(row.getScaduto0_30()));
            writeCell(target, 5, euro(row.getScaduto31_60()));
            writeCell(target, 6, euro(row.getScaduto61_90()));
            writeCell(target, 7, euro(row.getScadutoOver90()));
            writeCell(target, 8, String.valueOf(row.getNumeroSolleciti() == null ? 0 : row.getNumeroSolleciti()));
        }
        sheet.setColumnWidth(0, 7000);
        sheet.setColumnWidth(1, 4200);
        sheet.setColumnWidth(2, 4200);
        sheet.setColumnWidth(3, 4200);
        sheet.setColumnWidth(4, 4200);
        sheet.setColumnWidth(5, 4200);
        sheet.setColumnWidth(6, 4200);
        sheet.setColumnWidth(7, 4200);
        sheet.setColumnWidth(8, 3200);
    }

    private void buildXlsxEstrattiSheet(
            XSSFWorkbook workbook,
            CellStyle headerStyle,
            List<ReportSnapshotResponse.EstrattoContoSummaryRow> rows) {
        Sheet sheet = workbook.createSheet("Estratti");
        int rowIndex = 0;
        rowIndex = writeHeader(
                sheet,
                rowIndex,
                headerStyle,
                "Condomino",
                "Stato",
                "Saldo iniziale",
                "Residuo",
                "Totale rate",
                "Incassato rate",
                "Scoperto rate",
                "Totale versamenti");
        for (ReportSnapshotResponse.EstrattoContoSummaryRow row : safeList(rows)) {
            Row target = sheet.createRow(rowIndex++);
            writeCell(target, 0, defaultString(row.getNominativo()));
            writeCell(target, 1, defaultString(row.getStatoPosizione()));
            writeCell(target, 2, euro(row.getSaldoIniziale()));
            writeCell(target, 3, euro(row.getResiduo()));
            writeCell(target, 4, euro(row.getTotaleRate()));
            writeCell(target, 5, euro(row.getTotaleIncassatoRate()));
            writeCell(target, 6, euro(row.getScopertoRate()));
            writeCell(target, 7, euro(row.getTotaleVersamenti()));
        }
        sheet.setColumnWidth(0, 7000);
        sheet.setColumnWidth(1, 3200);
        sheet.setColumnWidth(2, 4200);
        sheet.setColumnWidth(3, 4200);
        sheet.setColumnWidth(4, 4200);
        sheet.setColumnWidth(5, 4200);
        sheet.setColumnWidth(6, 4200);
        sheet.setColumnWidth(7, 4200);
    }

    private void buildXlsxQuoteCondominoSheet(
            XSSFWorkbook workbook,
            CellStyle headerStyle,
            List<ReportSnapshotResponse.QuotaCondominoTabellaRow> rows) {
        if (rows == null || rows.isEmpty()) {
            return;
        }
        Sheet sheet = workbook.createSheet("Quote Condomino");
        final List<QuotaMovimentoGroup> groups = buildQuotaMovimentoGroups(rows);
        int rowIndex = 0;
        rowIndex = writeHeader(
                sheet,
                rowIndex,
                headerStyle,
                "Rif. spesa",
                "Data",
                "Codice spesa",
                "Descrizione",
                "Importo spesa",
                "Quota condomino",
                "Quadratura",
                "Tabella",
                "Quota tabella",
                "Millesimi",
                "Quota condomino tabella");
        for (QuotaMovimentoGroup group : groups) {
            Row summary = sheet.createRow(rowIndex++);
            writeCell(summary, 0, group.reference());
            writeCell(summary, 1, formatInstant(group.dataMovimento()));
            writeCell(summary, 2, defaultString(group.codiceSpesa()));
            writeCell(summary, 3, defaultString(group.descrizioneMovimento()));
            writeCell(summary, 4, euro(group.importoSpesa()));
            writeCell(summary, 5, euro(group.quotaCondominoMovimento()));
            writeCell(
                    summary,
                    6,
                    group.isBalanced()
                            ? "OK"
                            : "Delta " + euro(Math.abs(group.quotaCondominoTabellaTotale() - group.quotaCondominoMovimento())));
            for (ReportSnapshotResponse.QuotaCondominoTabellaRow row : group.rows()) {
                Row detail = sheet.createRow(rowIndex++);
                writeCell(detail, 0, group.reference());
                writeCell(detail, 7, defaultString(row.getCodiceTabella()));
                writeCell(detail, 8, euro(row.getImportoTabella()));
                writeCell(
                        detail,
                        9,
                        String.format(
                                java.util.Locale.US,
                                "%.2f/%.2f",
                                safe(row.getNumeratore()),
                                safe(row.getDenominatore())));
                writeCell(detail, 10, euro(row.getQuotaCondominoTabella()));
            }
            rowIndex += 1;
        }
        sheet.setColumnWidth(0, 3600);
        sheet.setColumnWidth(1, 5200);
        sheet.setColumnWidth(2, 5200);
        sheet.setColumnWidth(3, 7600);
        sheet.setColumnWidth(4, 4200);
        sheet.setColumnWidth(5, 5200);
        sheet.setColumnWidth(6, 3600);
        sheet.setColumnWidth(7, 5200);
        sheet.setColumnWidth(8, 4200);
        sheet.setColumnWidth(9, 4200);
        sheet.setColumnWidth(10, 5200);
    }

    private void appendPdfSections(Document document, ReportSnapshotResponse snapshot) throws DocumentException {
        document.add(new Paragraph("Condomio - Report esercizio"));
        document.add(new Paragraph("Condominio: " + defaultString(snapshot.getLabel())));
        document.add(new Paragraph("Anno: " + (snapshot.getAnno() == null ? "" : snapshot.getAnno())));
        document.add(new Paragraph("Gestione: " + defaultString(snapshot.getGestioneLabel())));
        document.add(new Paragraph("Generato il: " + formatInstant(snapshot.getGeneratedAt())));
        document.add(new Paragraph(" "));

        ReportSnapshotResponse.SituazioneContabile s = snapshot.getSituazioneContabile();
        document.add(new Paragraph("Situazione contabile"));
        PdfPTable situazione = new PdfPTable(new float[] { 4f, 2f });
        situazione.setWidthPercentage(100f);
        addPdfHeaderRow(situazione, "Indicatore", "Valore");
        addPdfValueRow(situazione, "Saldo iniziale condominio", euro(s == null ? null : s.getSaldoInizialeCondominio()));
        addPdfValueRow(situazione, "Residuo condominio", euro(s == null ? null : s.getResiduoCondominio()));
        addPdfValueRow(situazione, "Totale spese registrate", euro(s == null ? null : s.getTotaleSpeseRegistrate()));
        addPdfValueRow(situazione, "Totale versamenti", euro(s == null ? null : s.getTotaleVersamenti()));
        addPdfValueRow(situazione, "Totale rate emesse", euro(s == null ? null : s.getTotaleRateEmesse()));
        addPdfValueRow(situazione, "Totale rate incassate", euro(s == null ? null : s.getTotaleRateIncassate()));
        addPdfValueRow(situazione, "Totale scoperto rate", euro(s == null ? null : s.getTotaleScopertoRate()));
        addPdfValueRow(situazione, "Posizioni attive", String.valueOf(s == null ? 0 : s.getPosizioniAttive()));
        addPdfValueRow(situazione, "Posizioni cessate", String.valueOf(s == null ? 0 : s.getPosizioniCessate()));
        document.add(situazione);
        document.add(new Paragraph(" "));

        document.add(new Paragraph("Consuntivo"));
        PdfPTable consuntivo = new PdfPTable(new float[] { 2f, 2f, 3f, 2f, 2f, 2f });
        consuntivo.setWidthPercentage(100f);
        addPdfHeaderRow(consuntivo, "Spesa", "Tabella", "Descrizione", "Prev.", "Cons.", "Delta");
        for (PreventivoSnapshotResponse.Row row : safeList(snapshot.getConsuntivoRows())) {
            addPdfValueRow(consuntivo,
                    defaultString(row.getCodiceSpesa()),
                    defaultString(row.getCodiceTabella()),
                    defaultString(row.getDescrizioneTabella()),
                    euro(row.getPreventivo()),
                    euro(row.getConsuntivo()),
                    euro(row.getDelta()));
        }
        document.add(consuntivo);
        document.add(new Paragraph(" "));

        document.add(new Paragraph("Riparto per tabella"));
        PdfPTable riparto = new PdfPTable(new float[] { 2f, 2f, 3f, 2f });
        riparto.setWidthPercentage(100f);
        addPdfHeaderRow(riparto, "Spesa", "Tabella", "Descrizione", "Importo");
        for (ReportSnapshotResponse.RipartoTabellaRow row : safeList(snapshot.getRipartoPerTabella())) {
            addPdfValueRow(riparto,
                    defaultString(row.getCodiceSpesa()),
                    defaultString(row.getCodiceTabella()),
                    defaultString(row.getDescrizioneTabella()),
                    euro(row.getImportoTotale()));
        }
        document.add(riparto);
        document.add(new Paragraph(" "));

        document.add(new Paragraph("Morosita"));
        PdfPTable morosita = new PdfPTable(new float[] { 3f, 2f, 2f, 2f, 2f });
        morosita.setWidthPercentage(100f);
        addPdfHeaderRow(morosita, "Condomino", "Stato", "Debito", "Scaduto", "Solleciti");
        for (MorositaItemResource row : safeList(snapshot.getMorositaItems())) {
            addPdfValueRow(morosita,
                    defaultString(row.getNominativo()),
                    row.getPraticaStato() == null ? "" : row.getPraticaStato().name(),
                    euro(row.getDebitoTotale()),
                    euro(row.getDebitoScaduto()),
                    String.valueOf(row.getNumeroSolleciti() == null ? 0 : row.getNumeroSolleciti()));
        }
        document.add(morosita);
        document.add(new Paragraph(" "));

        document.add(new Paragraph("Estratti conto"));
        PdfPTable estratti = new PdfPTable(new float[] { 3f, 2f, 2f, 2f, 2f });
        estratti.setWidthPercentage(100f);
        addPdfHeaderRow(estratti, "Condomino", "Stato", "Residuo", "Scoperto rate", "Versamenti");
        for (ReportSnapshotResponse.EstrattoContoSummaryRow row : safeList(snapshot.getEstrattiConto())) {
            addPdfValueRow(estratti,
                    defaultString(row.getNominativo()),
                    defaultString(row.getStatoPosizione()),
                    euro(row.getResiduo()),
                    euro(row.getScopertoRate()),
                    euro(row.getTotaleVersamenti()));
        }
        document.add(estratti);

        if (snapshot.getQuotaCondominoTabelle() != null && !snapshot.getQuotaCondominoTabelle().isEmpty()) {
            document.add(new Paragraph(" "));
            document.add(new Paragraph("Dettaglio quota condomino per tabella"));
            final List<QuotaMovimentoGroup> groups = buildQuotaMovimentoGroups(snapshot.getQuotaCondominoTabelle());
            for (QuotaMovimentoGroup group : groups) {
                document.add(new Paragraph(
                        String.format(
                                java.util.Locale.US,
                                "%s | %s | %s | %s | importo=%s | quota condomino=%s | quadratura=%s",
                                group.reference(),
                                formatInstant(group.dataMovimento()),
                                defaultString(group.codiceSpesa()),
                                defaultString(group.descrizioneMovimento()),
                                euro(group.importoSpesa()),
                                euro(group.quotaCondominoMovimento()),
                                group.isBalanced()
                                        ? "OK"
                                        : "Delta " + euro(Math.abs(group.quotaCondominoTabellaTotale() - group.quotaCondominoMovimento())))));

                PdfPTable quote = new PdfPTable(new float[] { 2f, 2f, 2f, 2f });
                quote.setWidthPercentage(100f);
                addPdfHeaderRow(quote, "Tabella", "Quota tabella", "Millesimi", "Quota condomino tabella");
                for (ReportSnapshotResponse.QuotaCondominoTabellaRow row : safeList(group.rows())) {
                    addPdfValueRow(
                            quote,
                            defaultString(row.getCodiceTabella()),
                            euro(row.getImportoTabella()),
                            String.format(
                                    java.util.Locale.US,
                                    "%.2f/%.2f",
                                    safe(row.getNumeratore()),
                                    safe(row.getDenominatore())),
                            euro(row.getQuotaCondominoTabella()));
                }
                document.add(quote);
                document.add(new Paragraph(" "));
            }
        }
    }

    private void addPdfHeaderRow(PdfPTable table, String... values) {
        for (String value : values) {
            PdfPCell cell = new PdfPCell(new Phrase(value));
            table.addCell(cell);
        }
    }

    private void addPdfValueRow(PdfPTable table, String... values) {
        for (String value : values) {
            table.addCell(new Phrase(value));
        }
    }

    private int writeSectionHeader(Sheet sheet, int rowIndex, CellStyle headerStyle, String left, String right) {
        Row row = sheet.createRow(rowIndex);
        Cell c0 = row.createCell(0);
        c0.setCellValue(left);
        c0.setCellStyle(headerStyle);
        Cell c1 = row.createCell(1);
        c1.setCellValue(right);
        c1.setCellStyle(headerStyle);
        return rowIndex + 1;
    }

    private int writeHeader(Sheet sheet, int rowIndex, CellStyle headerStyle, String... headers) {
        Row row = sheet.createRow(rowIndex);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = row.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }
        return rowIndex + 1;
    }

    private int writeKvRow(Sheet sheet, int rowIndex, String key, String value) {
        Row row = sheet.createRow(rowIndex);
        writeCell(row, 0, key);
        writeCell(row, 1, value);
        return rowIndex + 1;
    }

    private void writeCell(Row row, int index, String value) {
        row.createCell(index).setCellValue(value);
    }

    private String resolveTabellaDescrizione(String descrizione, String codiceTabella) {
        if (descrizione != null && !descrizione.isBlank()) {
            return descrizione;
        }
        if (INDIVIDUALE_TABLE_CODE.equals(codiceTabella)) {
            return INDIVIDUALE_TABLE_LABEL;
        }
        return codiceTabella;
    }

    private String buildNominativo(String nome, String cognome) {
        return ((defaultString(cognome) + " " + defaultString(nome)).trim());
    }

    private String normalizeBlank(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String defaultString(String value) {
        return value == null ? "" : value;
    }

    private double safe(Double value) {
        return value == null ? 0d : value;
    }

    private double sumVersamenti(List<Condomino.Versamento> versamenti) {
        if (versamenti == null || versamenti.isEmpty()) {
            return 0d;
        }
        double total = 0d;
        for (Condomino.Versamento row : versamenti) {
            if (row == null) {
                continue;
            }
            total += safe(row.getImporto());
        }
        return round2(total);
    }

    private double round2(double value) {
        return Math.round(value * 100d) / 100d;
    }

    private String euro(Double value) {
        return String.format(java.util.Locale.US, "%.2f", safe(value));
    }

    private String formatInstant(Instant value) {
        if (value == null) {
            return "";
        }
        return DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(value.atOffset(ZoneOffset.UTC));
    }

    private <T> List<T> safeList(List<T> values) {
        return values == null ? List.of() : values;
    }

    /**
     * Converte le righe tabellari flat in gruppi movimento, per evidenziare
     * che piu' quote appartengono alla stessa spesa.
     */
    private List<QuotaMovimentoGroup> buildQuotaMovimentoGroups(
            List<ReportSnapshotResponse.QuotaCondominoTabellaRow> rows) {
        if (rows == null || rows.isEmpty()) {
            return List.of();
        }
        Map<String, List<ReportSnapshotResponse.QuotaCondominoTabellaRow>> grouped = new LinkedHashMap<>();
        int fallbackIndex = 0;
        for (ReportSnapshotResponse.QuotaCondominoTabellaRow row : rows) {
            if (row == null) {
                continue;
            }
            final String key;
            if (normalizeBlank(row.getMovimentoId()) != null) {
                key = row.getMovimentoId().trim();
            } else {
                key = "fallback_" + fallbackIndex++;
            }
            grouped.computeIfAbsent(key, ignored -> new ArrayList<>()).add(row);
        }

        List<QuotaMovimentoGroup> out = new ArrayList<>();
        int progressive = 1;
        for (Map.Entry<String, List<ReportSnapshotResponse.QuotaCondominoTabellaRow>> entry : grouped.entrySet()) {
            final List<ReportSnapshotResponse.QuotaCondominoTabellaRow> values = entry.getValue();
            if (values == null || values.isEmpty()) {
                continue;
            }
            final ReportSnapshotResponse.QuotaCondominoTabellaRow first = values.getFirst();
            double importoSpesa = 0d;
            double quotaTabTot = 0d;
            for (ReportSnapshotResponse.QuotaCondominoTabellaRow row : values) {
                if (row == null) {
                    continue;
                }
                importoSpesa += safe(row.getImportoTabella());
                quotaTabTot += safe(row.getQuotaCondominoTabella());
            }
            final String reference = String.format(java.util.Locale.US, "M%03d", progressive++);
            out.add(new QuotaMovimentoGroup(
                    reference,
                    first.getDataMovimento(),
                    defaultString(first.getCodiceSpesa()),
                    defaultString(first.getDescrizioneMovimento()),
                    round2(importoSpesa),
                    round2(safe(first.getQuotaCondominoMovimento())),
                    round2(quotaTabTot),
                    List.copyOf(values)));
        }
        return out;
    }

    private record RipartoRowKey(String codiceSpesa, String codiceTabella) {
    }

    private record QuotaMovimentoGroup(
            String reference,
            Instant dataMovimento,
            String codiceSpesa,
            String descrizioneMovimento,
            Double importoSpesa,
            Double quotaCondominoMovimento,
            Double quotaCondominoTabellaTotale,
            List<ReportSnapshotResponse.QuotaCondominoTabellaRow> rows) {
        private boolean isBalanced() {
            return Math.abs(safeDelta(quotaCondominoTabellaTotale, quotaCondominoMovimento)) < 0.01d;
        }

        private static double safeDelta(Double left, Double right) {
            return (left == null ? 0d : left) - (right == null ? 0d : right);
        }
    }
}
