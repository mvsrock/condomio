package it.atlantica.validationhandler.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.lang.Enum;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

public class EnumConstraintValidator implements ConstraintValidator<it.atlantica.validationhandler.validation.Enum, String> {

    private Set<String> allowedValues;

    @Override
    public void initialize(it.atlantica.validationhandler.validation.Enum constraintAnnotation) {
        Class<? extends Enum<?>> enumSelected = constraintAnnotation.enumClass();
        Enum<?>[] enumConstants = enumSelected.getEnumConstants();
        allowedValues = Arrays.stream(enumConstants)
                .map(Enum::name)
                .collect(Collectors.toSet());
    }

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null) {
            return true;
        }
        if (!allowedValues.contains(value)) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("must be any of " + allowedValues).addConstraintViolation();
            return false;
        }
        return true;
    }
}
