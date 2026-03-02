package it.condomio.exception;

import org.springframework.http.HttpStatus;

public class NotFoundException  extends ApiException{
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public NotFoundException(final String resourceCode) {
        withHttpStatus(HttpStatus.NOT_FOUND).withErrorCodes("service.notFound." + resourceCode);
    }

    public NotFoundException(final Class<?> resourceType) {
        this(resourceType.getSimpleName());
    }
}
