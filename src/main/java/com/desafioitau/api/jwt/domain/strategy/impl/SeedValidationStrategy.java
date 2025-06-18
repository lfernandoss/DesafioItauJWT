package com.desafioitau.api.jwt.domain.strategy.impl;

import com.desafioitau.api.jwt.domain.strategy.JwtValidationStrategy;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;

@Component
public class SeedValidationStrategy implements JwtValidationStrategy {

    @Override
    public boolean validate(Map<String, Object> claims) {
        return Optional.ofNullable(claims.get("Seed"))
                .map(Object::toString)
                .map(seed -> isPrime(Integer.parseInt(seed)))
                .orElse(false);
    }

    private boolean isPrime(int number) {
        if (number <= 1) {
            return false;
        }
        if (number <= 3) {
            return true;
        }
        if (number % 2 == 0 || number % 3 == 0) {
            return false;
        }
        for (int i = 5; i * i <= number; i += 6) {
            if (number % i == 0 || number % (i + 2) == 0) {
                return false;
            }
        }
        return true;
    }
} 