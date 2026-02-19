package it.atlantica.request;

import it.atlantica.dto.KeycloakAttributeDTO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class KeycloakRoleCreated {
    private String groupId;
    private String groupName;
    private  String subGroupName;
    private String realmId;
    private List<String> roles;
    private List<KeycloakAttributeDTO.AttributesDTO> attributes;
    @Data
    public static class AttributesDTO {
        private String id;
        private String name;
        private String value;
    }
}
