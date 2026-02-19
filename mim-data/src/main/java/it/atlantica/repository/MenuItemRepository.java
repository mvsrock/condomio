package it.atlantica.repository;



import it.atlantica.entity.MenuItem;
import it.atlantica.entity.keycloak.KeycloakRole;
import it.atlantica.repository.custom.MenuItemRepositoryCustom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MenuItemRepository extends JpaRepository<MenuItem, Long>, MenuItemRepositoryCustom {

	MenuItem findByItem(String parent);
    List<MenuItem> findByParent(MenuItem parent);

	@Query("SELECT m FROM MenuItem m WHERE m.role IN :roles  and m.visible is true ORDER BY m.visualOrder ASC")
	List<MenuItem> findByRoles(@Param("roles") List<KeycloakRole> roles);
}