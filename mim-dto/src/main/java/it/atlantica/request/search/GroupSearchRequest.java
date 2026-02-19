package it.atlantica.request.search;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
@Data
@AllArgsConstructor
@NoArgsConstructor
public class GroupSearchRequest {
    String groupName;
    String groupPath;
    List<String> roles;
}
