package it.atlantica.validationhandler.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.*;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Constraint(validatedBy = LengthConstraintValidator.class)
@Documented
@Retention(RUNTIME)
@Target({ METHOD, FIELD, ANNOTATION_TYPE, CONSTRUCTOR, PARAMETER, TYPE_USE })
public @interface Length {

    int min() default 0;

    int max() default 0;

    String minProperty() default "";

    String maxProperty() default "";

    String message() default "Invalid length";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
