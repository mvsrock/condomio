package it.atlantica.security.jwt;


import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class CustomJwtAuthenticationConverter extends JwtAuthenticationConverter {
    public CustomJwtAuthenticationConverter() {
        this.setJwtGrantedAuthoritiesConverter(jwt -> {
            List<GrantedAuthority> authorities = new ArrayList<>();
            // ruoli da realm_access
            Map<String, Object> realmAccess = jwt.getClaim("realm_access");
            if (realmAccess != null) {
                @SuppressWarnings("unchecked")
                List<String> roles = (List<String>) realmAccess.get("roles");
                if (roles != null) {
                    for (String role : roles) {
                        authorities.add(new SimpleGrantedAuthority("ROLE_" + role));
                    }
                }
            }
            // ruoli da resource_access.account
            Map<String, Object> resourceAccess = jwt.getClaim("resource_access");
            if (resourceAccess != null) {
                @SuppressWarnings("unchecked")
                Map<String, Object> account = (Map<String, Object>) resourceAccess.get("account");
                if (account != null) {
                    @SuppressWarnings("unchecked")
                    List<String> accountRoles = (List<String>) account.get("roles");
                    if (accountRoles != null) {
                        for (String role : accountRoles) {
                            authorities.add(new SimpleGrantedAuthority("ROLE_" + role));
                        }
                    }
                }
            }
            return authorities;
        });
    }
}
