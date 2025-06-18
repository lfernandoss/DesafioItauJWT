package com.desafioitau.api.jwt.rest.validator;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;

public class JwtValidator implements ConstraintValidator<JwtValid, String> {

    @Override
    public boolean isValid(String jwt, ConstraintValidatorContext context) {
        if (jwt == null || jwt.isEmpty()) {
            return false;
        }
     
        String[] partes = jwt.split("\\.");
        return partes.length == 3; 
    }

}
