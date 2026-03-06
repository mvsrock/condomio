package it.condomio.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.CondominioRoot;

@Repository
public interface CondominioRootRepository extends MongoRepository<CondominioRoot, String> {
    List<CondominioRoot> findByAdminKeycloakUserIdOrderByLabelKeyAsc(String adminKeycloakUserId);
    Optional<CondominioRoot> findByAdminKeycloakUserIdAndLabelKey(String adminKeycloakUserId, String labelKey);
    Optional<CondominioRoot> findByIdAndAdminKeycloakUserId(String id, String adminKeycloakUserId);
    boolean existsByIdAndAdminKeycloakUserId(String id, String adminKeycloakUserId);
}
