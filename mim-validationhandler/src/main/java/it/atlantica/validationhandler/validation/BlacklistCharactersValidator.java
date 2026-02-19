package it.atlantica.validationhandler.validation;


import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class BlacklistCharactersValidator implements ConstraintValidator<BlacklistCharacters, String> {

    private String[] blacklist;

    @Override
    public void initialize(BlacklistCharacters annotation) {
        this.blacklist = annotation.value();
    }

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null) {
            return true;
        }
        for (String forbiddenChar : blacklist) {
            if (value.contains(forbiddenChar)) {
                return false;
            }
        }
        return true;
    }
}

