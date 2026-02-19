package it.atlantica.request.search;

import jakarta.validation.constraints.Email;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserSearchRequest {
    @Email(message = "Invalid email format")
    private String email;
    private String firstName;
    private String lastName;
    private String username;
    private String groupName;
    private String distributionCompany;

}
