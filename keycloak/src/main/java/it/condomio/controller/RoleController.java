package it.condomio.controller;


import org.keycloak.representations.idm.RoleRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
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

import it.condomio.exception.PreconditionFailedException;
import it.condomio.request.search.KeycloakRoleGroupRequest;
import it.condomio.request.search.RoleSearchRequest;
import it.condomio.response.PageResponse;
import it.condomio.service.keycloak.RoleService;
import it.condomio.view.KeycloakRoleGroupSummaryViewService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/roles")
public class RoleController {
    @Autowired
    private RoleService roleService;

    @Autowired
    private KeycloakRoleGroupSummaryViewService keycloakRoleGroupSummaryViewService;

    @PostMapping()
    public ResponseEntity<RoleRepresentation> createComplete(@RequestBody KeycloakRoleGroupRequest register) {
        return ResponseEntity.status(HttpStatus.CREATED).body( roleService.createRealmRole(register));
    }


    @DeleteMapping
    public ResponseEntity<Void> deleteRole(@RequestParam String roleId) {
        roleService.deleteRealmRole(roleId);
        return ResponseEntity.noContent().build();
    }



  /*  @GetMapping("/{roleName}")
    public ResponseEntity<RoleRepresentation> getRole(@PathVariable String roleName) {
        return ResponseEntity.ok(roleService.getRealmRole(roleName));
    }*/

    @GetMapping
    public ResponseEntity<PageResponse<KeycloakRoleGroupRequest>> getRoles(@Valid RoleSearchRequest filters,
                                                                           @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int size,
                                                                           @RequestParam() String sort, @RequestParam() String direction
                                                                           ) {

        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.fromString(direction), sort));

        return ResponseEntity.ok(new PageResponse<>(keycloakRoleGroupSummaryViewService.findByFilters(filters, pageable)));
    }

    @PutMapping("/{roleId}")
    public ResponseEntity<Void> updateGroup(
            @PathVariable String roleId,
            @RequestBody KeycloakRoleGroupRequest updateRole) throws PreconditionFailedException {
            if (!roleId.equals(updateRole.getRoleId())) {
                throw  new PreconditionFailedException("dismatched","id");
            }
            roleService.updateRole(updateRole);
            return ResponseEntity.noContent().build();

    }
}
