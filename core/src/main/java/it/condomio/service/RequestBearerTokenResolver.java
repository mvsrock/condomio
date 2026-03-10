package it.condomio.service;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;

/**
 * Risoluzione centralizzata del bearer corrente da SecurityContext.
 *
 * Evita duplicazioni nei vari bridge/proxy service-to-service.
 */
@Component
public class RequestBearerTokenResolver {

    public String resolveBearerToken() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication instanceof JwtAuthenticationToken jwtAuthenticationToken) {
            return "Bearer " + jwtAuthenticationToken.getToken().getTokenValue();
        }
        throw new SecurityException("Missing authenticated bearer token");
    }
}
