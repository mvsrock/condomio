package it.condomio.repository;



import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import it.condomio.entity.MenuItem;
import it.condomio.entity.keycloak.KeycloakRole;
import it.condomio.repository.custom.MenuItemRepositoryCustom;

@Repository
public interface MenuItemRepository extends JpaRepository<MenuItem, Long>, MenuItemRepositoryCustom {

	MenuItem findByItem(String parent);
    List<MenuItem> findByParent(MenuItem parent);

	@Query("SELECT m FROM MenuItem m WHERE m.role IN :roles  and m.visible is true ORDER BY m.visualOrder ASC")
	List<MenuItem> findByRoles(@Param("roles") List<KeycloakRole> roles);
}