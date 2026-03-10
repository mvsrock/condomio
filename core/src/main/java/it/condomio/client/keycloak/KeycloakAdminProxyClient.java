package it.condomio.client.keycloak;

import java.util.Map;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Proxy typed verso keycloak-service.
 *
 * Core resta il solo ingresso dal frontend: le chiamate admin vengono inoltrate
 * service-to-service tramite discovery, mantenendo il bearer utente.
 */
@FeignClient(name = "keycloak-service", contextId = "keycloakAdminProxyClient")
public interface KeycloakAdminProxyClient {

    @GetMapping("/users")
    ResponseEntity<String> getUsers(
            @RequestHeader("Authorization") String authorization,
            @RequestParam("page") int page,
            @RequestParam("size") int size,
            @RequestParam("sort") String sort,
            @RequestParam("direction") String direction);

    @PostMapping("/users")
    ResponseEntity<String> createUser(
            @RequestHeader("Authorization") String authorization,
            @RequestBody Map<String, Object> payload);

    @PutMapping("/users")
    ResponseEntity<Void> updateUser(
            @RequestHeader("Authorization") String authorization,
            @RequestBody Map<String, Object> payload);

    @DeleteMapping("/users/{userId}")
    ResponseEntity<Void> deleteUser(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("userId") String userId);

    @PostMapping("/users/{userId}/add_groups")
    ResponseEntity<Void> addUserToGroups(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("userId") String userId,
            @RequestBody Map<String, Object> payload);

    @PutMapping("/users/{userId}/app-role")
    ResponseEntity<Void> updateUserAppRole(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("userId") String userId,
            @RequestBody Map<String, Object> payload);

    @GetMapping("/roles")
    ResponseEntity<String> getRoles(
            @RequestHeader("Authorization") String authorization,
            @RequestParam("page") int page,
            @RequestParam("size") int size,
            @RequestParam("sort") String sort,
            @RequestParam("direction") String direction);

    @PostMapping("/roles")
    ResponseEntity<String> createRole(
            @RequestHeader("Authorization") String authorization,
            @RequestBody Map<String, Object> payload);

    @DeleteMapping("/roles")
    ResponseEntity<Void> deleteRole(
            @RequestHeader("Authorization") String authorization,
            @RequestParam("roleId") String roleId);

    @GetMapping("/groups")
    ResponseEntity<String> getGroups(
            @RequestHeader("Authorization") String authorization,
            @RequestParam("page") int page,
            @RequestParam("size") int size,
            @RequestParam("sort") String sort,
            @RequestParam("direction") String direction);
}

