package it.atlantica.repository.keycloak;



import it.atlantica.entity.keycloak.KeycloakRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface KeycloakRoleRepository extends JpaRepository<KeycloakRole, String> {
    List<KeycloakRole> findByNameIn(List<String> names);
}