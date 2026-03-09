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
    List<Condomino> findByIdCondominioOrderByCognomeAscNomeAsc(String idCondominio);
    List<Condomino> findByIdCondominioIn(List<String> condominioIds);
    boolean existsByIdCondominio(String idCondominio);
    Optional<Condomino> findByIdAndIdCondominioIn(String id, List<String> condominioIds);
    boolean existsByIdAndIdCondominioIn(String id, List<String> condominioIds);
    List<Condomino> findByCondominoRootIdIn(List<String> condominoRootIds);
    List<Condomino> findByIdCondominioInAndUnitaImmobiliareId(List<String> idCondominio, String unitaImmobiliareId);
    List<Condomino> findByKeycloakUserId(String keycloakUserId);
    boolean existsByCondominoRootId(String condominoRootId);
    boolean existsByIdCondominioAndCondominoRootId(String idCondominio, String condominoRootId);
    boolean existsByIdCondominioAndCondominoRootIdIn(String idCondominio, List<String> condominoRootIds);
    boolean existsByIdCondominioAndKeycloakUserId(String idCondominio, String keycloakUserId);

    /** Update puntuale residuo di un condomino specifico nel condominio atteso. */
    @Query("{ '_id': ?0, 'idCondominio': ?1 }")
    @Update("{ '$set': { 'residuo': ?2 } }")
    long setResiduoByIdAndCondominio(String id, String idCondominio, double residuo);

    /** Delta contabile su residuo condomino (incrementale). */
    @Query("{ '_id': ?0, 'idCondominio': ?1 }")
    @Update("{ '$inc': { 'residuo': ?2 } }")
    long incResiduoByIdAndCondominio(String id, String idCondominio, double delta);

    /** Add atomica di un versamento sul condomino target. */
    @Query("{ '_id': ?0, 'idCondominio': ?1 }")
    @Update("{ '$push': { 'versamenti': ?2 } }")
    long addVersamentoByIdAndCondominio(String id, String idCondominio, Condomino.Versamento versamento);

    /** Delete atomica del versamento selezionato per id. */
    @Query("{ '_id': ?0, 'idCondominio': ?1 }")
    @Update("{ '$pull': { 'versamenti': { 'id': ?2 } } }")
    long removeVersamentoByIdAndCondominio(String id, String idCondominio, String versamentoId);
}

interface CondominoRepositoryCustom {
    // metodi custom eventuali
}
