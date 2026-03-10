package it.condomio.client.keycloak;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;

@FeignClient(name = "keycloak-service")
public interface KeycloakServiceClient {

    @PutMapping("/users/{userId}/app-role")
    void updateUserAppRole(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("userId") String userId,
            @RequestBody KeycloakAppRoleUpdateRequest request);
}

