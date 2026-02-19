package it.atlantica.service.keycloak;


import java.util.Collections;
import java.util.List;
import java.util.Set;




import it.atlantica.config.KeycloakProperties;
import it.atlantica.entity.keycloak.KeycloakRole;
import it.atlantica.request.search.KeycloakRoleGroupRequest;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.resource.RoleResource;
import org.keycloak.representations.idm.GroupRepresentation;
import org.keycloak.representations.idm.RoleRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Service
public class RoleService {

    @Autowired
    private Keycloak keycloak;


    @Autowired
    private KeycloakProperties keycloakProperties;


       public RoleRepresentation createRealmRole(KeycloakRoleGroupRequest roleGroupRequest) {
        RoleRepresentation role = new RoleRepresentation();
        role.setName(roleGroupRequest.getRoleName());
        if (roleGroupRequest.getDescription() != null) {
            role.setDescription(roleGroupRequest.getDescription());
        }
        keycloak.realm(keycloakProperties.getRealm()).roles().create(role);
        if (!roleGroupRequest.getGroupIDs().isEmpty()) {
            RoleRepresentation roleCreated = keycloak.realm(keycloakProperties.getRealm()).roles().get(roleGroupRequest.getRoleName()).toRepresentation();
            for (String groupId : roleGroupRequest.getGroupIDs()) {
                keycloak.realm(keycloakProperties.getRealm()).groups().group(groupId).roles().realmLevel().add(Collections.singletonList(roleCreated));
            }
        }
        return keycloak.realm(keycloakProperties.getRealm()).roles().get(roleGroupRequest.getRoleName()).toRepresentation();
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
