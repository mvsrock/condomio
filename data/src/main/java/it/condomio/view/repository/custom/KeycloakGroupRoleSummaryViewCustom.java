package it.condomio.view.repository.custom;


import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import it.condomio.dto.KeycloakGroupRoleSummaryDTO;
import it.condomio.request.search.GroupSearchRequest;
import it.condomio.view.DistributionCompanyKeycloakGroupView;

public interface KeycloakGroupRoleSummaryViewCustom {
    Page<DistributionCompanyKeycloakGroupView> findByFilters(List<String> id_Company, Pageable pageable);

    Page<KeycloakGroupRoleSummaryDTO> findByFilters(GroupSearchRequest filters, Pageable pageable);

}
