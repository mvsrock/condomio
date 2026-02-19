package it.atlantica.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class KeycloakAttributeDTO {
    private String groupId;
    private List<AttributesDTO> attributes;
    private String nameGroup;
    private List<String> roles;
    @Data
    public static class AttributesDTO {
        private String id;
        private String name;
        private String value;
    }
}
