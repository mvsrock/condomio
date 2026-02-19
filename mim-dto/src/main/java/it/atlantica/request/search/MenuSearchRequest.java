package it.atlantica.request.search;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class MenuSearchRequest {
    private String label;
    private String parent;
    private String roleId;

}
