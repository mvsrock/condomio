package it.atlantica.request;

import it.atlantica.dto.KeycloakAttributeDTO;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class KeycloakGroupRequest {
    private String groupId;
    @NotNull
    @NotEmpty
    @NotBlank
    private String groupName;
    private List<String> roles;
    private List<KeycloakAttributeDTO.AttributesDTO> attributes;

    private List<String> subGroupName;
}
