package it.condomio.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.data.mongodb.repository.Update;
import org.springframework.stereotype.Repository;

import it.condomio.document.Condominio;
import java.util.List;
import java.util.Optional;

@Repository
public interface CondominioRepository extends MongoRepository<Condominio, String>, CondominioRepositoryCustom {
    List<Condominio> findByAdminKeycloakUserId(String adminKeycloakUserId);
    Optional<Condominio> findByIdAndAdminKeycloakUserId(String id, String adminKeycloakUserId);
    boolean existsByIdAndAdminKeycloakUserId(String id, String adminKeycloakUserId);
    boolean existsByAnnoAndLabelIgnoreCase(Long anno, String label);

    /** Update puntuale residuo: singolo documento condominio. */
    @Query("{ '_id': ?0 }")
    @Update("{ '$set': { 'residuo': ?1 } }")
    long setResiduoById(String id, double residuo);

    /** Delta contabile su residuo condominio (incrementale). */
    @Query("{ '_id': ?0 }")
    @Update("{ '$inc': { 'residuo': ?1 } }")
    long incResiduoById(String id, double delta);
}

interface CondominioRepositoryCustom {
    // qui puoi dichiarare i tuoi metodi custom
}

