package com.desafioitau.api.jwt.domain.strategy.impl;

import com.desafioitau.api.jwt.domain.strategy.JwtValidationStrategy;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;

@Component
public class NameValidationStrategy implements JwtValidationStrategy {
    private static final int MAX_NAME_LENGTH = 256;

    @Override
    public boolean validate(Map<String, Object> claims) {
        return Optional.ofNullable(claims.get("Name"))
                .map(Object::toString)
                .filter(name -> !name.isEmpty())
                .filter(name -> name.length() <= MAX_NAME_LENGTH)
                .filter(name -> !name.matches(".*\\d.*"))
                .isPresent();
    }
    
} 