package it.atlantica.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class MenuItemDto {
    private Long id;
    private String item;
    @NotNull
    @NotEmpty
    @NotBlank
    private String label;

    private String description;
    private String parent;
    private Long parentId;
    private int visualOrder = 0;
    private String uri;
    private String icon;
    private String realm;
    @NotNull
    @NotEmpty
    @NotBlank
    private String roleId;
    @NotNull
    private boolean visible;

    private String roleName;
}