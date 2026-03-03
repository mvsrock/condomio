package it.condomio.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.Movimenti;

@Repository
public interface MovimentiRepository extends MongoRepository<Movimenti, String>, MovimentiRepositoryCustom {
}

interface MovimentiRepositoryCustom {
    // qui puoi dichiarare i tuoi metodi custom
}

