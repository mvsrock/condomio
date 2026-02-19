package it.atlantica.validationhandler.validation;

import it.atlantica.validationhandler.internal.OptionalValidator;
import org.springframework.validation.Errors;
import org.springframework.validation.Validator;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;

@OptionalValidator
public class MatchValidator implements Validator {

    private record FieldMatcher(Field field, Field matchField, boolean negate) {

            void validate(final Object target, final Errors errors) {
                try {
                    final Object value = field.get(target);
                    final Object matchValue = matchField.get(target);

                    if (negate == Objects.equals(value, matchValue)) {
                        errors.rejectValue(field.getName(), "match");
                    }

                } catch (IllegalAccessException e) {
                    throw new UnsupportedOperationException("Can not happen");
                }
            }
        }

    private static final Map<Class<?>, List<FieldMatcher>> MATCHERS = new ConcurrentHashMap<>();

    @Override
    public boolean supports(final Class<?> clazz) {
        if (MATCHERS.containsKey(clazz)) {
            return true;
        }

        final List<FieldMatcher> matchers = new ArrayList<>();

        for (Field field : clazz.getDeclaredFields()) {
            final Match match = field.getAnnotation(Match.class);
            if (match != null) {
                try {
                    final Field matchField = clazz.getDeclaredField(match.value());
                    if (matchField.equals(field)) {
                        throw new IllegalArgumentException("@Match exception targets same field");
                    }

                    field.setAccessible(true);
                    matchField.setAccessible(true);

                    final FieldMatcher matcher = new FieldMatcher(field, matchField, match.negate());
                    matchers.add(matcher);

                } catch (NoSuchFieldException e) {
                    throw new IllegalArgumentException("@Match exception targets not existing field");
                }
            }
        }

        if (matchers.isEmpty()) {
            return false;
        }

        MATCHERS.put(clazz, matchers);

        return true;
    }

    @Override
    public void validate(final Object target, final Errors errors) {
        final List<FieldMatcher> matchers = MATCHERS.get(target.getClass());
        if (matchers == null) {
            throw new IllegalStateException("target support not checked");
        }

        for (FieldMatcher matcher : matchers) {
            matcher.validate(target, errors);
        }
    }
}
