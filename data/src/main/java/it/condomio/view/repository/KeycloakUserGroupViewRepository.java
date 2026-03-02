package it.condomio.view.repository;


import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import it.condomio.view.KeycloakUserGroupView;
import it.condomio.view.repository.custom.KeycloakUserGroupViewCustom;

@Repository
public interface KeycloakUserGroupViewRepository extends JpaRepository<KeycloakUserGroupView, String>, KeycloakUserGroupViewCustom {
    @Query("SELECT k.distributionCompany FROM KeycloakUserGroupView k WHERE k.userId = :userId")
    List<String> findDistributionCompanyNamesByUserId(@Param("userId") String userId);

}
