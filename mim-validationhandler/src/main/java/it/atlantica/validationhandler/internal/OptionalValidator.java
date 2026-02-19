package it.atlantica.validationhandler.internal;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.*;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Component
@Qualifier
@Documented
@Retention(RUNTIME)
@Target({ TYPE, FIELD, METHOD })
public @interface OptionalValidator {

}
