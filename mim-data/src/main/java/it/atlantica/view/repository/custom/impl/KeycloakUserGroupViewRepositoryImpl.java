package it.atlantica.view.repository.custom.impl;



import it.atlantica.config.KeycloakProperties;
import it.atlantica.request.search.UserSearchRequest;
import it.atlantica.service.keycloak.RealmService;
import it.atlantica.view.KeycloakUserGroupView;
import it.atlantica.view.repository.custom.KeycloakUserGroupViewCustom;
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

public class KeycloakUserGroupViewRepositoryImpl implements KeycloakUserGroupViewCustom {

    @PersistenceContext
    private EntityManager entityManager;
    
    @Autowired
    private RealmService realmService;

    @Autowired
    private KeycloakProperties keycloakProperties;

    @Override
    public Page<KeycloakUserGroupView> findByFilters(UserSearchRequest filters, Pageable pageable) {
        StringBuilder queryBuilder = new StringBuilder("FROM KeycloakUserGroupView k");
        Map<String, Object> params = new HashMap<>();
        List<String> conditions = new ArrayList<>();

        String realmId = realmService.getIdRealm(keycloakProperties.getRealm());
        conditions.add("k.realmId = :realm_id");
        params.put("realm_id", realmId);

        if (filters.getEmail() != null && !filters.getEmail().isBlank()) {
            conditions.add("LOWER(k.email) LIKE LOWER(:email)");
            params.put("email", "%" + filters.getEmail() + "%");
        }

        if (filters.getFirstName() != null && !filters.getFirstName().isBlank()) {
            conditions.add("LOWER(k.firstName) LIKE LOWER(:firstName)");
            params.put("firstName", "%" + filters.getFirstName() + "%");
        }

        if (filters.getLastName() != null && !filters.getLastName().isBlank()) {
            conditions.add("LOWER(k.lastName) LIKE LOWER(:lastName)");
            params.put("lastName", "%" + filters.getLastName() + "%");
        }

        if (filters.getUsername() != null && !filters.getUsername().isBlank()) {
            conditions.add("LOWER(k.username) LIKE LOWER(:username)");
            params.put("username", "%" + filters.getUsername() + "%");
        }

        if (filters.getGroupName() != null && !filters.getGroupName().isBlank()) {
            conditions.add("LOWER(k.groupName) LIKE LOWER(:groupName)");
            params.put("groupName", "%" + filters.getGroupName() + "%");
        }

        if (filters.getDistributionCompany() != null && !filters.getDistributionCompany().isBlank()) {
            conditions.add("LOWER(k.distributionCompany) LIKE LOWER(:distributionCompany)");
            params.put("distributionCompany", "%" + filters.getDistributionCompany() + "%");
        }

        if (!conditions.isEmpty()) {
            queryBuilder.append(" WHERE ")
                    .append(String.join(" AND ", conditions));
        }

        String selectQuery = "SELECT k " + queryBuilder;
        String countQuery = "SELECT COUNT(k) " + queryBuilder;

        if (pageable.getSort().isSorted()) {
            String orderBy = pageable.getSort().stream()
                    .map(order -> "k." + order.getProperty() + " " + order.getDirection())
                    .collect(Collectors.joining(", "));
            if (!orderBy.isBlank()) {
                selectQuery += " ORDER BY " + orderBy;
            }
        }

        TypedQuery<KeycloakUserGroupView> query = entityManager.createQuery(selectQuery, KeycloakUserGroupView.class);
        TypedQuery<Long> countQ = entityManager.createQuery(countQuery, Long.class);

        params.forEach((key, value) -> {
            query.setParameter(key, value);
            countQ.setParameter(key, value);
        });

        query.setFirstResult((int) pageable.getOffset());
        query.setMaxResults(pageable.getPageSize());

        List<KeycloakUserGroupView> results = query.getResultList();
        long total = countQ.getSingleResult();

        return new PageImpl<>(results, pageable, total);
    }

}
