package it.atlantica.request.search;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class KeycloakRoleGroupRequest {
    private String roleId;
    @NotNull
    @NotEmpty
    private String roleName;
    private String description;

    private List<String> groupIDs;

    public KeycloakRoleGroupRequest(String roleId, String roleName, String groupsName, String description) {
        this.roleId = roleId;
        this.roleName = roleName;
        this.description = description;
        if (groupsName == null || groupsName.isBlank()) {
            this.groupIDs = Collections.emptyList();
        } else {
            this.groupIDs = Arrays.asList(groupsName.split(","));
        }
    }

}
