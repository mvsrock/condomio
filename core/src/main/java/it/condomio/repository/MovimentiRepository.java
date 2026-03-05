package it.condomio.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.Movimenti;

@Repository
public interface MovimentiRepository extends MongoRepository<Movimenti, String>, MovimentiRepositoryCustom {
    List<Movimenti> findByIdCondominio(String idCondominio);
    List<Movimenti> findByIdCondominioIn(List<String> condominioIds);
    Optional<Movimenti> findByIdAndIdCondominioIn(String id, List<String> condominioIds);
    boolean existsByIdAndIdCondominioIn(String id, List<String> condominioIds);
}

interface MovimentiRepositoryCustom {
    // qui puoi dichiarare i tuoi metodi custom
}

