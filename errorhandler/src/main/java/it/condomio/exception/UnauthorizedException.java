package it.condomio.exception;

import org.springframework.http.HttpStatus;

public class UnauthorizedException extends ApiException {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public UnauthorizedException() {
        super();
        withHttpStatus(HttpStatus.UNAUTHORIZED)
                .withErrorCodes("authentication.unauthorized");
    }
}