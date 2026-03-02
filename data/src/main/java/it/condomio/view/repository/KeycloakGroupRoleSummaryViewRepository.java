package it.condomio.view.repository;



import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import it.condomio.view.KeycloakGroupRoleSummaryView;
import it.condomio.view.repository.custom.KeycloakGroupRoleSummaryViewCustom;

public interface KeycloakGroupRoleSummaryViewRepository extends JpaRepository<KeycloakGroupRoleSummaryView, String>, KeycloakGroupRoleSummaryViewCustom {
    List<KeycloakGroupRoleSummaryView> findByDistributionCompanyNameNotIn(List<String> excludedCompanies);


    List<KeycloakGroupRoleSummaryView> findByDistributionCompanyID(String distributionCompanyID);
}
