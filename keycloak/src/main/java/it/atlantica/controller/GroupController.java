package it.atlantica.controller;


import it.atlantica.dto.KeycloakAttributeDTO;
import it.atlantica.dto.KeycloakGroupRoleSummaryDTO;
import it.atlantica.exception.ApiException;
import it.atlantica.exception.NotFoundException;
import it.atlantica.exception.PreconditionFailedException;
import it.atlantica.request.KeycloakGroupRequest;
import it.atlantica.request.KeycloakRoleCreated;
import it.atlantica.request.search.GroupSearchRequest;
import it.atlantica.response.PageResponse;
import it.atlantica.service.keycloak.GroupKeycloakService;
import it.atlantica.view.KeycloakGroupRoleSummaryViewService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/groups")
public class GroupController {
    @Autowired
    private GroupKeycloakService groupService;


    @Autowired
    private KeycloakGroupRoleSummaryViewService keycloakUserGroupViewService;


    @GetMapping
    public ResponseEntity<PageResponse<KeycloakGroupRoleSummaryDTO>> getGroups(@Valid GroupSearchRequest groupSearchRequest,
                                                                               @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int size,
                                                                               @RequestParam() String sort, @RequestParam() String direction
    ) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.fromString(direction), sort));
        return ResponseEntity.ok(new PageResponse<>(keycloakUserGroupViewService.findByFilters(groupSearchRequest, pageable)));
    }


    @PostMapping
    public ResponseEntity<Void> createComplete(@RequestBody KeycloakGroupRequest register) throws ApiException {
        groupService.createGroup(register);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PutMapping("/{groupId}")
    public ResponseEntity<?> updateGroup(
            @PathVariable String groupId,
            @RequestBody KeycloakRoleCreated updatedGroup) throws NotFoundException, PreconditionFailedException {

            if (!groupId.equals(updatedGroup.getGroupId())) {
                throw new PreconditionFailedException("mismatched","id");

            }

            groupService.updateGroup(updatedGroup);
            return ResponseEntity.ok().build();

    }

    @PutMapping("/{groupId}/attributes")
    public ResponseEntity<Object> updateAttributesGroup(
            @PathVariable String groupId,
            @RequestBody KeycloakAttributeDTO updatedGroup) throws NotFoundException, PreconditionFailedException {

            if (!groupId.equals(updatedGroup.getGroupId())) {
                throw new PreconditionFailedException("mismatched","id");
            }

            groupService.updateAttributesGroup(updatedGroup);
            return ResponseEntity.ok().build();
    }
    @DeleteMapping("/{groupId}")
    public ResponseEntity<Void> deleteGroup (@PathVariable String groupId) throws NotFoundException {
        groupService.deleteGroup(groupId );
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{groupId}/subGroups")
    public ResponseEntity<Object> createSubGroup(
            @PathVariable String groupId,
            @RequestBody KeycloakAttributeDTO updatedGroup) throws ApiException {

            if (!groupId.equals(updatedGroup.getGroupId())) {
                throw new PreconditionFailedException("mismatched","id");
            }

            groupService.createSubGroup(updatedGroup);
            return ResponseEntity.ok().build();

    }


    @GetMapping("/{distributionId}")
    public Map<String, String> findSubGroupById(@PathVariable String distributionId) {
        return keycloakUserGroupViewService.findSubGroupByDistributionCompanyId(distributionId);
    }
}
