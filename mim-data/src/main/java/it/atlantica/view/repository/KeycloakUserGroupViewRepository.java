package it.atlantica.view.repository;


import it.atlantica.view.KeycloakUserGroupView;
import it.atlantica.view.repository.custom.KeycloakUserGroupViewCustom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface KeycloakUserGroupViewRepository extends JpaRepository<KeycloakUserGroupView, String>, KeycloakUserGroupViewCustom {
    @Query("SELECT k.distributionCompany FROM KeycloakUserGroupView k WHERE k.userId = :userId")
    List<String> findDistributionCompanyNamesByUserId(@Param("userId") String userId);

}
