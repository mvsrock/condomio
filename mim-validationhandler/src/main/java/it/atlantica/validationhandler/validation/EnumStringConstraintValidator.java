package it.atlantica.validationhandler.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import org.springframework.util.Assert;

public class EnumStringConstraintValidator implements ConstraintValidator<EnumString, String> {

    private String[] values;

    @Override
    public void initialize(final EnumString constraintAnnotation) {
        values = constraintAnnotation.value();
        Assert.notNull(values, "@Enum values are null");
    }

    @Override
    public boolean isValid(final String value, final ConstraintValidatorContext context) {
        if (value == null) {
            return true;
        }

        for (String s : values) {
            if (value.equals(s)) {
                return true;
            }
        }

        return false;
    }
}
