package it.atlantica.view.repository.custom;


import it.atlantica.dto.KeycloakGroupRoleSummaryDTO;
import it.atlantica.request.search.GroupSearchRequest;
import it.atlantica.view.DistributionCompanyKeycloakGroupView;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface KeycloakGroupRoleSummaryViewCustom {
    Page<DistributionCompanyKeycloakGroupView> findByFilters(List<String> id_Company, Pageable pageable);

    Page<KeycloakGroupRoleSummaryDTO> findByFilters(GroupSearchRequest filters, Pageable pageable);

}
