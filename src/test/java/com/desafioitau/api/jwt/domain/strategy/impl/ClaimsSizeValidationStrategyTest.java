package com.desafioitau.api.jwt.domain.strategy.impl;

import org.junit.jupiter.api.Test;
import java.util.HashMap;
import java.util.Map;
import static org.junit.jupiter.api.Assertions.*;

class ClaimsSizeValidationStrategyTest {

    private final ClaimsSizeValidationStrategy strategy = new ClaimsSizeValidationStrategy();

    @Test
    void deveRetornarTrueQuandoClaimsTemTamanhoExato() {
        // Arrange
        Map<String, Object> claims = new HashMap<>();
        claims.put("claim1", "valor1");
        claims.put("claim2", "valor2");
        claims.put("claim3", "valor3");

        // Act
        boolean resultado = strategy.validate(claims);

        // Assert
        assertTrue(resultado);
    }

    @Test
    void deveRetornarFalseQuandoClaimsTemTamanhoMenor() {
        // Arrange
        Map<String, Object> claims = new HashMap<>();
        claims.put("claim1", "valor1");
        claims.put("claim2", "valor2");

        // Act
        boolean resultado = strategy.validate(claims);

        // Assert
        assertFalse(resultado);
    }

    @Test
    void deveRetornarFalseQuandoClaimsTemTamanhoMaior() {
        // Arrange
        Map<String, Object> claims = new HashMap<>();
        claims.put("claim1", "valor1");
        claims.put("claim2", "valor2");
        claims.put("claim3", "valor3");
        claims.put("claim4", "valor4");

        // Act
        boolean resultado = strategy.validate(claims);

        // Assert
        assertFalse(resultado);
    }


} 