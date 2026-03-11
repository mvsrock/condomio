package it.condomio.service;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.gridfs.GridFsOperations;
import org.springframework.data.mongodb.gridfs.GridFsTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.mongodb.client.gridfs.model.GridFSFile;

import it.condomio.controller.model.DocumentoArchivioResource;
import it.condomio.document.Condominio;
import it.condomio.document.DocumentoArchivio;
import it.condomio.document.Movimenti;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;
import it.condomio.repository.DocumentoArchivioRepository;
import it.condomio.repository.MovimentiRepository;

/**
 * Verticale documentale Fase 5:
 * - archivio documenti per esercizio
 * - allegati a movimenti
 * - versioning minimo (gruppo + versione incrementale)
 * - storage binario su GridFS
 */
@Service
public class DocumentoArchivioService {
    private static final String DEFAULT_CONTENT_TYPE = "application/octet-stream";
    private static final int MAX_PAGE_SIZE = 200;

    private final DocumentoArchivioRepository documentoRepository;
    private final CondominioRepository condominioRepository;
    private final MovimentiRepository movimentiRepository;
    private final TenantAccessService tenantAccessService;
    private final EsercizioGuardService esercizioGuardService;
    private final GridFsTemplate gridFsTemplate;
    private final GridFsOperations gridFsOperations;

    public DocumentoArchivioService(
            DocumentoArchivioRepository documentoRepository,
            CondominioRepository condominioRepository,
            MovimentiRepository movimentiRepository,
            TenantAccessService tenantAccessService,
            EsercizioGuardService esercizioGuardService,
            GridFsTemplate gridFsTemplate,
            GridFsOperations gridFsOperations) {
        this.documentoRepository = documentoRepository;
        this.condominioRepository = condominioRepository;
        this.movimentiRepository = movimentiRepository;
        this.tenantAccessService = tenantAccessService;
        this.esercizioGuardService = esercizioGuardService;
        this.gridFsTemplate = gridFsTemplate;
        this.gridFsOperations = gridFsOperations;
    }

    public DocumentoArchivioPageResult listDocumenti(
            String idCondominio,
            String categoriaRaw,
            String search,
            String movimentoId,
            boolean includeAllVersions,
            Integer page,
            Integer size,
            String keycloakUserId) throws ApiException {
        final String exerciseId = normalize(idCondominio);
        if (exerciseId == null) {
            throw new ValidationFailedException("validation.required.documento.idCondominio");
        }

        ensureExerciseVisible(exerciseId, keycloakUserId);
        final DocumentoArchivio.Categoria categoria = parseCategoria(categoriaRaw, true);
        final String normalizedMovimentoId = normalize(movimentoId);
        final String searchToken = normalize(search) == null ? null : search.trim().toLowerCase(Locale.ROOT);

        List<DocumentoArchivio> rows = normalizedMovimentoId == null
                ? documentoRepository.findByIdCondominioOrderByCreatedAtDesc(exerciseId)
                : documentoRepository.findByIdCondominioAndMovimentoIdOrderByCreatedAtDesc(
                        exerciseId,
                        normalizedMovimentoId);

        rows = rows.stream()
                .filter(item -> categoria == null || item.getCategoria() == categoria)
                .filter(item -> matchSearch(item, searchToken))
                .sorted(Comparator
                        .comparing(DocumentoArchivio::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(DocumentoArchivio::getVersionNumber, Comparator.nullsLast(Comparator.reverseOrder())))
                .toList();

        if (!includeAllVersions) {
            rows = keepOnlyLatestByGroup(rows);
        }

        if (page == null && size == null) {
            List<DocumentoArchivioResource> all = rows.stream().map(this::toResource).toList();
            return new DocumentoArchivioPageResult(
                    all,
                    0,
                    all.size(),
                    all.size(),
                    all.isEmpty() ? 0 : 1,
                    false,
                    false);
        }

        final int pageNumber = page == null ? 0 : page;
        final int pageSize = size == null ? 50 : size;
        validatePagination(pageNumber, pageSize);

        final int totalElements = rows.size();
        final int totalPages = totalElements == 0
                ? 0
                : (int) Math.ceil((double) totalElements / pageSize);
        final int fromIndex = pageNumber * pageSize;
        final int toIndex = Math.min(fromIndex + pageSize, totalElements);

        final List<DocumentoArchivioResource> pageRows = fromIndex >= totalElements
                ? List.of()
                : rows.subList(fromIndex, toIndex).stream().map(this::toResource).toList();

        final boolean hasPrevious = pageNumber > 0 && totalElements > 0;
        final boolean hasNext = toIndex < totalElements;

        return new DocumentoArchivioPageResult(
                pageRows,
                pageNumber,
                pageSize,
                totalElements,
                totalPages,
                hasNext,
                hasPrevious);
    }

    @Transactional
    public DocumentoArchivioResource uploadDocumento(
            String idCondominio,
            String categoriaRaw,
            String titolo,
            String descrizione,
            String movimentoId,
            String versionGroupId,
            MultipartFile file,
            String keycloakUserId) throws ApiException, IOException {
        final String exerciseId = normalize(idCondominio);
        if (exerciseId == null) {
            throw new ValidationFailedException("validation.required.documento.idCondominio");
        }
        if (file == null || file.isEmpty()) {
            throw new ValidationFailedException("validation.required.documento.file");
        }

        Condominio exercise = esercizioGuardService.requireOwnedOpenExercise(exerciseId, keycloakUserId);
        final DocumentoArchivio.Categoria categoria = parseCategoria(categoriaRaw, false);
        final String normalizedMovimentoId = normalize(movimentoId);
        ensureMovimentoBelongsToExerciseIfPresent(normalizedMovimentoId, exercise.getId());

        byte[] bytes = file.getBytes();
        if (bytes.length == 0) {
            throw new ValidationFailedException("validation.required.documento.file");
        }

        final String groupId = normalize(versionGroupId) == null
                ? UUID.randomUUID().toString()
                : normalize(versionGroupId);
        final int nextVersion = resolveNextVersion(groupId);
        final String filename = normalize(file.getOriginalFilename()) == null
                ? "documento"
                : file.getOriginalFilename().trim();
        final String contentType = normalize(file.getContentType()) == null
                ? DEFAULT_CONTENT_TYPE
                : file.getContentType().trim();
        final String normalizedTitolo = normalize(titolo) == null ? filename : titolo.trim();
        final String normalizedDescrizione = normalize(descrizione);

        ObjectId storedObjectId;
        try (InputStream stream = new ByteArrayInputStream(bytes)) {
            Document metadata = new Document();
            metadata.put("idCondominio", exerciseId);
            metadata.put("categoria", categoria.name());
            metadata.put("documentGroupId", groupId);
            metadata.put("versionNumber", nextVersion);
            if (normalizedMovimentoId != null) {
                metadata.put("movimentoId", normalizedMovimentoId);
            }
            storedObjectId = gridFsTemplate.store(stream, filename, contentType, metadata);
        }

        Instant now = Instant.now();
        DocumentoArchivio payload = new DocumentoArchivio();
        payload.setIdCondominio(exerciseId);
        payload.setMovimentoId(normalizedMovimentoId);
        payload.setCategoria(categoria);
        payload.setTitolo(normalizedTitolo);
        payload.setDescrizione(normalizedDescrizione);
        payload.setOriginalFileName(filename);
        payload.setContentType(contentType);
        payload.setSizeBytes((long) bytes.length);
        payload.setChecksumSha256(sha256Hex(bytes));
        payload.setStorageObjectId(storedObjectId.toHexString());
        payload.setDocumentGroupId(groupId);
        payload.setVersionNumber(nextVersion);
        payload.setCreatedAt(now);
        payload.setUpdatedAt(now);
        payload.setCreatedByKeycloakUserId(keycloakUserId);

        return toResource(documentoRepository.save(payload));
    }

    @Transactional
    public DocumentoArchivioResource uploadNuovaVersione(
            String sourceDocumentoId,
            String titolo,
            String descrizione,
            MultipartFile file,
            String keycloakUserId) throws ApiException, IOException {
        DocumentoArchivio source = documentoRepository.findById(sourceDocumentoId)
                .orElseThrow(() -> new NotFoundException("documento"));
        esercizioGuardService.requireOwnedOpenExercise(source.getIdCondominio(), keycloakUserId);

        return uploadDocumento(
                source.getIdCondominio(),
                source.getCategoria() == null ? null : source.getCategoria().name(),
                normalize(titolo) == null ? source.getTitolo() : titolo,
                normalize(descrizione) == null ? source.getDescrizione() : descrizione,
                source.getMovimentoId(),
                source.getDocumentGroupId(),
                file,
                keycloakUserId);
    }

    public DocumentoDownloadPayload downloadDocumento(String documentoId, String keycloakUserId) throws ApiException, IOException {
        DocumentoArchivio document = documentoRepository.findById(documentoId)
                .orElseThrow(() -> new NotFoundException("documento"));
        if (!tenantAccessService.canViewCondominio(keycloakUserId, document.getIdCondominio())) {
            throw new ForbiddenException();
        }

        ObjectId objectId;
        try {
            objectId = new ObjectId(document.getStorageObjectId());
        } catch (IllegalArgumentException ex) {
            throw new NotFoundException("documento.file");
        }
        GridFSFile file = gridFsTemplate.findOne(Query.query(Criteria.where("_id").is(objectId)));
        if (file == null) {
            throw new NotFoundException("documento.file");
        }

        byte[] bytes;
        try (InputStream stream = gridFsOperations.getResource(file).getInputStream()) {
            bytes = stream.readAllBytes();
        }
        String contentType = normalize(document.getContentType()) == null ? DEFAULT_CONTENT_TYPE : document.getContentType();
        String filename = normalize(document.getOriginalFileName()) == null ? "documento" : document.getOriginalFileName();
        return new DocumentoDownloadPayload(filename, contentType, bytes);
    }

    @Transactional
    public void deleteDocumento(String documentoId, String keycloakUserId) throws ApiException {
        DocumentoArchivio target = documentoRepository.findById(documentoId)
                .orElseThrow(() -> new NotFoundException("documento"));
        esercizioGuardService.requireOwnedOpenExercise(target.getIdCondominio(), keycloakUserId);

        if (normalize(target.getStorageObjectId()) != null) {
            try {
                ObjectId objectId = new ObjectId(target.getStorageObjectId());
                gridFsTemplate.delete(Query.query(Criteria.where("_id").is(objectId)));
            } catch (IllegalArgumentException ignored) {
                // storage id legacy/malformato: manteniamo delete metadato per evitare lock operativo.
            }
        }
        documentoRepository.deleteById(documentoId);
    }

    private Condominio ensureExerciseVisible(String idCondominio, String keycloakUserId) throws ApiException {
        Condominio exercise = condominioRepository.findById(idCondominio)
                .orElseThrow(() -> new NotFoundException("esercizio"));
        if (!tenantAccessService.canViewCondominio(keycloakUserId, idCondominio)) {
            throw new ForbiddenException();
        }
        return exercise;
    }

    private void ensureMovimentoBelongsToExerciseIfPresent(String movimentoId, String idCondominio) throws ApiException {
        if (movimentoId == null) {
            return;
        }
        Movimenti movimento = movimentiRepository.findById(movimentoId)
                .orElseThrow(() -> new ValidationFailedException("validation.notfound.documento.movimento"));
        if (normalize(movimento.getIdCondominio()) == null || !movimento.getIdCondominio().equals(idCondominio)) {
            throw new ValidationFailedException("validation.invalid.documento.movimentoTenant");
        }
    }

    private int resolveNextVersion(String documentGroupId) {
        return documentoRepository.findFirstByDocumentGroupIdOrderByVersionNumberDesc(documentGroupId)
                .map(item -> (item.getVersionNumber() == null ? 0 : item.getVersionNumber()) + 1)
                .orElse(1);
    }

    private boolean matchSearch(DocumentoArchivio item, String searchToken) {
        if (searchToken == null) {
            return true;
        }
        return containsIgnoreCase(item.getTitolo(), searchToken)
                || containsIgnoreCase(item.getDescrizione(), searchToken)
                || containsIgnoreCase(item.getOriginalFileName(), searchToken)
                || containsIgnoreCase(item.getCategoria() == null ? null : item.getCategoria().name(), searchToken);
    }

    private boolean containsIgnoreCase(String raw, String token) {
        return raw != null && raw.toLowerCase(Locale.ROOT).contains(token);
    }

    private List<DocumentoArchivio> keepOnlyLatestByGroup(List<DocumentoArchivio> rows) {
        Map<String, DocumentoArchivio> byGroup = new LinkedHashMap<>();
        List<DocumentoArchivio> fallbackNoGroup = new ArrayList<>();
        for (DocumentoArchivio item : rows) {
            String group = normalize(item.getDocumentGroupId());
            if (group == null) {
                fallbackNoGroup.add(item);
                continue;
            }
            byGroup.putIfAbsent(group, item);
        }
        List<DocumentoArchivio> out = new ArrayList<>(byGroup.values());
        out.addAll(fallbackNoGroup);
        out.sort(Comparator
                .comparing(DocumentoArchivio::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder()))
                .thenComparing(DocumentoArchivio::getVersionNumber, Comparator.nullsLast(Comparator.reverseOrder())));
        return out;
    }

    private DocumentoArchivio.Categoria parseCategoria(String raw, boolean allowNull) throws ValidationFailedException {
        String normalized = normalize(raw);
        if (normalized == null) {
            if (allowNull) {
                return null;
            }
            throw new ValidationFailedException("validation.required.documento.categoria");
        }
        try {
            return DocumentoArchivio.Categoria.valueOf(normalized.toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException ex) {
            throw new ValidationFailedException("validation.invalid.documento.categoria");
        }
    }

    private DocumentoArchivioResource toResource(DocumentoArchivio source) {
        DocumentoArchivioResource out = new DocumentoArchivioResource();
        out.setId(source.getId());
        out.setIdCondominio(source.getIdCondominio());
        out.setMovimentoId(source.getMovimentoId());
        out.setCategoria(source.getCategoria() == null ? null : source.getCategoria().name());
        out.setTitolo(source.getTitolo());
        out.setDescrizione(source.getDescrizione());
        out.setOriginalFileName(source.getOriginalFileName());
        out.setContentType(source.getContentType());
        out.setSizeBytes(source.getSizeBytes());
        out.setChecksumSha256(source.getChecksumSha256());
        out.setDocumentGroupId(source.getDocumentGroupId());
        out.setVersionNumber(source.getVersionNumber());
        out.setCreatedAt(source.getCreatedAt());
        out.setUpdatedAt(source.getUpdatedAt());
        out.setCreatedByKeycloakUserId(source.getCreatedByKeycloakUserId());
        return out;
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void validatePagination(int page, int size) throws ValidationFailedException {
        if (page < 0) {
            throw new ValidationFailedException("validation.invalid.documento.page");
        }
        if (size <= 0 || size > MAX_PAGE_SIZE) {
            throw new ValidationFailedException("validation.invalid.documento.size");
        }
    }

    private String sha256Hex(byte[] bytes) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] out = digest.digest(bytes);
            StringBuilder builder = new StringBuilder(out.length * 2);
            for (byte chunk : out) {
                builder.append(String.format("%02x", chunk));
            }
            return builder.toString();
        } catch (NoSuchAlgorithmException ex) {
            // SHA-256 presente su tutte le JVM standard: fallback impossibile in pratica.
            throw new IllegalStateException("SHA-256 algorithm unavailable", ex);
        }
    }

    public record DocumentoDownloadPayload(String fileName, String contentType, byte[] bytes) {
    }

    public record DocumentoArchivioPageResult(
            List<DocumentoArchivioResource> items,
            int page,
            int size,
            int totalElements,
            int totalPages,
            boolean hasNext,
            boolean hasPrevious) {
    }
}
