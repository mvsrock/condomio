package it.atlantica.dto;


import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Data
public class KeycloakGroupRoleSummaryDTO {
    private String groupId;
    private String groupName;
    private String subGroupName;
    private String realmId;
    private String distributionCompanyID;
    private String distributionCompanyName;
    private List<String> roles;
    private JsonNode attributesCurrent;
    private String groupPath;
    public KeycloakGroupRoleSummaryDTO(String keycloakGroupId, String keycloakGroupName, String realmId, String rolesCsv, String subGroupName, String distributionCompanyID, String distributionCompanyName,
                                       JsonNode attributesCurrent, String groupPath) {
        this.groupId = keycloakGroupId;
        this.groupName = keycloakGroupName;
        this.realmId = realmId;
        this.subGroupName=subGroupName;
        this.distributionCompanyID=distributionCompanyID;
        this.distributionCompanyName=distributionCompanyName;
        this.attributesCurrent = attributesCurrent;
        this.groupPath = groupPath;
        if (rolesCsv == null || rolesCsv.isBlank()) {
            this.roles = Collections.emptyList();
        } else {
            this.roles = Arrays.asList(rolesCsv.split(","));
        }
    }
}