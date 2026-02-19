package it.atlantica.exception;

import org.springframework.http.HttpStatus;

public class ForbiddenException extends ApiException {

    public ForbiddenException() {
        super();
        withHttpStatus(HttpStatus.FORBIDDEN)
                .withErrorCodes("service.forbidden");
    }
}