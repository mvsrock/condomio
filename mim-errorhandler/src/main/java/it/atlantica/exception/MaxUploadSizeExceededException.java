package it.atlantica.exception;

import org.springframework.http.HttpStatus;

public class MaxUploadSizeExceededException extends ApiException {
    public MaxUploadSizeExceededException() {
        withHttpStatus(HttpStatus.BAD_REQUEST).withErrorCodes("service.maxUploadSizeExceededException");
    }
}
