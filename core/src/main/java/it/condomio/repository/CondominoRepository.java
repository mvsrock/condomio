package it.condomio.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.Condomino;

@Repository
public interface CondominoRepository extends MongoRepository<Condomino, String>, CondominoRepositoryCustom {
}

interface CondominoRepositoryCustom {
    // qui puoi dichiarare i tuoi metodi custom
}
