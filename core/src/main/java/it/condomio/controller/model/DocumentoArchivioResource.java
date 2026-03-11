package it.condomio.controller.model;

import java.time.Instant;

/**
 * Risorsa read model per archivio documentale esercizio.
 */
public class DocumentoArchivioResource {
    private String id;
    private String idCondominio;
    private String movimentoId;
    private String categoria;
    private String titolo;
    private String descrizione;
    private String originalFileName;
    private String contentType;
    private Long sizeBytes;
    private String checksumSha256;
    private String documentGroupId;
    private Integer versionNumber;
    private Instant createdAt;
    private Instant updatedAt;
    private String createdByKeycloakUserId;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getIdCondominio() {
        return idCondominio;
    }

    public void setIdCondominio(String idCondominio) {
        this.idCondominio = idCondominio;
    }

    public String getMovimentoId() {
        return movimentoId;
    }

    public void setMovimentoId(String movimentoId) {
        this.movimentoId = movimentoId;
    }

    public String getCategoria() {
        return categoria;
    }

    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }

    public String getTitolo() {
        return titolo;
    }

    public void setTitolo(String titolo) {
        this.titolo = titolo;
    }

    public String getDescrizione() {
        return descrizione;
    }

    public void setDescrizione(String descrizione) {
        this.descrizione = descrizione;
    }

    public String getOriginalFileName() {
        return originalFileName;
    }

    public void setOriginalFileName(String originalFileName) {
        this.originalFileName = originalFileName;
    }

    public String getContentType() {
        return contentType;
    }

    public void setContentType(String contentType) {
        this.contentType = contentType;
    }

    public Long getSizeBytes() {
        return sizeBytes;
    }

    public void setSizeBytes(Long sizeBytes) {
        this.sizeBytes = sizeBytes;
    }

    public String getChecksumSha256() {
        return checksumSha256;
    }

    public void setChecksumSha256(String checksumSha256) {
        this.checksumSha256 = checksumSha256;
    }

    public String getDocumentGroupId() {
        return documentGroupId;
    }

    public void setDocumentGroupId(String documentGroupId) {
        this.documentGroupId = documentGroupId;
    }

    public Integer getVersionNumber() {
        return versionNumber;
    }

    public void setVersionNumber(Integer versionNumber) {
        this.versionNumber = versionNumber;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCreatedByKeycloakUserId() {
        return createdByKeycloakUserId;
    }

    public void setCreatedByKeycloakUserId(String createdByKeycloakUserId) {
        this.createdByKeycloakUserId = createdByKeycloakUserId;
    }
}
