package it.condomio.util;


import static java.lang.String.join;
import static java.util.Arrays.stream;
import static java.util.stream.Collectors.joining;
import static org.apache.commons.lang3.ArrayUtils.insert;
import static org.apache.commons.lang3.StringUtils.splitByCharacterTypeCamelCase;
import static org.apache.commons.text.CaseUtils.toCamelCase;

import java.util.Collection;

import org.springframework.validation.Errors;

import it.condomio.exception.ValidationFailedException;
import it.condomio.payload.ErrorPayload;

public class ErrorCodes {

    private ErrorCodes() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static String fromException(final Throwable e, final String... path) {
        final String exceptionCode = e.getClass().getSimpleName().replaceFirst("Exception$", "");
        return normalize(join(".", insert(0, path, exceptionCode)));
    }

    public static Collection<String> normalize(final Collection<String> errorCodes) {
        return errorCodes.stream().map(ErrorCodes::normalize).toList();
    }

    public static String normalize(final String string) {
        return stream(string.split("\\.")).map(ErrorCodes::toLowerCamelCase).collect(joining("."));
    }

    private static String toLowerCamelCase(final String string) {
        return toCamelCase(join("|", splitByCharacterTypeCamelCase(string)), false, '|');
    }

    public static ErrorPayload validation(final Throwable e, final String... resource) {
        return new ErrorPayload("validation." + ErrorCodes.fromException(e, resource));
    }

    public static ErrorPayload validation(final String resource, final Errors errors) {
        return new ValidationFailedException(resource, errors).getPayload();
    }
}
