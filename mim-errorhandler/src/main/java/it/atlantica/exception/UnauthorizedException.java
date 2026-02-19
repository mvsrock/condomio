package it.atlantica.exception;

import org.springframework.http.HttpStatus;

public class UnauthorizedException extends ApiException {

    public UnauthorizedException() {
        super();
        withHttpStatus(HttpStatus.UNAUTHORIZED)
                .withErrorCodes("authentication.unauthorized");
    }
}