package it.condomio.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.data.mongodb.repository.Update;
import org.springframework.stereotype.Repository;

import it.condomio.document.Condominio;

@Repository
public interface CondominioRepository extends MongoRepository<Condominio, String>, CondominioRepositoryCustom {
    List<Condominio> findByAdminKeycloakUserId(String adminKeycloakUserId);
    List<Condominio> findByAdminKeycloakUserIdOrderByAnnoDesc(String adminKeycloakUserId);
    List<Condominio> findByCondominioRootIdOrderByAnnoDesc(String condominioRootId);
    List<Condominio> findByCondominioRootIdAndGestioneCodiceOrderByAnnoDesc(
            String condominioRootId,
            String gestioneCodice);
    List<Condominio> findByCondominioRootIdAndStatoOrderByAnnoDesc(
            String condominioRootId,
            Condominio.EsercizioStato stato);
    Optional<Condominio> findFirstByCondominioRootIdOrderByAnnoDesc(String condominioRootId);
    Optional<Condominio> findFirstByCondominioRootIdAndGestioneCodiceOrderByAnnoDesc(
            String condominioRootId,
            String gestioneCodice);
    Optional<Condominio> findFirstByCondominioRootIdAndStatoOrderByAnnoDesc(
            String condominioRootId,
            Condominio.EsercizioStato stato);
    Optional<Condominio> findFirstByCondominioRootIdAndGestioneCodiceAndStatoOrderByAnnoDesc(
            String condominioRootId,
            String gestioneCodice,
            Condominio.EsercizioStato stato);
    Optional<Condominio> findByIdAndAdminKeycloakUserId(String id, String adminKeycloakUserId);
    Optional<Condominio> findByCondominioRootIdAndAnno(String condominioRootId, Long anno);
    Optional<Condominio> findByCondominioRootIdAndGestioneCodiceAndAnno(
            String condominioRootId,
            String gestioneCodice,
            Long anno);
    boolean existsByIdAndAdminKeycloakUserId(String id, String adminKeycloakUserId);
    boolean existsByCondominioRootIdAndAnno(String condominioRootId, Long anno);
    boolean existsByCondominioRootIdAndGestioneCodiceAndAnno(
            String condominioRootId,
            String gestioneCodice,
            Long anno);
    boolean existsByAnnoAndLabelIgnoreCase(Long anno, String label);

    /** Update puntuale residuo: singolo documento condominio. */
    @Query("{ '_id': ?0 }")
    @Update("{ '$set': { 'residuo': ?1 } }")
    long setResiduoById(String id, double residuo);

    /** Delta contabile su residuo condominio (incrementale). */
    @Query("{ '_id': ?0 }")
    @Update("{ '$inc': { 'residuo': ?1 } }")
    long incResiduoById(String id, double delta);

    /** Propaga il label snapshot su tutti gli esercizi del root. */
    @Query("{ 'condominioRootId': ?0 }")
    @Update("{ '$set': { 'label': ?1 } }")
    long setLabelSnapshotByRootId(String condominioRootId, String label);
}

interface CondominioRepositoryCustom {
    // qui puoi dichiarare i tuoi metodi custom
}

