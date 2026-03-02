package it.condomio.exception;

import static java.util.stream.Stream.concat;

import java.util.stream.Stream;

import org.springframework.http.HttpStatus;
import org.springframework.validation.Errors;

public class ValidationFailedException  extends ApiException {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public ValidationFailedException(final String baseResource, final Errors errors) {
        withHttpStatus(HttpStatus.BAD_REQUEST).withErrorCodes(extractErrors(baseResource, errors));
    }

    public ValidationFailedException(final String... errorCodes) {
        withHttpStatus(HttpStatus.BAD_REQUEST).withErrorCodes(errorCodes);
    }

    private String[] extractErrors(final String baseResource, final Errors errors) {
        return concat(globalErrors(baseResource, errors), fieldErrors(baseResource, errors))
                .toArray(String[]::new);
    }

    private Stream<String> globalErrors(final String baseResource, final Errors errors) {
        return errors.getGlobalErrors().stream().map(ge -> "validation." + ge.getCode() + "." + baseResource);
    }

    private Stream<String> fieldErrors(final String baseResource, final Errors errors) {
        return errors.getFieldErrors().stream()
                .map(fe -> "validation." + fe.getCode() + "." + baseResource + "." + trashListIndices(fe.getField()));
    }

    private static String trashListIndices(final String fieldPath) {
        return fieldPath.replaceAll("\\[\\d+\\]", "");
    }

}
