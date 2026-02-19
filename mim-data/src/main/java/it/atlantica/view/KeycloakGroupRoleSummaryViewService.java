package it.atlantica.view;


import it.atlantica.dto.KeycloakGroupRoleSummaryDTO;
import it.atlantica.request.search.GroupSearchRequest;
import it.atlantica.view.repository.KeycloakGroupRoleSummaryViewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class KeycloakGroupRoleSummaryViewService {

	@Autowired
	private KeycloakGroupRoleSummaryViewRepository keycloakGroupRoleSummaryViewRepository;



	public Page<DistributionCompanyKeycloakGroupView> findByFilters(List<String> id_Company, Pageable pageable){
		return keycloakGroupRoleSummaryViewRepository.findByFilters(id_Company, pageable);
	}

    public Page<KeycloakGroupRoleSummaryDTO> findByFilters(GroupSearchRequest filters,
                                                           Pageable pageable) {
        return keycloakGroupRoleSummaryViewRepository.findByFilters(filters, pageable);
    }

    public Map<String, String> findSubGroupByDistributionCompanyId(String id) {
        List<KeycloakGroupRoleSummaryView> lists= keycloakGroupRoleSummaryViewRepository.findByDistributionCompanyID(id);
        Map<String, String> map = new HashMap<>();
        for (KeycloakGroupRoleSummaryView item : lists) {
            map.put(item.getGroupID(), item.getGroupPath()!=null && !item.getGroupPath().isEmpty()? item.getGroupName()+'/'+item.getGroupPath(): item.getGroupName());

        }
        return map;

    }
}
