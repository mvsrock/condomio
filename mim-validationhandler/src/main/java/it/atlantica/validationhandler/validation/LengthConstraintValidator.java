package it.atlantica.validationhandler.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;

public class LengthConstraintValidator implements ConstraintValidator<Length, String> {

    @Autowired
    private Environment env;

    private int min;
    private int max;

    @Override
    public void initialize(final Length constraintAnnotation) {
        final String minProperty = constraintAnnotation.minProperty().trim();
        if (!minProperty.isEmpty()) {
            final String minString = env.getProperty(minProperty);
            min = Integer.parseInt(minString);
        } else {
            min = constraintAnnotation.min();
        }

        final String maxProperty = constraintAnnotation.maxProperty().trim();
        if (!maxProperty.isEmpty()) {
            final String maxString = env.getProperty(maxProperty);
            max = Integer.parseInt(maxString);
        } else {
            max = constraintAnnotation.max();
        }
        if (max == 0) {
            max = Integer.MAX_VALUE;
        }
    }

    @Override
    public boolean isValid(final String value, final ConstraintValidatorContext context) {
        if (value == null) {
            return true;
        }

        final int length = value.length();
        return length >= min && length <= max;
    }
}
