package it.condomio.controller;

import java.io.IOException;
import java.util.List;

import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import it.condomio.controller.model.DocumentoArchivioResource;
import it.condomio.exception.ApiException;
import it.condomio.service.DocumentoArchivioService;
import it.condomio.service.DocumentoArchivioService.DocumentoArchivioPageResult;
import it.condomio.service.DocumentoArchivioService.DocumentoDownloadPayload;

/**
 * API archivio documentale:
 * - lista con filtri
 * - upload documento
 * - upload nuova versione
 * - download binario
 * - delete documento
 */
@RestController
@RequestMapping("/documenti")
public class DocumentoArchivioController {
    private final DocumentoArchivioService documentoService;

    public DocumentoArchivioController(DocumentoArchivioService documentoService) {
        this.documentoService = documentoService;
    }

    @GetMapping
    public ResponseEntity<List<DocumentoArchivioResource>> list(
            @RequestParam String idCondominio,
            @RequestParam(required = false) String categoria,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String movimentoId,
            @RequestParam(defaultValue = "false") boolean includeAllVersions,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        DocumentoArchivioPageResult result = documentoService.listDocumenti(
                idCondominio,
                categoria,
                search,
                movimentoId,
                includeAllVersions,
                page,
                size,
                jwt.getSubject());
        return ResponseEntity.ok()
                .header("X-Page", String.valueOf(result.page()))
                .header("X-Size", String.valueOf(result.size()))
                .header("X-Total-Count", String.valueOf(result.totalElements()))
                .header("X-Total-Pages", String.valueOf(result.totalPages()))
                .header("X-Has-Next", String.valueOf(result.hasNext()))
                .header("X-Has-Previous", String.valueOf(result.hasPrevious()))
                .body(result.items());
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<DocumentoArchivioResource> upload(
            @RequestParam String idCondominio,
            @RequestParam String categoria,
            @RequestParam(required = false) String titolo,
            @RequestParam(required = false) String descrizione,
            @RequestParam(required = false) String movimentoId,
            @RequestParam(required = false) String versionGroupId,
            @RequestPart("file") MultipartFile file,
            @AuthenticationPrincipal Jwt jwt) throws ApiException, IOException {
        DocumentoArchivioResource created = documentoService.uploadDocumento(
                idCondominio,
                categoria,
                titolo,
                descrizione,
                movimentoId,
                versionGroupId,
                file,
                jwt.getSubject());
        return ResponseEntity.status(201).body(created);
    }

    @PostMapping(path = "/{idDocumento}/versioni", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<DocumentoArchivioResource> uploadNuovaVersione(
            @PathVariable String idDocumento,
            @RequestParam(required = false) String titolo,
            @RequestParam(required = false) String descrizione,
            @RequestPart("file") MultipartFile file,
            @AuthenticationPrincipal Jwt jwt) throws ApiException, IOException {
        DocumentoArchivioResource created = documentoService.uploadNuovaVersione(
                idDocumento,
                titolo,
                descrizione,
                file,
                jwt.getSubject());
        return ResponseEntity.status(201).body(created);
    }

    @GetMapping("/{idDocumento}/download")
    public ResponseEntity<ByteArrayResource> download(
            @PathVariable String idDocumento,
            @AuthenticationPrincipal Jwt jwt) throws ApiException, IOException {
        DocumentoDownloadPayload payload = documentoService.downloadDocumento(idDocumento, jwt.getSubject());
        ByteArrayResource body = new ByteArrayResource(payload.bytes());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentLength(payload.bytes().length);
        try {
            headers.setContentType(MediaType.parseMediaType(payload.contentType()));
        } catch (Exception ignored) {
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        }
        headers.setContentDisposition(ContentDisposition.attachment().filename(payload.fileName()).build());

        return ResponseEntity.ok()
                .headers(headers)
                .body(body);
    }

    @DeleteMapping("/{idDocumento}")
    public ResponseEntity<Void> delete(
            @PathVariable String idDocumento,
            @AuthenticationPrincipal Jwt jwt) throws ApiException {
        documentoService.deleteDocumento(idDocumento, jwt.getSubject());
        return ResponseEntity.noContent().build();
    }
}
