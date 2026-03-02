package it.condomio.repository.keycloak;



import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import it.condomio.entity.keycloak.KeycloakRole;


@Repository
public interface KeycloakRoleRepository extends JpaRepository<KeycloakRole, String> {
    List<KeycloakRole> findByNameIn(List<String> names);
}