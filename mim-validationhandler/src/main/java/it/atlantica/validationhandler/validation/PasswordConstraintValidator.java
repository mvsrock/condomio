package it.atlantica.validationhandler.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import org.apache.commons.lang3.CharSet;

import static java.lang.Character.*;

public class PasswordConstraintValidator implements ConstraintValidator<Password, String> {

    private static final int MIN_LENGTH = 8;
    private static final int MIN_LOWER_CASE_CHARS = 1;
    private static final int MIN_UPPER_CASE_CHARS = 1;
    private static final int MIN_DIGIT_CHARS = 1;
    private static final int MIN_SPECIAL_CHARS = 1;

    private static final CharSet SPECIAL_CHARS = CharSet.getInstance("-", "^", "+=$*.[]{}()?\"!@#%&/\\,><':;|_~`");

    @Override
    public boolean isValid(final String value, final ConstraintValidatorContext context) {
        if (value == null) {
            return true;
        }

        if (value.length() < MIN_LENGTH) {
            return false;
        }

        int lowerCaseChars = 0;
        int upperCaseChars = 0;
        int digitChars = 0;
        int specialChars = 0;

        for (char c : value.toCharArray()) {
            if (isLowerCase(c)) {
                lowerCaseChars++;
            } else if (isUpperCase(c)) {
                upperCaseChars++;
            } else if (isDigit(c)) {
                digitChars++;
            } else if (SPECIAL_CHARS.contains(c)) {
                specialChars++;
            } else {
                return false;
            }
        }

        return lowerCaseChars >= MIN_LOWER_CASE_CHARS && upperCaseChars >= MIN_UPPER_CASE_CHARS
                && digitChars >= MIN_DIGIT_CHARS && specialChars >= MIN_SPECIAL_CHARS;
    }

}
