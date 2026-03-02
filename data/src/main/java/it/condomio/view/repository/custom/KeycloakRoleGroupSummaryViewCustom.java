package it.condomio.view.repository.custom;



import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import it.condomio.request.search.KeycloakRoleGroupRequest;
import it.condomio.request.search.RoleSearchRequest;

public interface KeycloakRoleGroupSummaryViewCustom {
    Page<KeycloakRoleGroupRequest> findByFilters(RoleSearchRequest filters, Pageable pageable);

}
