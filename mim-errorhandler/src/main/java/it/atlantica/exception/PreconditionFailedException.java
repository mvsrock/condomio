package it.atlantica.exception;

import org.springframework.http.HttpStatus;
import org.springframework.util.Assert;

public class PreconditionFailedException  extends ApiException {

    public PreconditionFailedException(String precondition, String resource) {
        Assert.doesNotContain(precondition, ".", "Precondition with dot");
        withErrorCodes("precondition." + precondition + "." + resource).withHttpStatus(httpStatus());

    }

    protected HttpStatus httpStatus() {
        return HttpStatus.UNPROCESSABLE_ENTITY;
    }
}
