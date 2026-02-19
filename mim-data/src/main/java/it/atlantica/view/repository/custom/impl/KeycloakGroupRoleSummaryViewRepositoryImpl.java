package it.atlantica.view.repository.custom.impl;


import it.atlantica.config.KeycloakProperties;
import it.atlantica.dto.KeycloakGroupRoleSummaryDTO;
import it.atlantica.request.search.GroupSearchRequest;
import it.atlantica.service.keycloak.RealmService;
import it.atlantica.view.DistributionCompanyKeycloakGroupView;
import it.atlantica.view.KeycloakGroupRoleSummaryView;
import it.atlantica.view.repository.custom.KeycloakGroupRoleSummaryViewCustom;
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

public class KeycloakGroupRoleSummaryViewRepositoryImpl implements KeycloakGroupRoleSummaryViewCustom {
    @PersistenceContext
    private EntityManager entityManager;

    @Autowired
    private RealmService realmService;


    @Autowired
    private KeycloakProperties keycloakProperties;


    public Page<DistributionCompanyKeycloakGroupView> findByFilters(List<String> id_Company, Pageable pageable){
        String baseSelect = "SELECT k FROM DistributionCompanyKeycloakGroupView k ";
        String baseCount = "SELECT COUNT(k) FROM DistributionCompanyKeycloakGroupView k ";

        StringBuilder queryBuilder = new StringBuilder(baseSelect);
        queryBuilder.append("WHERE k.realmId = :realm_id ");

        queryBuilder.append("and k.idCompany in :idCompany ");
        String countBuilder = baseCount + "WHERE k.realmId = :realm_id " +
                "and  k.idCompany in :idCompany ";

        if (pageable.getSort().isSorted()) {
            String orderBy =  pageable.getSort().stream().map(order -> "k." + order.getProperty() + " " + order.getDirection().name())
                    .collect(Collectors.joining(", "));
            if (!orderBy.isBlank()) {
                queryBuilder.append("ORDER BY ").append(orderBy).append(" ");
            }
            System.out.println("OrderBy: " + orderBy);
        }
        TypedQuery<DistributionCompanyKeycloakGroupView> query = entityManager.createQuery(queryBuilder.toString(), DistributionCompanyKeycloakGroupView.class);
        TypedQuery<Long> countQuery = entityManager.createQuery(countBuilder, Long.class);
        query.setParameter("idCompany", id_Company);
        countQuery.setParameter("idCompany", id_Company);
        query.setParameter("realm_id", realmService.getIdRealm(keycloakProperties.getRealm()));
        countQuery.setParameter("realm_id",  realmService.getIdRealm(keycloakProperties.getRealm()));


        query.setFirstResult((int) pageable.getOffset());
        query.setMaxResults(pageable.getPageSize());

        System.out.println("Query finale: " + queryBuilder);
        System.out.println("Sort ricevuto: " + pageable.getSort());

        return new PageImpl<>(query.getResultList(), pageable, countQuery.getSingleResult());
    }

    @Override
    public Page<KeycloakGroupRoleSummaryDTO> findByFilters(GroupSearchRequest filters, Pageable pageable) {
        String baseFrom = "FROM KeycloakGroupRoleSummaryView k";

        List<String> conditions = new ArrayList<>();
        Map<String, Object> params = new HashMap<>();

        String realmId = realmService.getIdRealm(keycloakProperties.getRealm());
        conditions.add("k.realmId = :realm_id");
        params.put("realm_id", realmId);

        if (filters.getGroupName() != null && !filters.getGroupName().isBlank()) {
            conditions.add("k.groupName LIKE :groupName");
            params.put("groupName", "%" + filters.getGroupName() + "%");
        }

        if (filters.getGroupPath() != null && !filters.getGroupPath().isBlank()) {
            conditions.add("k.groupPath LIKE :groupPath");
            params.put("groupPath", "%" + filters.getGroupPath() + "%");
        }

        if (filters.getRoles() != null && !filters.getRoles().isEmpty()) {
            for (int i = 0; i < filters.getRoles().size(); i++) {
                String roleParam = "role" + i;
                conditions.add("k.roles LIKE :" + roleParam);
                params.put(roleParam, "%" + filters.getRoles().get(i) + "%");
            }
        }

        String where = conditions.isEmpty() ? "" : " WHERE " + String.join(" AND ", conditions);

        String selectQueryStr = "SELECT k " + baseFrom + where;
        String countQueryStr  = "SELECT COUNT(k) " + baseFrom + where;

        if (pageable.getSort().isSorted()) {
            String orderBy = pageable.getSort().stream()
                    .map(order -> "k." + order.getProperty() + " " + order.getDirection().name())
                    .collect(Collectors.joining(", "));
            if (!orderBy.isBlank()) {
                selectQueryStr += " ORDER BY " + orderBy;
            }
        }

        TypedQuery<KeycloakGroupRoleSummaryView> query =
                entityManager.createQuery(selectQueryStr, KeycloakGroupRoleSummaryView.class);
        TypedQuery<Long> countQuery =
                entityManager.createQuery(countQueryStr, Long.class);

        params.forEach((k, v) -> {
            query.setParameter(k, v);
            countQuery.setParameter(k, v);
        });

        query.setFirstResult((int) pageable.getOffset());
        query.setMaxResults(pageable.getPageSize());

        List<KeycloakGroupRoleSummaryView> entities = query.getResultList();
        long total = countQuery.getSingleResult();

        List<KeycloakGroupRoleSummaryDTO> dtos = entities.stream()
                .map(e -> new KeycloakGroupRoleSummaryDTO(
                        e.getGroupID(),
                        e.getGroupName(),
                        e.getRealmId(),
                        e.getRoles(),
                        e.getCurrentGroupName(),
                        e.getDistributionCompanyID(),
                        e.getDistributionCompanyName(),
                        e.getAttributesCurrent(),
                        e.getGroupPath()
                ))
                .toList();

        return new PageImpl<>(dtos, pageable, total);
    }


}
