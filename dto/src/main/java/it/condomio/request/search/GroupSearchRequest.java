package it.condomio.request.search;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
@Data
@AllArgsConstructor
@NoArgsConstructor
public class GroupSearchRequest {
    String groupName;
    String groupPath;
    List<String> roles;
}
