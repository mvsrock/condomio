package it.condomio.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.Preventivo;

@Repository
public interface PreventivoRepository extends MongoRepository<Preventivo, String> {
}

