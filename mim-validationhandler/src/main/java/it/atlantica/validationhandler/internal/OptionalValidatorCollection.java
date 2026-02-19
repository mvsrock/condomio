package it.atlantica.validationhandler.internal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.validation.Errors;
import org.springframework.validation.Validator;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import static java.util.stream.Collectors.toList;

@Component
public class OptionalValidatorCollection implements Validator {

    private static final Map<Class<?>, List<Validator>> VALIDATORS = new ConcurrentHashMap<>();

    @Autowired
    @OptionalValidator
    private List<Validator> validators;

    void registerValidator(final Validator validator) {
        validators.add(validator);
    }

    @Override
    public boolean supports(final Class<?> clazz) {
        VALIDATORS.computeIfAbsent(clazz, c -> validators.stream().filter(v -> v.supports(c)).collect(toList()));
        return true;
    }

    @Override
    public void validate(final Object target, final Errors errors) {
        VALIDATORS.get(target.getClass()).forEach(v -> v.validate(target, errors));
    }

}
