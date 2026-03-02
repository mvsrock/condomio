package it.condomio.request;

import java.util.List;

import it.condomio.dto.KeycloakAttributeDTO;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

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
