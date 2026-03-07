package it.condomio.repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.CondominoRoot;

@Repository
public interface CondominoRootRepository extends MongoRepository<CondominoRoot, String> {

    List<CondominoRoot> findByIdIn(Collection<String> ids);

    List<CondominoRoot> findByKeycloakUserId(String keycloakUserId);

    Optional<CondominoRoot> findByCondominioRootIdAndEmail(String condominioRootId, String email);

    Optional<CondominoRoot> findByCondominioRootIdAndKeycloakUserId(String condominioRootId, String keycloakUserId);

    boolean existsByCondominioRootIdAndEmailAndIdNot(String condominioRootId, String email, String id);

    boolean existsByCondominioRootIdAndKeycloakUserIdAndIdNot(
            String condominioRootId,
            String keycloakUserId,
            String id);
}
