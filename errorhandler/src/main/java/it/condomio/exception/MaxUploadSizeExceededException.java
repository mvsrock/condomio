package it.condomio.exception;

import org.springframework.http.HttpStatus;

public class MaxUploadSizeExceededException extends ApiException {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public MaxUploadSizeExceededException() {
        withHttpStatus(HttpStatus.BAD_REQUEST).withErrorCodes("service.maxUploadSizeExceededException");
    }
}
