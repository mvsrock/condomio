package it.atlantica.entity.keycloak;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.io.Serializable;

/*
 * classe semiclone di quella originale di keycloack
 * **/

@Entity
@Table(name = "keycloak_role")
public class KeycloakRole implements Serializable {

    @Id
    @Column(name = "id", nullable = false, length = 36)
    private String id;

    @Column(name = "client_realm_constraint")
    private String clientRealmConstraint;

    @Column(name = "client_role", nullable = false)
    private boolean clientRole = false;

    @Column(name = "description")
    private String description;

    @Column(name = "name")
    private String name;

    @Column(name = "realm_id")
    private String realmId;

    @Column(name = "client", length = 36)
    private String client;



    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getClientRealmConstraint() {
        return clientRealmConstraint;
    }

    public void setClientRealmConstraint(String clientRealmConstraint) {
        this.clientRealmConstraint = clientRealmConstraint;
    }

    public boolean isClientRole() {
        return clientRole;
    }

    public void setClientRole(boolean clientRole) {
        this.clientRole = clientRole;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRealmId() {
        return realmId;
    }

    public void setRealmId(String realmId) {
        this.realmId = realmId;
    }

    public String getClient() {
        return client;
    }

    public void setClient(String client) {
        this.client = client;
    }


}
