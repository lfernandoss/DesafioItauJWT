package com.desafioitau.api.jwt.domain.strategy;

import io.jsonwebtoken.Claims;

import java.util.Map;

public interface JwtValidationStrategy {
    boolean validate(Map<String, Object> claims);
} 