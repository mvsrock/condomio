package it.condomio.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.data.mongodb.repository.Update;
import org.springframework.stereotype.Repository;

import it.condomio.document.Condomino;

@Repository
public interface CondominoRepository extends MongoRepository<Condomino, String>, CondominoRepositoryCustom {
    List<Condomino> findByIdCondominio(String idCondominio);
    List<Condomino> findByIdCondominioIn(List<String> condominioIds);
    Optional<Condomino> findByIdAndIdCondominioIn(String id, List<String> condominioIds);
    boolean existsByIdAndIdCondominioIn(String id, List<String> condominioIds);
    boolean existsByIdCondominioAndEmailIgnoreCase(String idCondominio, String email);
    boolean existsByIdCondominioAndEmailIgnoreCaseAndIdNot(String idCondominio, String email, String id);

    // Associazione utente applicativo (Keycloak) <-> condomino.
    List<Condomino> findByKeycloakUserId(String keycloakUserId);
    Optional<Condomino> findByKeycloakUserIdAndIdCondominio(String keycloakUserId, String idCondominio);
    boolean existsByIdCondominioAndKeycloakUserId(String idCondominio, String keycloakUserId);

    /** Update puntuale residuo di un condomino specifico nel condominio atteso. */
    @Query("{ '_id': ?0, 'idCondominio': ?1 }")
    @Update("{ '$set': { 'residuo': ?2 } }")
    long setResiduoByIdAndCondominio(String id, String idCondominio, double residuo);

    /** Delta contabile su residuo condomino (incrementale). */
    @Query("{ '_id': ?0, 'idCondominio': ?1 }")
    @Update("{ '$inc': { 'residuo': ?2 } }")
    long incResiduoByIdAndCondominio(String id, String idCondominio, double delta);
}

interface CondominoRepositoryCustom {
    // metodi custom eventuali
}
