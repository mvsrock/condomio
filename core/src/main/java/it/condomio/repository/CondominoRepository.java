package it.condomio.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.Condomino;

@Repository
public interface CondominoRepository extends MongoRepository<Condomino, String>, CondominoRepositoryCustom {
    List<Condomino> findByIdCondominioIn(List<String> condominioIds);
    Optional<Condomino> findByIdAndIdCondominioIn(String id, List<String> condominioIds);
    boolean existsByIdAndIdCondominioIn(String id, List<String> condominioIds);
    boolean existsByIdCondominioAndEmailIgnoreCase(String idCondominio, String email);
    boolean existsByIdCondominioAndEmailIgnoreCaseAndIdNot(String idCondominio, String email, String id);

    // Associazione utente applicativo (Keycloak) <-> condomino.
    List<Condomino> findByKeycloakUserId(String keycloakUserId);
    Optional<Condomino> findByKeycloakUserIdAndIdCondominio(String keycloakUserId, String idCondominio);
    boolean existsByIdCondominioAndKeycloakUserId(String idCondominio, String keycloakUserId);
}

interface CondominoRepositoryCustom {
    // metodi custom eventuali
}
