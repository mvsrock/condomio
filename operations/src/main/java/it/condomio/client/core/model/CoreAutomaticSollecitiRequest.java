package it.condomio.client.core.model;

public class CoreAutomaticSollecitiRequest {
    private String idCondominio;
    private Integer minDaysOverdue;
    private String requesterKeycloakUserId;

    public String getIdCondominio() {
        return idCondominio;
    }

    public void setIdCondominio(String idCondominio) {
        this.idCondominio = idCondominio;
    }

    public Integer getMinDaysOverdue() {
        return minDaysOverdue;
    }

    public void setMinDaysOverdue(Integer minDaysOverdue) {
        this.minDaysOverdue = minDaysOverdue;
    }

    public String getRequesterKeycloakUserId() {
        return requesterKeycloakUserId;
    }

    public void setRequesterKeycloakUserId(String requesterKeycloakUserId) {
        this.requesterKeycloakUserId = requesterKeycloakUserId;
    }
}
