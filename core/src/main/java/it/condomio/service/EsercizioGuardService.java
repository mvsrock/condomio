package it.condomio.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.condomio.document.Condominio;
import it.condomio.exception.ApiException;
import it.condomio.exception.ForbiddenException;
import it.condomio.exception.NotFoundException;
import it.condomio.exception.ValidationFailedException;
import it.condomio.repository.CondominioRepository;

/**
 * Guard centralizzato per ownership e stato dell'esercizio.
 *
 * Tutte le scritture devono passare da qui per evitare comportamenti incoerenti
 * quando un esercizio e' chiuso.
 */
@Service
public class EsercizioGuardService {

    @Autowired
    private CondominioRepository condominioRepository;

    @Autowired
    private TenantAccessService tenantAccessService;

    public Condominio requireOwnedExercise(String esercizioId, String keycloakUserId) throws ApiException {
        Condominio esercizio = condominioRepository.findById(esercizioId)
                .orElseThrow(() -> new NotFoundException("condominio"));
        if (!tenantAccessService.ownsCondominio(keycloakUserId, esercizioId)) {
            throw new ForbiddenException();
        }
        return esercizio;
    }

    public Condominio requireOwnedOpenExercise(String esercizioId, String keycloakUserId) throws ApiException {
        Condominio esercizio = requireOwnedExercise(esercizioId, keycloakUserId);
        ensureOpen(esercizio);
        return esercizio;
    }

    public void ensureOpen(Condominio esercizio) throws ValidationFailedException {
        if (esercizio == null) {
            return;
        }
        if (esercizio.getStato() == Condominio.EsercizioStato.CLOSED) {
            throw new ValidationFailedException("validation.esercizio.closed");
        }
    }
}
