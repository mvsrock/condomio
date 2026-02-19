package it.atlantica.view.repository.custom;



import it.atlantica.request.search.KeycloakRoleGroupRequest;
import it.atlantica.request.search.RoleSearchRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface KeycloakRoleGroupSummaryViewCustom {
    Page<KeycloakRoleGroupRequest> findByFilters(RoleSearchRequest filters, Pageable pageable);

}
