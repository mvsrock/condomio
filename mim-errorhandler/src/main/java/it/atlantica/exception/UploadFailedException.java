package it.atlantica.exception;

import org.springframework.http.HttpStatus;

public class UploadFailedException extends ApiException {
    public UploadFailedException() {
        withHttpStatus(HttpStatus.NOT_ACCEPTABLE).withErrorCodes("failUpload");
    }
}
