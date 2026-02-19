package it.atlantica.service.keycloak;


import it.atlantica.config.KeycloakProperties;
import it.atlantica.dto.KeycloakAttributeDTO;
import it.atlantica.exception.ApiException;
import it.atlantica.exception.NotFoundException;
import it.atlantica.exception.PreconditionFailedException;
import it.atlantica.request.KeycloakGroupRequest;
import it.atlantica.request.KeycloakRoleCreated;
import jakarta.ws.rs.core.Response;
import org.keycloak.admin.client.CreatedResponseUtil;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.resource.GroupResource;
import org.keycloak.admin.client.resource.GroupsResource;
import org.keycloak.admin.client.resource.RealmResource;
import org.keycloak.representations.idm.GroupRepresentation;
import org.keycloak.representations.idm.RoleRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class GroupKeycloakService {

    private final Keycloak keycloak;

    @Autowired
    private KeycloakProperties keycloakProperties;

    public GroupKeycloakService(Keycloak keycloak) {
        this.keycloak = keycloak;

    }

    private GroupsResource getGroupsResource() {
        return keycloak.realm(keycloakProperties.getRealm()).groups();
    }

    /**
     * Aggiunge un utente a un gruppo.
     * @param userId L'ID UUID dell'utente.
     * @param groupId L'ID UUID del gruppo.
     */
    public void addUserToGroup(String userId, String groupId) {
            keycloak.realm(keycloakProperties.getRealm()).users().get(userId).joinGroup(groupId);
    }

    public void createGroup(KeycloakGroupRequest created) throws ApiException {
        GroupRepresentation group = new GroupRepresentation();
        group.setName(created.getGroupName());

            String groupId = null;
            Response add = keycloak.realm(keycloakProperties.getRealm()).groups().add(group);
            if (add.getStatus() != 201) {
                throw new ApiException()
                        .withHttpStatus(HttpStatus.BAD_REQUEST)
                        .withErrorCodes("service.group.creation_failed");
            }
            groupId = CreatedResponseUtil.getCreatedId(add);
            if (created.getRoles() != null && !created.getRoles().isEmpty()) {
                for (String role : created.getRoles()) {
                    assignRoleToGroupID(keycloakProperties.getRealm(), groupId, role);
                }
            }
            if(created.getAttributes() != null && !created.getAttributes().isEmpty()) {
                Map<String, List<String>> attrs = new LinkedHashMap<>();

                for (KeycloakAttributeDTO.AttributesDTO a : Optional.ofNullable(created.getAttributes()).orElse(List.of())) {
                    String name = a.getName();
                    String value = a.getValue();
                    attrs.put(name, List.of(value));
                }
                GroupResource groupResource = resolveGroupResourceById(keycloakProperties.getRealm(), groupId);
                GroupRepresentation existingGroup = groupResource.toRepresentation();
                existingGroup.setAttributes(attrs);
                groupResource.update(existingGroup);
            }

        if(created.getSubGroupName()!=null && !created.getSubGroupName().isEmpty()){
            for(String subGroupName : created.getSubGroupName()){
                createSubGroup(new KeycloakAttributeDTO(groupId,null,subGroupName,null));

            }
        }

    }

    public void assignRoleToGroupID(String realm, String groupId, String roleId) throws NotFoundException {
        List<RoleRepresentation> allRoles = keycloak.realm(realm).roles().list();
        RoleRepresentation matchedRole = allRoles.stream()
                .filter(role -> role.getId().equals(roleId))
                .findFirst()
                .orElseThrow(() -> new NotFoundException("roleId"));
            keycloak.realm(keycloakProperties.getRealm())
                    .groups()
                    .group(groupId)
                    .roles()
                    .realmLevel()
                    .add(Collections.singletonList(matchedRole));
    }
    /**
     * Risolve un GroupResource per ID che può essere anche di un SOTTOGRUPPO.
     */
    private GroupResource resolveGroupResourceById(String realm, String groupId) throws NotFoundException {
        RealmResource realmRes = keycloak.realm(realm);
            GroupResource gr = realmRes.groups().group(groupId);
            GroupRepresentation rep = gr.toRepresentation();
            if (rep != null) return gr;

        List<GroupRepresentation> roots = realmRes.groups().groups();
        GroupResource found = findGroupResourceRecursive(realmRes, roots, groupId);
        if (found == null) {
            throw new NotFoundException(groupId);
        }
        return found;
    }

    /**
     * DFS sui gruppi per trovare l'ID anche tra i subGroups annidati.
     */
    private GroupResource findGroupResourceRecursive(RealmResource realmRes, List<GroupRepresentation> groups, String groupId) {
        if (groups == null) return null;
        for (GroupRepresentation g : groups) {
            if (groupId.equals(g.getId())) {
                return realmRes.groups().group(g.getId());
            }
            GroupResource sub = findGroupResourceRecursive(realmRes, g.getSubGroups(), groupId);
            if (sub != null) return sub;
        }
        return null;
    }
    public void updateGroup(KeycloakRoleCreated updated) throws NotFoundException {
        String realm = keycloakProperties.getRealm();
        String groupId = updated.getGroupId();
        GroupResource groupResource = resolveGroupResourceById(realm, groupId);
        GroupRepresentation existingGroup = groupResource.toRepresentation();
        if (existingGroup == null) {
            throw new NotFoundException( groupId);
        }
        List<RoleRepresentation> previousRoles = groupResource.roles().realmLevel().listAll();
            if (updated.getGroupName() != null &&
                    !updated.getGroupName().equals(existingGroup.getName())) {
                existingGroup.setName(updated.getGroupName());
                groupResource.update(existingGroup);
            }
            if (updated.getSubGroupName() != null &&
                    !updated.getSubGroupName().equals(existingGroup.getName())) {
                existingGroup.setName(updated.getSubGroupName());
                groupResource.update(existingGroup);
            }
            if (!previousRoles.isEmpty()) {
                groupResource.roles().realmLevel().remove(previousRoles);
            }
            if (updated.getRoles() != null && !updated.getRoles().isEmpty()) {
                List<RoleRepresentation> allRealmRoles = keycloak.realm(realm).roles().list();
                List<RoleRepresentation> rolesToAssign = new ArrayList<>();
                for (String roleId : updated.getRoles()) {
                    RoleRepresentation roleRepresentation = allRealmRoles.stream()
                            .filter(role -> role.getId().equals(roleId))
                            .findFirst()
                            .orElseThrow(() -> new NotFoundException("roleId" ));
                    rolesToAssign.add(roleRepresentation);
                }

                groupResource.roles().realmLevel().add(rolesToAssign);
            }
            Map<String, List<String>> attrs = new LinkedHashMap<>();
            for (KeycloakAttributeDTO.AttributesDTO a : Optional.ofNullable(updated.getAttributes()).orElse(List.of())) {
                String name = a.getName();
                String value = a.getValue();
                attrs.put(name, List.of(value));
            }
            existingGroup.setAttributes(attrs);
            groupResource.update(existingGroup);

    }

    public void updateAttributesGroup(KeycloakAttributeDTO updated) throws it.atlantica.exception.NotFoundException {
        String groupId = updated.getGroupId();

        GroupResource groupResource = resolveGroupResourceById(keycloakProperties.getRealm(), groupId);
        GroupRepresentation existingGroup = groupResource.toRepresentation();

        if (existingGroup == null) {
            throw new NotFoundException("groupId");
        }

        Map<String, List<String>> attrs = new LinkedHashMap<>();

        for (KeycloakAttributeDTO.AttributesDTO a : Optional.ofNullable(updated.getAttributes()).orElse(List.of())) {
            String name = a.getName();
            String value = a.getValue();
            attrs.put(name, List.of(value));
        }

        existingGroup.setAttributes(attrs);
        groupResource.update(existingGroup);

    }

    public void deleteGroup(String groupId) throws NotFoundException {

        String realm = keycloakProperties.getRealm();
        GroupResource groupResource = resolveGroupResourceById(realm, groupId);
        GroupRepresentation existingGroup = groupResource.toRepresentation();
        if (existingGroup == null) {
            throw new NotFoundException("groupId" );
        }
        groupResource.remove();

    }


    public void createSubGroup(KeycloakAttributeDTO newSubGroup) throws ApiException {
        String realm = keycloakProperties.getRealm();
        String parentId = newSubGroup.getGroupId();
        GroupResource parent = resolveGroupResourceById(realm, parentId);
        GroupRepresentation parentRep = parent.toRepresentation();
        if (parentRep == null) {
            throw new NotFoundException("groupId" );
        }
        String name = Optional.ofNullable(newSubGroup.getNameGroup())
                .map(String::trim)
                .orElseThrow(() ->  new PreconditionFailedException("nameGroup","missing"));

        GroupRepresentation sub = new GroupRepresentation();
        sub.setName(name);

        boolean exists = parentRep.getSubGroups() != null &&
                parentRep.getSubGroups().stream().anyMatch(g -> name.equals(g.getName()));
        if (exists) {
            throw new ApiException()
                    .withHttpStatus(HttpStatus.BAD_REQUEST)
                    .withErrorCodes("service.service.subgroup.already_exists");
        }

        try (Response resp = parent.subGroup(sub)) {
            int status = resp.getStatus();
            if (status != 201 && status != 204) {
                throw new ApiException()
                        .withHttpStatus(HttpStatus.BAD_REQUEST)
                        .withErrorCodes("service.subgroup.creation_failed");
            }
            String createdId = null;
            if (status == 201) {
                String location = resp.getHeaderString("Location");
                if (location != null) {
                    createdId = location.substring(location.lastIndexOf('/') + 1);
                }
            }
            if (createdId != null && newSubGroup.getAttributes() != null) {
                GroupResource created = keycloak.realm(realm).groups().group(createdId);
                GroupRepresentation rep = created.toRepresentation();
                Map<String, List<String>> attrs = buildMapFromDto(newSubGroup.getAttributes());
                rep.setAttributes(attrs);
                created.update(rep);
                if (newSubGroup.getRoles() != null && !newSubGroup.getRoles().isEmpty()) {
                    List<RoleRepresentation> allRealmRoles = keycloak.realm(realm).roles().list();
                    List<RoleRepresentation> rolesToAssign = new ArrayList<>();
                    for (String roleId : newSubGroup.getRoles()) {
                        RoleRepresentation role_id = allRealmRoles.stream()
                                .filter(role -> role.getId().equals(roleId))
                                .findFirst()
                                .orElseThrow(() -> new NotFoundException("role"));
                        rolesToAssign.add(role_id);
                    }

                    created.roles().realmLevel().add(rolesToAssign);
                }
            }
        }
    }

    private Map<String, List<String>> buildMapFromDto(List<KeycloakAttributeDTO.AttributesDTO> attrs) {
        Map<String, List<String>> map = new LinkedHashMap<>();

        if (attrs == null) {
            return map;
        }

        for (KeycloakAttributeDTO.AttributesDTO a : attrs) {
            if (a == null) continue;

            String name = a.getName() != null ? a.getName().trim() : null;
            String value = a.getValue();

            if (name == null || name.isEmpty()) {
                continue;
            }
            if (value != null && !value.isBlank()) {
                map.put(name, List.of(value));
            } else {
                map.put(name, List.of());
            }
        }
        return map;
    }


}