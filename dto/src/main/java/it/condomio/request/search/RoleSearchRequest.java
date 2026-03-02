package it.condomio.request.search;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RoleSearchRequest {

    List<String> groupsName;
    String roleName;
}
