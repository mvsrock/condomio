package it.atlantica.repository.custom.impl;



import it.atlantica.config.KeycloakProperties;
import it.atlantica.dto.MenuItemDto;
import it.atlantica.entity.MenuItem;
import it.atlantica.repository.custom.MenuItemRepositoryCustom;
import it.atlantica.request.search.MenuSearchRequest;
import it.atlantica.service.keycloak.RealmService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class MenuItemRepositoryImpl implements MenuItemRepositoryCustom {

    @PersistenceContext
    private EntityManager entityManager;

    private final RealmService realmService;
    private final KeycloakProperties keycloakProperties;

    public MenuItemRepositoryImpl(RealmService realmService, KeycloakProperties keycloakProperties) {
        this.realmService = realmService;
        this.keycloakProperties = keycloakProperties;
    }

    @Override
    public Page<MenuItemDto> findByFilters(MenuSearchRequest filters, Pageable pageable) {
        StringBuilder selectQuery = new StringBuilder("SELECT k FROM MenuItem k ");
        StringBuilder countQuery = new StringBuilder("SELECT COUNT(k) FROM MenuItem k ");
        Map<String, Object> params = new HashMap<>();

        StringBuilder where = new StringBuilder();

        String realmId = realmService.getIdRealm(keycloakProperties.getRealm());
        where.append("k.role.realmId = :realm_id ");
        params.put("realm_id", realmId);

        if (filters.getLabel() != null && !filters.getLabel().isBlank()) {
            where.append("AND LOWER(k.label) LIKE LOWER(CONCAT('%', :label, '%')) ");
            params.put("label", filters.getLabel());
        }

        if (filters.getParent() != null && !filters.getParent().isBlank()) {
            where.append("AND LOWER(k.parent.label) LIKE LOWER(CONCAT('%', :parent, '%')) ");
            params.put("parent", filters.getParent());
        }

        if (filters.getRoleId() != null && !filters.getRoleId().isBlank()) {
            where.append("AND k.role.id = :role_id ");
            params.put("role_id", filters.getRoleId());
        }

        if (!where.isEmpty()) {
            selectQuery.append("WHERE ").append(where);
            countQuery.append("WHERE ").append(where);
        }

        if (pageable.getSort().isSorted()) {
            String orderBy = pageable.getSort().stream()
                    .map(order -> "k." + order.getProperty() + " " + order.getDirection().name())
                    .collect(Collectors.joining(", "));
            selectQuery.append("ORDER BY ").append(orderBy);
        }

        TypedQuery<MenuItem> query = entityManager.createQuery(selectQuery.toString(), MenuItem.class);
        TypedQuery<Long> count = entityManager.createQuery(countQuery.toString(), Long.class);

        params.forEach((key, value) -> {
            query.setParameter(key, value);
            count.setParameter(key, value);
        });

        query.setFirstResult((int) pageable.getOffset());
        query.setMaxResults(pageable.getPageSize());

        List<MenuItemDto> dtos = query.getResultList().stream()
                .map(this::toDto)
                .toList();

        long total = count.getSingleResult();

        return new PageImpl<>(dtos, pageable, total);
    }



    public MenuItemDto toDto(MenuItem menuItem) {
        return new MenuItemDto(
                menuItem.getId(),
                menuItem.getItem(),
                menuItem.getLabel(),
                menuItem.getDescription(),
                menuItem.getParent() != null  ? menuItem.getParent().getLabel() : null,
                menuItem.getParent() != null   ? menuItem.getParent().getId() : null,
                menuItem.getVisualOrder(),
                menuItem.getUri(),
                menuItem.getIcon(),
                menuItem.getRole() != null ? menuItem.getRole().getRealmId() : null,
                menuItem.getRole() != null ? menuItem.getRole().getId() : null,
                menuItem.isVisible(),
                menuItem.getRole()!=null? menuItem.getRole().getName(): null
        );
    }
}
