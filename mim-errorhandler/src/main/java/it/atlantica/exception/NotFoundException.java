package it.atlantica.exception;

import org.springframework.http.HttpStatus;

public class NotFoundException  extends ApiException{
    public NotFoundException(final String resourceCode) {
        withHttpStatus(HttpStatus.NOT_FOUND).withErrorCodes("service.notFound." + resourceCode);
    }

    public NotFoundException(final Class<?> resourceType) {
        this(resourceType.getSimpleName());
    }
}
