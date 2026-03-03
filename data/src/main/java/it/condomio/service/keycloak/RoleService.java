package it.condomio.service.keycloak;


import java.util.Collections;
import java.util.List;
import java.util.Set;

import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.resource.RoleResource;
import org.keycloak.representations.idm.GroupRepresentation;
import org.keycloak.representations.idm.RoleRepresentation;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.config.KeycloakProperties;
import it.condomio.entity.keycloak.KeycloakRole;
import it.condomio.request.search.KeycloakRoleGroupRequest;
import jakarta.ws.rs.ClientErrorException;
import jakarta.ws.rs.ProcessingException;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;

@Service
public class RoleService {
    private static final Logger log = LoggerFactory.getLogger(RoleService.class);

    @Autowired
    private Keycloak keycloak;


    @Autowired
    private KeycloakProperties keycloakProperties;


       public RoleRepresentation createRealmRole(KeycloakRoleGroupRequest roleGroupRequest) {
        if (roleGroupRequest == null ||
                roleGroupRequest.getRoleName() == null ||
                roleGroupRequest.getRoleName().isBlank()) {
            throw new IllegalArgumentException("roleName is required");
        }

        final String realm = keycloakProperties.getRealm();
        final String roleName = roleGroupRequest.getRoleName().trim();
        RoleRepresentation role = new RoleRepresentation();
        role.setName(roleName);
        if (roleGroupRequest.getDescription() != null) {
            role.setDescription(roleGroupRequest.getDescription());
        }

        try {
            keycloak.realm(realm).roles().create(role);
        } catch (ClientErrorException ex) {
            final Response response = ex.getResponse();
            final int status = response != null ? response.getStatus() : -1;
            final String responseBody = safeReadBody(response);
            log.error(
                    "Keycloak role create failed. realm={} role={} status={} body={}",
                    realm,
                    roleName,
                    status,
                    responseBody,
                    ex
            );
            throw new IllegalStateException(
                    "Keycloak role create failed: status=" + status + ", body=" + responseBody,
                    ex
            );
        } catch (ProcessingException ex) {
            final Response response = extractResponseFromThrowable(ex);
            final int status = response != null ? response.getStatus() : -1;
            final String responseBody = safeReadBody(response);
            log.error(
                    "Keycloak role create failed (processing). realm={} role={} status={} body={}",
                    realm,
                    roleName,
                    status,
                    responseBody,
                    ex
            );
            throw new IllegalStateException(
                    "Keycloak role create failed (processing): status=" + status + ", body=" + responseBody,
                    ex
            );
        }

        List<String> groupIds = roleGroupRequest.getGroupIDs();
        if (groupIds == null) {
            groupIds = Collections.emptyList();
        }
        if (!groupIds.isEmpty()) {
            RoleRepresentation roleCreated = keycloak.realm(realm).roles().get(roleName).toRepresentation();
            for (String groupId : groupIds) {
                keycloak.realm(realm).groups().group(groupId).roles().realmLevel().add(Collections.singletonList(roleCreated));
            }
        }
        return keycloak.realm(realm).roles().get(roleName).toRepresentation();
    }

    private String safeReadBody(Response response) {
        if (response == null) return "";
        try {
            if (response.hasEntity()) {
                String body = response.readEntity(String.class);
                return body == null ? "" : body;
            }
        } catch (Exception e) {
            log.warn("Cannot read Keycloak error response body", e);
        }
        return "";
    }

    private Response extractResponseFromThrowable(Throwable throwable) {
        Throwable current = throwable;
        while (current != null) {
            if (current instanceof WebApplicationException webEx) {
                return webEx.getResponse();
            }
            current = current.getCause();
        }
        return null;
    }

    /**
     * Elimina un ruolo a livello di realm.
     */
    public void deleteRealmRole(String roleId) {
        RoleRepresentation role = keycloak.realm(keycloakProperties.getRealm()).rolesById().getRole(roleId);
        String roleName = role.getName();
        keycloak.realm(keycloakProperties.getRealm()).roles().deleteRole(roleName);

    }

    /**
     * Recupera un ruolo specifico.
     */

    public RoleRepresentation getRealmRole( String roleName) {
        return keycloak.realm(keycloakProperties.getRealm()).roles().get(roleName).toRepresentation();
    }


    public RoleRepresentation getRealmRoleById(String roleId) {
        return keycloak
                .realm(keycloakProperties.getRealm())
                .rolesById()
                .getRole(roleId);
    }
    /**
     * Restituisce tutti i ruoli a livello di realm.
     */
    public List<RoleRepresentation> getAllRealmRoles() {
        return keycloak.realm(keycloakProperties.getRealm()).roles().list();
    }


    public KeycloakRole fromRepresentation(RoleRepresentation role) {
        KeycloakRole entity = new KeycloakRole();
        entity.setId(role.getId());
        entity.setName(role.getName());
        return entity;
    }

   public void updateRole(KeycloakRoleGroupRequest updateRole)   {
        String realmId = keycloakProperties.getRealm();
        String roleId  = updateRole.getRoleId();

        RoleRepresentation current = keycloak.realm(realmId).rolesById().getRole(roleId);
        String currentName = current.getName();

        RoleResource roleResource = keycloak.realm(realmId).roles().get(currentName);

     
        Set<GroupRepresentation> currentlyAssignedGroups = roleResource.getRoleGroupMembers();
        java.util.Set<String> currentGroupIds = new java.util.HashSet<>();
        for (GroupRepresentation g : currentlyAssignedGroups) {
            currentGroupIds.add(g.getId());
        }

        java.util.Set<String> targetGroupIds = new java.util.HashSet<>();
       if (updateRole.getGroupIDs() != null) {
            targetGroupIds.addAll(updateRole.getGroupIDs()); 
        }

     
        String originalDescription = current.getDescription();
        current.setName(updateRole.getRoleName());
        current.setDescription(updateRole.getDescription() != null ? updateRole.getDescription() : originalDescription);
        roleResource.update(current);

        RoleRepresentation updatedRole = keycloak.realm(realmId).rolesById().getRole(roleId);

        for (String gid : currentGroupIds) {
            if (!targetGroupIds.contains(gid)) {
                keycloak.realm(realmId)
                        .groups().group(gid)
                        .roles().realmLevel()
                        .remove(java.util.Collections.singletonList(updatedRole));
            }
        }

        for (String gid : targetGroupIds) {
            if (!currentGroupIds.contains(gid)) {
                keycloak.realm(realmId)
                        .groups().group(gid)
                        .roles().realmLevel()
                        .add(java.util.Collections.singletonList(updatedRole));
            }
        }
    }

}
