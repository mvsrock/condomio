package it.condomio.exception;

import org.springframework.http.HttpStatus;

public class ForbiddenException extends ApiException {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public ForbiddenException() {
        super();
        withHttpStatus(HttpStatus.FORBIDDEN)
                .withErrorCodes("service.forbidden");
    }
}