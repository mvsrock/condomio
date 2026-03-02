package it.condomio.view;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import it.condomio.PageDto;
import it.condomio.request.search.KeycloakRoleGroupRequest;
import it.condomio.request.search.RoleSearchRequest;
import it.condomio.view.repository.KeycloakRoleGroupSummaryViewRepository;

@Service
public class KeycloakRoleGroupSummaryViewService {

	@Autowired
	private KeycloakRoleGroupSummaryViewRepository keycloakRoleGroupSummaryViewRepository;
  /*  @Cacheable(
            cacheNames = "roleSearch",
            condition = "@environment.getProperty('app.cache.enabled', T(java.lang.Boolean), false)",
            unless     = "#result == null || #result.content().isEmpty()",
            key = "T(java.util.Objects).hash(" +
                    "T(java.util.List).of(" +
                    "T(java.util.Objects).toString(#filters?.groupsName, '')," +
                    "T(java.util.Objects).toString(#filters?.roleName, '')," +
                    "#pageable.pageNumber, #pageable.pageSize, #pageable.sort.toString())" +
                    ")"
    )*/
    public PageDto<KeycloakRoleGroupRequest> findByFilters(RoleSearchRequest filters,
                                                           Pageable pageable) {
        var page = keycloakRoleGroupSummaryViewRepository.findByFilters(filters, pageable);
        return PageDto.fromPage(page);
	}

}
