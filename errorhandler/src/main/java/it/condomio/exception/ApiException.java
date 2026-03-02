package it.condomio.exception;


import static java.util.Arrays.asList;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.util.Assert;

import it.condomio.payload.ErrorPayload;
import it.condomio.util.ErrorCodes;
import lombok.Getter;

@Getter
public class ApiException extends Exception {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private HttpStatus httpStatus = HttpStatus.BAD_REQUEST;

    private final List<String> errorCodes = new ArrayList<>();

    public ApiException() {
    }

    public ErrorPayload getPayload() {
        return new ErrorPayload(errorCodes);
    }

    public ApiException withHttpStatus(final HttpStatus httpStatus) {
        Assert.notNull(httpStatus, "null httpStatus in exception");
        this.httpStatus = httpStatus;
        return this;
    }

    public ApiException withErrorCodes(final String... errorCodes) {
        return withErrorCodes(asList(errorCodes));
    }

    public ApiException withErrorCodes(final Collection<String> errorCodes) {
        Assert.notEmpty(errorCodes, "empty errorCodes in exception");
        this.errorCodes.addAll(ErrorCodes.normalize(errorCodes));
        return this;
    }

}