package it.atlantica.view.repository;


import it.atlantica.view.KeycloakRoleGroupSummaryView;
import it.atlantica.view.repository.custom.KeycloakRoleGroupSummaryViewCustom;
import org.springframework.data.jpa.repository.JpaRepository;

public interface KeycloakRoleGroupSummaryViewRepository extends JpaRepository<KeycloakRoleGroupSummaryView, String>, KeycloakRoleGroupSummaryViewCustom {

}
