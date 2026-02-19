package it.atlantica.view.repository.custom;


import it.atlantica.request.search.UserSearchRequest;
import it.atlantica.view.KeycloakUserGroupView;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface KeycloakUserGroupViewCustom {

    Page<KeycloakUserGroupView> findByFilters(UserSearchRequest filters, Pageable pageable);
}
