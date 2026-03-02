package it.condomio.exception;

import org.springframework.http.HttpStatus;

public class UploadFailedException extends ApiException {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public UploadFailedException() {
        withHttpStatus(HttpStatus.NOT_ACCEPTABLE).withErrorCodes("failUpload");
    }
}
