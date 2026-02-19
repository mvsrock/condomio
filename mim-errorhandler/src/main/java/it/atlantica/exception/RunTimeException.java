package it.atlantica.exception;

import org.springframework.http.HttpStatus;

public class RunTimeException extends ApiException{
    public RunTimeException(final String resourceCode) {
        withHttpStatus(HttpStatus.INTERNAL_SERVER_ERROR).withErrorCodes("runtime.exception." + resourceCode);
    }

    public RunTimeException(final Class<?> resourceType) {
        this(resourceType.getSimpleName());
    }
}
