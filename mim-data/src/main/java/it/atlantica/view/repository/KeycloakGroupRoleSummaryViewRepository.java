package it.atlantica.view.repository;



import it.atlantica.view.KeycloakGroupRoleSummaryView;
import it.atlantica.view.repository.custom.KeycloakGroupRoleSummaryViewCustom;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface KeycloakGroupRoleSummaryViewRepository extends JpaRepository<KeycloakGroupRoleSummaryView, String>, KeycloakGroupRoleSummaryViewCustom {
    List<KeycloakGroupRoleSummaryView> findByDistributionCompanyNameNotIn(List<String> excludedCompanies);


    List<KeycloakGroupRoleSummaryView> findByDistributionCompanyID(String distributionCompanyID);
}
