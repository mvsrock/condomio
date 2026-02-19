package it.atlantica.payload;

import lombok.ToString;
import lombok.Value;

import java.time.Instant;
import java.util.List;

import static java.util.Arrays.asList;
import static java.util.Collections.unmodifiableList;

@Value
public class ErrorPayload {
    @ToString.Exclude
    Instant timestamp = Instant.now();

    List<String> errorCodes;

    public ErrorPayload(final List<String> errorCodes) {
        this.errorCodes = unmodifiableList(errorCodes);
    }

    public ErrorPayload(final String... errorCodes) {
        this(asList(errorCodes));
    }
}