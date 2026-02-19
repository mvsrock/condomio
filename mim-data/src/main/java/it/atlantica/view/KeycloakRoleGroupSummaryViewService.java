package it.atlantica.view;


import it.atlantica.PageDto;
import it.atlantica.request.search.KeycloakRoleGroupRequest;
import it.atlantica.request.search.RoleSearchRequest;
import it.atlantica.view.repository.KeycloakRoleGroupSummaryViewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

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
