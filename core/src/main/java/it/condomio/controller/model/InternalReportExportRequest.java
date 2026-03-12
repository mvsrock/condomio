package it.condomio.controller.model;

public class InternalReportExportRequest {
    private String idCondominio;
    private String format;
    private String condominoId;
    private String requesterKeycloakUserId;

    public String getIdCondominio() {
        return idCondominio;
    }

    public void setIdCondominio(String idCondominio) {
        this.idCondominio = idCondominio;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public String getCondominoId() {
        return condominoId;
    }

    public void setCondominoId(String condominoId) {
        this.condominoId = condominoId;
    }

    public String getRequesterKeycloakUserId() {
        return requesterKeycloakUserId;
    }

    public void setRequesterKeycloakUserId(String requesterKeycloakUserId) {
        this.requesterKeycloakUserId = requesterKeycloakUserId;
    }
}
