package com.desafioitau.api.jwt.rest.validator;

import javax.validation.Constraint;
import javax.validation.Payload;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = JwtValidator.class)
public @interface JwtValid {
    String message() default "JWT inválido";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

