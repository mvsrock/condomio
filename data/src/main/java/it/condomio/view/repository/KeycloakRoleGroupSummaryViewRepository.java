package it.condomio.view.repository;


import org.springframework.data.jpa.repository.JpaRepository;

import it.condomio.view.KeycloakRoleGroupSummaryView;
import it.condomio.view.repository.custom.KeycloakRoleGroupSummaryViewCustom;

public interface KeycloakRoleGroupSummaryViewRepository extends JpaRepository<KeycloakRoleGroupSummaryView, String>, KeycloakRoleGroupSummaryViewCustom {

}
