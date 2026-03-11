package it.condomio.document;

import java.time.Instant;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * Documento archivio per esercizio.
 *
 * Modello:
 * - scope tenant su singolo esercizio (`idCondominio`)
 * - link opzionale a movimento (`movimentoId`)
 * - versioning minimo tramite (`documentGroupId`, `versionNumber`)
 * - payload binario salvato su GridFS (`storageObjectId`)
 */
@Document(collection = "documento")
public class DocumentoArchivio {
    public enum Categoria {
        FATTURA,
        CONTRATTO,
        VERBALE,
        MOVIMENTO,
        ALTRO
    }

    @Id
    private String id;

    @Version
    private Integer version;

    private String idCondominio;
    private String movimentoId;
    private Categoria categoria;
    private String titolo;
    private String descrizione;
    private String originalFileName;
    private String contentType;
    private Long sizeBytes;
    private String checksumSha256;
    private String storageObjectId;
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

    public Integer getVersion() {
        return version;
    }

    public void setVersion(Integer version) {
        this.version = version;
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

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
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

    public String getStorageObjectId() {
        return storageObjectId;
    }

    public void setStorageObjectId(String storageObjectId) {
        this.storageObjectId = storageObjectId;
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
