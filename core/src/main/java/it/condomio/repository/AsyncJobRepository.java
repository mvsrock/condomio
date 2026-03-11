package it.condomio.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.AsyncJob;

@Repository
public interface AsyncJobRepository extends MongoRepository<AsyncJob, String> {
    Optional<AsyncJob> findByIdAndRequesterKeycloakUserId(String id, String requesterKeycloakUserId);
    List<AsyncJob> findByRequesterKeycloakUserIdOrderByCreatedAtDesc(String requesterKeycloakUserId);
    List<AsyncJob> findByRequesterKeycloakUserIdOrderByCreatedAtDesc(
            String requesterKeycloakUserId,
            Pageable pageable);
}
