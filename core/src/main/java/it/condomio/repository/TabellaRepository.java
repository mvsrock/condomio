package it.condomio.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.Tabella;

@Repository
public interface TabellaRepository extends MongoRepository<Tabella, String>, TabellaRepositoryCustom {
    List<Tabella> findByIdCondominio(String idCondominio);
    List<Tabella> findByIdCondominioOrderByCodiceAsc(String idCondominio);
    List<Tabella> findByIdCondominioIn(List<String> condominioIds);
    boolean existsByIdCondominio(String idCondominio);
    Optional<Tabella> findByIdAndIdCondominioIn(String id, List<String> condominioIds);
    boolean existsByIdAndIdCondominioIn(String id, List<String> condominioIds);
    boolean existsByIdCondominioAndCodiceIgnoreCase(String idCondominio, String codice);
    boolean existsByIdCondominioAndCodiceIgnoreCaseAndIdNot(String idCondominio, String codice, String id);
}

interface TabellaRepositoryCustom {
    // qui puoi dichiarare i tuoi metodi custom
}
