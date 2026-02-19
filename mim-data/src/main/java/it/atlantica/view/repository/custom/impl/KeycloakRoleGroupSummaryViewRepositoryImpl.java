package it.atlantica.view.repository.custom.impl;



import it.atlantica.config.KeycloakProperties;
import it.atlantica.request.search.KeycloakRoleGroupRequest;
import it.atlantica.request.search.RoleSearchRequest;
import it.atlantica.service.keycloak.RealmService;
import it.atlantica.view.KeycloakRoleGroupSummaryView;
import it.atlantica.view.repository.custom.KeycloakRoleGroupSummaryViewCustom;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class KeycloakRoleGroupSummaryViewRepositoryImpl implements KeycloakRoleGroupSummaryViewCustom {
    @PersistenceContext
    private EntityManager entityManager;


    @Autowired
    private RealmService realmService;
    @Autowired
    private KeycloakProperties keycloakProperties;

    @Override
    public Page<KeycloakRoleGroupRequest> findByFilters(RoleSearchRequest filters, Pageable pageable) {
        String baseFrom = "FROM KeycloakRoleGroupSummaryView k";

        List<String> conditions = new ArrayList<>();
        Map<String, Object> params = new HashMap<>();

        String realmId = realmService.getIdRealm(keycloakProperties.getRealm());
        conditions.add("k.realmId = :realm_id");
        params.put("realm_id", realmId);

        if (filters.getRoleName() != null
                && !filters.getRoleName().isBlank()
                && !"null".equalsIgnoreCase(filters.getRoleName())) {
            conditions.add("LOWER(k.roleName) LIKE LOWER(:roleName)");
            params.put("roleName", "%" + filters.getRoleName() + "%");
        }

        if (filters.getGroupsName() != null && !filters.getGroupsName().isEmpty()) {
            int index = 0;
            for (String role : filters.getGroupsName()) {
                if (role != null && !role.isBlank()) {
                    String param = "groupName" + index++;
                    conditions.add("k.groupName LIKE :" + param);
                    params.put(param, "%" + role + "%");
                }
            }
        }

        String where = conditions.isEmpty() ? "" : " WHERE " + String.join(" AND ", conditions);

        String selectQueryStr = "SELECT k " + baseFrom + where;
        String countQueryStr  = "SELECT COUNT(k) " + baseFrom + where;

        if (pageable.getSort().isSorted()) {
            String orderBy = pageable.getSort().stream()
                    .map(order -> "k." + order.getProperty() + " " + order.getDirection())
                    .collect(Collectors.joining(", "));
            if (!orderBy.isBlank()) {
                selectQueryStr += " ORDER BY " + orderBy;
            }
        }

        TypedQuery<KeycloakRoleGroupSummaryView> query =
                entityManager.createQuery(selectQueryStr, KeycloakRoleGroupSummaryView.class);
        TypedQuery<Long> countQuery =
                entityManager.createQuery(countQueryStr, Long.class);

        params.forEach((k, v) -> {
            query.setParameter(k, v);
            countQuery.setParameter(k, v);
        });

        query.setFirstResult((int) pageable.getOffset());
        query.setMaxResults(pageable.getPageSize());

        List<KeycloakRoleGroupSummaryView> entities = query.getResultList();
        long total = countQuery.getSingleResult();

        List<KeycloakRoleGroupRequest> dtos = entities.stream()
                .map(e -> new KeycloakRoleGroupRequest(
                        e.getRolesId(),
                        e.getRoleName(),
                        e.getGroupName(),
                        e.getDescription()
                ))
                .toList();

        return new PageImpl<>(dtos, pageable, total);
    }



}
