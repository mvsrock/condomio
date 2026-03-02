package it.condomio.controller;


import java.util.List;

import org.keycloak.representations.idm.UserRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.Errors;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import it.condomio.PageDto;
import it.condomio.dto.AddUserGroupDTO;
import it.condomio.dto.KeycloakUserUpdateDTO;
import it.condomio.exception.ValidationFailedException;
import it.condomio.request.search.UserSearchRequest;
import it.condomio.response.PageResponse;
import it.condomio.service.UserKeycloakService;
import it.condomio.view.KeycloakGroupRoleSummaryView;
import it.condomio.view.KeycloakUserGroupView;
import it.condomio.view.KeycloakUserGroupViewService;
import it.condomio.view.repository.KeycloakGroupRoleSummaryViewRepository;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserKeycloakService userService;

    @Autowired
    private KeycloakUserGroupViewService groupViewRepository;

    @Autowired
    private KeycloakGroupRoleSummaryViewRepository groupRoleSummaryViewRepository;


    public UserController(UserKeycloakService userService) {
        this.userService = userService;
    }
  //  @Autowired
 //   private NextPagePrefetcher prefetcher;

    @PostMapping
    public ResponseEntity<UserRepresentation> createUser(@RequestBody KeycloakUserUpdateDTO register) {
        return ResponseEntity.ok( userService.createUser(register));
    }
    @GetMapping
    public ResponseEntity<PageResponse<KeycloakUserGroupView>> searchUsers(@Valid UserSearchRequest userSearchRequest, final Errors errors,
                                                                           @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int size,
                                                                           @RequestParam() String sort, @RequestParam() String direction
    ) throws ValidationFailedException {
        if (errors.hasErrors()) {
            throw new ValidationFailedException("user", errors);
        }
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.fromString(direction), sort));
        PageDto<KeycloakUserGroupView> pageResult = groupViewRepository.findByFilters(userSearchRequest, pageable);
       /* prefetcher.prefetchNext(
                userSearchRequest,
                pageable,
                pageResult.totalPages(),
                (UserSearchRequest f, Pageable p) -> groupViewRepository.findByFilters(f, p)
        );*/
        return ResponseEntity.ok(new PageResponse<>(pageResult));
    }


    @PutMapping()
    public ResponseEntity<Void> updateUser(@RequestBody KeycloakUserUpdateDTO dto) {
        userService.updateUserAndMoveGroup(dto);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> deleteUser(@RequestParam(name = "userId") String user_id,@RequestParam(name = "groupId")String group_id) {
        userService.leaveGroup(user_id, group_id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{userId}/disable")
    public ResponseEntity<Void> updateUser(@PathVariable (name = "userId") String user_id) {
        userService.disabledUser(user_id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> deleteUserFromKeycloak(@PathVariable(name = "userId") String userId) {
        userService.deleteUserFromKeycloak(userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{userId}/not_groups")
    public List<KeycloakGroupRoleSummaryView> distributionNotIn(@PathVariable String userId) {
        return groupRoleSummaryViewRepository.findByDistributionCompanyNameNotIn(groupViewRepository.findDistributionCompanyNamesByUserId(userId));
    }

    @PostMapping("/{userId}/add_groups")
    public void addUserToGroups(@PathVariable String userId,
                                @RequestBody AddUserGroupDTO request) {
        userService.addGroupToUser(userId,request.getGroupIds());
    }

}
