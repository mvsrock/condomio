package it.condomio.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.Tabella;

@Repository
public interface TabellaRepository extends MongoRepository<Tabella, String>, TabellaRepositoryCustom {
}

interface TabellaRepositoryCustom {
    // qui puoi dichiarare i tuoi metodi custom
}
