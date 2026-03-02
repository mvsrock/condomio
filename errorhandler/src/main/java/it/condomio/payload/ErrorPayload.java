package it.condomio.payload;

import static java.util.Arrays.asList;
import static java.util.Collections.unmodifiableList;

import java.time.Instant;
import java.util.List;

import lombok.ToString;
import lombok.Value;

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