package it.atlantica.dto;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class KeycloakUserUpdateDTO {
    private String userId;

    private String fromGroupId;
    private List<String> toGroupId;
    private String username;
    private String firstName;
    private String lastName;
    private String email;
    private String password;
    private boolean enabled;
    private  String toDistributionCompanyIds;
    private String fromDistributionCompanyId;

}
