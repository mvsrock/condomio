package it.condomio.service;


import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import org.keycloak.admin.client.CreatedResponseUtil;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.resource.RealmResource;
import org.keycloak.admin.client.resource.UserResource;
import org.keycloak.admin.client.resource.UsersResource;
import org.keycloak.representations.idm.CredentialRepresentation;
import org.keycloak.representations.idm.RoleRepresentation;
import org.keycloak.representations.idm.UserRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.config.KeycloakProperties;
import it.condomio.dto.KeycloakUserUpdateDTO;
import it.condomio.service.keycloak.GroupKeycloakService;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.core.Response;

@Service
public class UserKeycloakService {
    private static final String APP_ROLE_CONSIGLIERE = "consigliere";
    private static final String APP_ROLE_STANDARD = "default-roles-condominio";

    @Autowired
    private Keycloak keycloak;

    @Autowired
    private KeycloakProperties keycloakProperties;
    @Autowired
    private GroupKeycloakService groupKeycloakService;

    public void updateUserAndMoveGroup(KeycloakUserUpdateDTO dto) {
        UserResource userResource = getUserResourceAndUpdate(dto);
        if (dto.getFromGroupId() != null) {
            userResource.leaveGroup(dto.getFromGroupId());
        }
        if (dto.getToGroupId() != null) {
            for(String groupId : dto.getToGroupId()) {
                userResource.joinGroup( groupId);
            }
        }
    }

    public UserRepresentation createUser(KeycloakUserUpdateDTO dto){
        UserRepresentation user = new UserRepresentation();
        user.setUsername(dto.getUsername());
        user.setEnabled(true);
        user.setFirstName(dto.getFirstName());
        user.setLastName(dto.getLastName());
        user.setEmail(dto.getEmail());
        Response response = keycloak.realm(keycloakProperties.getRealm()).users().create(user);
        String userId = CreatedResponseUtil.getCreatedId(response);

        CredentialRepresentation cred = new CredentialRepresentation();
        cred.setTemporary(false);
        cred.setType(CredentialRepresentation.PASSWORD);
        cred.setValue(dto.getPassword());
        keycloak.realm(keycloakProperties.getRealm()).users().get(userId).resetPassword(cred);
        for(String  groupId: dto.getToGroupId()) {
            groupKeycloakService.addUserToGroup(userId,groupId);
        }
        return keycloak.realm(keycloakProperties.getRealm()).users().get(userId).toRepresentation();
    }

    private  UserResource getUserResourceAndUpdate(KeycloakUserUpdateDTO dto ) {
        UserResource userResource = getUserResource(dto.getUserId());
        UserRepresentation user = userResource.toRepresentation();
        if (dto.getFirstName() != null) user.setFirstName(dto.getFirstName());
        if (dto.getLastName() != null) user.setLastName(dto.getLastName());
        if (dto.getEmail() != null) user.setEmail(dto.getEmail());
        user.setEnabled(dto.isEnabled());
        userResource.update(user);
        if (dto.getPassword() != null && !dto.getPassword().isEmpty()) {
            CredentialRepresentation cred = new CredentialRepresentation();
            cred.setType(CredentialRepresentation.PASSWORD);
            cred.setValue(dto.getPassword());
            cred.setTemporary(false);
            userResource.resetPassword(cred);
        }
        return userResource;
    }


    private UserResource getUserResource(String keycloakUserId) {
        return keycloak.realm(keycloakProperties.getRealm()).users().get(keycloakUserId);
    }

    public void leaveGroup(String user_id,String groupId) {
        UserResource userResource = getUserResource(user_id);
        userResource.leaveGroup(groupId);
    }

    public void disabledUser(String user_id) {
        UserResource userResource = getUserResource(user_id);
        UserRepresentation user = userResource.toRepresentation();
        user.setEnabled(false);
        userResource.update(user);
    }

    public void deleteUserFromKeycloak(String userId) {
        RealmResource realmResource = keycloak.realm(keycloakProperties.getRealm());
        UsersResource usersResource = realmResource.users();
        usersResource.delete(userId);
    }

    public void addGroupToUser(String userId, List<String> groupIds) {
        UserResource userResource= getUserResource(userId);
        for(String groupId : groupIds) {
            userResource.joinGroup( groupId);
        }
    }

    /**
     * Assegna il ruolo applicativo direttamente a livello realm-role (senza gruppi).
     *
     * Strategia:
     * - target = consigliere: aggiunge `consigliere`
     * - target = standard/default: rimuove `consigliere`
     *
     * Il ruolo di default realm (`default-roles-<realm>`) resta gestito da Keycloak.
     */
    public void updateUserAppRole(String userId, String roleName) {
        final UserResource userResource = getUserResource(userId);
        final RealmResource realmResource = keycloak.realm(keycloakProperties.getRealm());
        final String normalized = normalizeRoleName(roleName);

        final List<RoleRepresentation> currentlyAssigned =
                userResource.roles().realmLevel().listAll();

        final List<RoleRepresentation> toRemove = new ArrayList<>();
        for (RoleRepresentation role : currentlyAssigned) {
            final String currentName = role == null ? null : role.getName();
            if (currentName == null) {
                continue;
            }
            final String normalizedCurrent = normalizeRoleName(currentName);
            if (APP_ROLE_CONSIGLIERE.equals(normalizedCurrent)
                    || APP_ROLE_STANDARD.equals(normalizedCurrent)) {
                toRemove.add(role);
            }
        }
        if (!toRemove.isEmpty()) {
            userResource.roles().realmLevel().remove(toRemove);
        }

        if (APP_ROLE_CONSIGLIERE.equals(normalized)) {
            final RoleRepresentation consigliereRole = requireRealmRole(
                    realmResource,
                    APP_ROLE_CONSIGLIERE);
            userResource.roles().realmLevel().add(List.of(consigliereRole));
            return;
        }

        // target standard/default:
        // assegna esplicitamente il ruolo standard per evitare utenti "senza ruolo"
        // quando in questo realm il default non viene applicato automaticamente.
        final RoleRepresentation standardRole = findRealmRole(
                realmResource,
                APP_ROLE_STANDARD,
                "standard");
        if (standardRole != null) {
            userResource.roles().realmLevel().add(List.of(standardRole));
        }
    }

    private RoleRepresentation requireRealmRole(RealmResource realmResource, String roleName) {
        final RoleRepresentation role = findRealmRole(realmResource, roleName);
        if (role == null) {
            throw new IllegalStateException("Missing realm role: " + roleName);
        }
        return role;
    }

    private RoleRepresentation findRealmRole(RealmResource realmResource, String... candidateNames) {
        for (String candidate : candidateNames) {
            if (candidate == null || candidate.isBlank()) {
                continue;
            }
            try {
                return realmResource.roles().get(candidate).toRepresentation();
            } catch (NotFoundException ex) {
                // try next alias
            }
        }
        return null;
    }

    private String normalizeRoleName(String raw) {
        if (raw == null) {
            return "";
        }
        String normalized = raw.trim().toLowerCase(Locale.ROOT);
        if (normalized.startsWith("role_")) {
            normalized = normalized.substring(5);
        }
        if (normalized.startsWith("authority_")) {
            normalized = normalized.substring("authority_".length());
        }
        if (Set.of("standard", "default", "default-roles-condominio").contains(normalized)) {
            return "default-roles-condominio";
        }
        return normalized;
    }
}
