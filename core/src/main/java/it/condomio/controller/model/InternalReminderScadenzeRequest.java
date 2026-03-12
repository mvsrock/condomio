package it.condomio.controller.model;

public class InternalReminderScadenzeRequest {
    private String idCondominio;
    private Integer maxDaysAhead;
    private String requesterKeycloakUserId;

    public String getIdCondominio() {
        return idCondominio;
    }

    public void setIdCondominio(String idCondominio) {
        this.idCondominio = idCondominio;
    }

    public Integer getMaxDaysAhead() {
        return maxDaysAhead;
    }

    public void setMaxDaysAhead(Integer maxDaysAhead) {
        this.maxDaysAhead = maxDaysAhead;
    }

    public String getRequesterKeycloakUserId() {
        return requesterKeycloakUserId;
    }

    public void setRequesterKeycloakUserId(String requesterKeycloakUserId) {
        this.requesterKeycloakUserId = requesterKeycloakUserId;
    }
}
