package com.desafioitau.api.jwt.domain.strategy.impl;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class SeedValidationStrategyTest {

    private SeedValidationStrategy strategy;

    @BeforeEach
    void setUp() {
        strategy = new SeedValidationStrategy();
    }

    @Test
    void validate_QuandoSeedNulo_DeveRetornarFalse() {
        Map<String, Object> claims = new HashMap<>();
        claims.put("Seed", null);

        boolean result = strategy.validate(claims);

        assertFalse(result);
    }

    @Test
    void validate_QuandoSeedNaoExiste_DeveRetornarFalse() {
        Map<String, Object> claims = new HashMap<>();

        boolean result = strategy.validate(claims);

        assertFalse(result);
    }

    @ParameterizedTest
    @ValueSource(ints = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29})
    void validate_QuandoSeedPrimo_DeveRetornarTrue(int primo) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("Seed", primo);

        boolean result = strategy.validate(claims);

        assertTrue(result);
    }

    @ParameterizedTest
    @ValueSource(ints = {4, 6, 8, 9, 10, 12, 14, 15, 16, 18})
    void validate_QuandoSeedNaoPrimo_DeveRetornarFalse(int naoPrimo) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("Seed", naoPrimo);

        boolean result = strategy.validate(claims);

        assertFalse(result);
    }

    @Test
    void validate_QuandoSeedMenorOuIgualA1_DeveRetornarFalse() {
        Map<String, Object> claims = new HashMap<>();
        claims.put("Seed", 1);

        boolean result = strategy.validate(claims);

        assertFalse(result);
    }

} 