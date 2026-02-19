package it.atlantica.view;


import it.atlantica.PageDto;
import it.atlantica.request.search.UserSearchRequest;
import it.atlantica.view.repository.KeycloakUserGroupViewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class KeycloakUserGroupViewService {

	@Autowired
	private KeycloakUserGroupViewRepository groupViewRepository;

//    @Cacheable(
//            cacheNames = "userSearch",
//            condition = "@environment.getProperty('app.cache.enabled', T(java.lang.Boolean), false)",
//            unless     = "#result == null || #result.content().isEmpty()",
//            key = "T(java.util.Objects).hash(" +
//                    "T(java.util.List).of(" +
//                    "T(java.util.Objects).toString(#filters?.email, '')," +
//                    "T(java.util.Objects).toString(#filters?.firstName, '')," +
//                    "T(java.util.Objects).toString(#filters?.lastName, '')," +
//                    "T(java.util.Objects).toString(#filters?.username, '')," +
//                    "T(java.util.Objects).toString(#filters?.groupName, '')," +
//                    "T(java.util.Objects).toString(#filters?.distributionCompany, '')," +
//                    "#pageable.pageNumber, #pageable.pageSize, #pageable.sort.toString())" +
//                    ")"
//    )
    public PageDto<KeycloakUserGroupView> findByFilters(UserSearchRequest filters, Pageable pageable) {
        var page = groupViewRepository.findByFilters(filters, pageable);
        return PageDto.fromPage(page);
    }

    public List<String> findDistributionCompanyNamesByUserId(String id) {
        return groupViewRepository.findDistributionCompanyNamesByUserId(id);
    }


}
