package com.desafioitau.api.jwt.domain.strategy.impl;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class NameValidationStrategyTest {

    private NameValidationStrategy strategy;
    private Map<String, Object> claims;

    @BeforeEach
    void setUp() {
        strategy = new NameValidationStrategy();
        claims = new HashMap<>();
    }

    @Test
    @DisplayName("Deve retornar true para um nome válido")
    void shouldReturnTrueForValidName() {
        claims.put("Name", "João Silva");
        assertTrue(strategy.validate(claims));
    }

    @Test
    @DisplayName("Deve retornar false quando o nome não está presente no mapa")
    void shouldReturnFalseWhenNameIsNotPresent() {
        assertFalse(strategy.validate(claims));
    }

    @Test
    @DisplayName("Deve retornar false para nome nulo")
    void shouldReturnFalseForNullName() {
        claims.put("Name", null);
        assertFalse(strategy.validate(claims));
    }

    @Test
    @DisplayName("Deve retornar false para nome vazio")
    void shouldReturnFalseForEmptyName() {
        claims.put("Name", "");
        assertFalse(strategy.validate(claims));
    }

    @Test
    @DisplayName("Deve retornar false para nome com mais de 256 caracteres")
    void shouldReturnFalseForNameExceedingMaxLength() {
        String longName = "a".repeat(257);
        claims.put("Name", longName);
        assertFalse(strategy.validate(claims));
    }

    @ParameterizedTest
    @ValueSource(strings = {"João123", "123João", "João1Silva", "1"})
    @DisplayName("Deve retornar false para nomes contendo números")
    void shouldReturnFalseForNamesContainingNumbers(String invalidName) {
        claims.put("Name", invalidName);
        assertFalse(strategy.validate(claims));
    }

    @ParameterizedTest
    @ValueSource(strings = {"João Silva", "Maria", "José da Silva", "Ana Paula"})
    @DisplayName("Deve retornar true para nomes válidos")
    void shouldReturnTrueForValidNames(String validName) {
        claims.put("Name", validName);
        assertTrue(strategy.validate(claims));
    }

} 