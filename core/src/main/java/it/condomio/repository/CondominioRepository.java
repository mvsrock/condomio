package it.condomio.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.Condominio;
import java.util.List;
import java.util.Optional;

@Repository
public interface CondominioRepository extends MongoRepository<Condominio, String>, CondominioRepositoryCustom {
    List<Condominio> findByAdminKeycloakUserId(String adminKeycloakUserId);
    Optional<Condominio> findByIdAndAdminKeycloakUserId(String id, String adminKeycloakUserId);
    boolean existsByIdAndAdminKeycloakUserId(String id, String adminKeycloakUserId);
}

interface CondominioRepositoryCustom {
    // qui puoi dichiarare i tuoi metodi custom
}

