package it.condomio.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.Condominio;

@Repository
public interface CondominioRepository extends MongoRepository<Condominio, String>, CondominioRepositoryCustom {
}

interface CondominioRepositoryCustom {
    // qui puoi dichiarare i tuoi metodi custom
}

