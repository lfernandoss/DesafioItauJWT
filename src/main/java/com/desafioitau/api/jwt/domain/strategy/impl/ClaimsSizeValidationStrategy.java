package com.desafioitau.api.jwt.domain.strategy.impl;

import com.desafioitau.api.jwt.domain.strategy.JwtValidationStrategy;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class ClaimsSizeValidationStrategy implements JwtValidationStrategy {
    private static final int CLAIMS_SIZE = 3;

    @Override
    public boolean validate(Map<String, Object> claims) {
        return claims.size() == CLAIMS_SIZE;
    }
    
} 