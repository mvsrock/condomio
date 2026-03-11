package it.condomio.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import it.condomio.document.DocumentoArchivio;

@Repository
public interface DocumentoArchivioRepository extends MongoRepository<DocumentoArchivio, String> {
    List<DocumentoArchivio> findByIdCondominioOrderByCreatedAtDesc(String idCondominio);

    List<DocumentoArchivio> findByIdCondominioAndMovimentoIdOrderByCreatedAtDesc(
            String idCondominio,
            String movimentoId);

    Optional<DocumentoArchivio> findFirstByDocumentGroupIdOrderByVersionNumberDesc(String documentGroupId);
}
