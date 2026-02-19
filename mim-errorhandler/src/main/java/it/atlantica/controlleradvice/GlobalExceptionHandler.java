package it.atlantica.controlleradvice;


import it.atlantica.exception.ApiException;
import it.atlantica.exception.MaxUploadSizeExceededException;
import it.atlantica.payload.ErrorPayload;
import lombok.extern.log4j.Log4j2;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.lang.reflect.UndeclaredThrowableException;


@Log4j2
@ControllerAdvice
@Order(Ordered.HIGHEST_PRECEDENCE)
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorPayload> handleAccessDenied(AccessDeniedException e) {
        log.error("Access denied: {}", e.getStackTrace()[0]);
        log.debug("Full exception", e);

        return new ResponseEntity<>(new ErrorPayload("service.forbidden"), HttpStatus.FORBIDDEN);
    }

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ErrorPayload> handleApiException(ApiException e) {
        log.error("Application error: {}", e.getStackTrace()[0]);
        log.debug("Full exception", e);
        return new ResponseEntity<>(e.getPayload(), e.getHttpStatus());
    }


    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorPayload> handleInternalError(final Exception e) {
        log.error("Unexpected error", e);
        return new ResponseEntity<>(new ErrorPayload("server.internal"), HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<ErrorPayload> handleApplicationMaxLimitUpload(final MaxUploadSizeExceededException e) {
        log.error("Application MaxLimitUpload error: {}", e.getStackTrace()[0]);
        log.debug("Full exception MaxLimitUpload", e);

        if (e instanceof MaxUploadSizeExceededException) {
            log.debug("MaxUploadSizeExceededException", e);
            return new ResponseEntity<>(new ErrorPayload("service.MaxUploadSizeExceededException"),
                    HttpStatus.BAD_REQUEST);
        }
        return new ResponseEntity<>(new ErrorPayload("service.internal"), HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @ExceptionHandler(UndeclaredThrowableException.class)
    public ResponseEntity<ErrorPayload> handleExceptionInAspect(final UndeclaredThrowableException e) {
        log.warn("Rethrowing aspect error");

        final Exception cause = (Exception) e.getCause();

        if (cause instanceof ApiException causes) {
            return handleApiException(causes);
        }
        return handleInternalError(cause);
    }
}