package it.condomio.controller;

import java.util.Map;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import feign.FeignException;
import it.condomio.client.keycloak.KeycloakAdminProxyClient;
import it.condomio.service.RequestBearerTokenResolver;

/**
 * Facade admin su core per chiamate Keycloak.
 *
 * Frontend -> core -> keycloak-service (via discovery + OpenFeign):
 * in questo modo keycloak-service non viene mai invocato direttamente dalla UI.
 */
@RestController
@RequestMapping("/keycloak-admin")
public class KeycloakAdminProxyController {

    private final KeycloakAdminProxyClient keycloakAdminProxyClient;
    private final RequestBearerTokenResolver bearerTokenResolver;

    public KeycloakAdminProxyController(
            KeycloakAdminProxyClient keycloakAdminProxyClient,
            RequestBearerTokenResolver bearerTokenResolver) {
        this.keycloakAdminProxyClient = keycloakAdminProxyClient;
        this.bearerTokenResolver = bearerTokenResolver;
    }

    @GetMapping("/users")
    public ResponseEntity<String> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size,
            @RequestParam(defaultValue = "username") String sort,
            @RequestParam(defaultValue = "ASC") String direction) {
        try {
            return keycloakAdminProxyClient.getUsers(
                    bearerTokenResolver.resolveBearerToken(),
                    page,
                    size,
                    sort,
                    direction);
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @PostMapping("/users")
    public ResponseEntity<String> createUser(@RequestBody Map<String, Object> payload) {
        try {
            return keycloakAdminProxyClient.createUser(
                    bearerTokenResolver.resolveBearerToken(),
                    payload);
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @PutMapping("/users")
    public ResponseEntity<String> updateUser(@RequestBody Map<String, Object> payload) {
        try {
            ResponseEntity<Void> upstream = keycloakAdminProxyClient.updateUser(
                    bearerTokenResolver.resolveBearerToken(),
                    payload);
            return ResponseEntity.status(upstream.getStatusCode()).build();
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @DeleteMapping("/users/{userId}")
    public ResponseEntity<String> deleteUser(@PathVariable String userId) {
        try {
            ResponseEntity<Void> upstream = keycloakAdminProxyClient.deleteUser(
                    bearerTokenResolver.resolveBearerToken(),
                    userId);
            return ResponseEntity.status(upstream.getStatusCode()).build();
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @PostMapping("/users/{userId}/add_groups")
    public ResponseEntity<String> addUserToGroups(
            @PathVariable String userId,
            @RequestBody Map<String, Object> payload) {
        try {
            ResponseEntity<Void> upstream = keycloakAdminProxyClient.addUserToGroups(
                    bearerTokenResolver.resolveBearerToken(),
                    userId,
                    payload);
            return ResponseEntity.status(upstream.getStatusCode()).build();
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @PutMapping("/users/{userId}/app-role")
    public ResponseEntity<String> updateUserAppRole(
            @PathVariable String userId,
            @RequestBody Map<String, Object> payload) {
        try {
            ResponseEntity<Void> upstream = keycloakAdminProxyClient.updateUserAppRole(
                    bearerTokenResolver.resolveBearerToken(),
                    userId,
                    payload);
            return ResponseEntity.status(upstream.getStatusCode()).build();
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @GetMapping("/roles")
    public ResponseEntity<String> getRoles(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size,
            @RequestParam(defaultValue = "roleName") String sort,
            @RequestParam(defaultValue = "ASC") String direction) {
        try {
            return keycloakAdminProxyClient.getRoles(
                    bearerTokenResolver.resolveBearerToken(),
                    page,
                    size,
                    sort,
                    direction);
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @PostMapping("/roles")
    public ResponseEntity<String> createRole(@RequestBody Map<String, Object> payload) {
        try {
            return keycloakAdminProxyClient.createRole(
                    bearerTokenResolver.resolveBearerToken(),
                    payload);
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @DeleteMapping("/roles")
    public ResponseEntity<String> deleteRole(@RequestParam String roleId) {
        try {
            ResponseEntity<Void> upstream = keycloakAdminProxyClient.deleteRole(
                    bearerTokenResolver.resolveBearerToken(),
                    roleId);
            return ResponseEntity.status(upstream.getStatusCode()).build();
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    @GetMapping("/groups")
    public ResponseEntity<String> getGroups(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "200") int size,
            @RequestParam(defaultValue = "groupName") String sort,
            @RequestParam(defaultValue = "ASC") String direction) {
        try {
            return keycloakAdminProxyClient.getGroups(
                    bearerTokenResolver.resolveBearerToken(),
                    page,
                    size,
                    sort,
                    direction);
        } catch (FeignException ex) {
            return mapFeignException(ex);
        }
    }

    private ResponseEntity<String> mapFeignException(FeignException ex) {
        HttpStatus status = HttpStatus.resolve(ex.status());
        if (status == null) {
            status = HttpStatus.BAD_GATEWAY;
        }
        String body = ex.contentUTF8();
        if (body == null || body.isBlank()) {
            body = "{\"errorCodes\":[\"server.upstream.keycloak\"],\"timestamp\":null}";
        }
        return ResponseEntity.status(status)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(body);
    }

}
