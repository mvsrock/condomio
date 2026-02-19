package it.atlantica.request.search;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RoleSearchRequest {

    List<String> groupsName;
    String roleName;
}
