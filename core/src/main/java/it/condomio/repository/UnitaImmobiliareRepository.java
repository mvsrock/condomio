package it.condomio.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.UnitaImmobiliare;

@Repository
public interface UnitaImmobiliareRepository extends MongoRepository<UnitaImmobiliare, String> {
    List<UnitaImmobiliare> findByCondominioRootIdOrderByScalaAscInternoAsc(String condominioRootId);
    Optional<UnitaImmobiliare> findByIdAndCondominioRootId(String id, String condominioRootId);
    boolean existsByCondominioRootIdAndScalaAndInterno(String condominioRootId, String scala, String interno);
    boolean existsByCondominioRootIdAndScalaAndInternoAndIdNot(
            String condominioRootId,
            String scala,
            String interno,
            String id);
    Optional<UnitaImmobiliare> findByCondominioRootIdAndScalaAndInterno(
            String condominioRootId,
            String scala,
            String interno);
}
