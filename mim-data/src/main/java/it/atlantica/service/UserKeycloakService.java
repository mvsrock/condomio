package it.atlantica.service;


import it.atlantica.config.KeycloakProperties;
import it.atlantica.dto.KeycloakUserUpdateDTO;
import it.atlantica.service.keycloak.GroupKeycloakService;
import jakarta.ws.rs.core.Response;
import org.keycloak.admin.client.CreatedResponseUtil;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.resource.RealmResource;
import org.keycloak.admin.client.resource.UserResource;
import org.keycloak.admin.client.resource.UsersResource;
import org.keycloak.representations.idm.CredentialRepresentation;
import org.keycloak.representations.idm.UserRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserKeycloakService {

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
}
