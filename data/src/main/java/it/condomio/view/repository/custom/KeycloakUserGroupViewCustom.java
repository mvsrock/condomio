package it.condomio.view.repository.custom;


import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import it.condomio.request.search.UserSearchRequest;
import it.condomio.view.KeycloakUserGroupView;

public interface KeycloakUserGroupViewCustom {

    Page<KeycloakUserGroupView> findByFilters(UserSearchRequest filters, Pageable pageable);
}
