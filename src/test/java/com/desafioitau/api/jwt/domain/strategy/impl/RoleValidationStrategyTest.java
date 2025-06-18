package com.desafioitau.api.jwt.domain.strategy.impl;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class RoleValidationStrategyTest {

    private RoleValidationStrategy roleValidationStrategy;
    private Map<String, Object> claims;

    @BeforeEach
    void setUp() {
        roleValidationStrategy = new RoleValidationStrategy();
        claims = new HashMap<>();
    }

    @Test
    @DisplayName("Deve retornar true quando a role é Admin")
    void shouldReturnTrueWhenRoleIsAdmin() {
        claims.put("Role", "Admin");
        assertTrue(roleValidationStrategy.validate(claims));
    }

    @Test
    @DisplayName("Deve retornar true quando a role é Member")
    void shouldReturnTrueWhenRoleIsMember() {
        claims.put("Role", "Member");
        assertTrue(roleValidationStrategy.validate(claims));
    }

    @Test
    @DisplayName("Deve retornar true quando a role é External")
    void shouldReturnTrueWhenRoleIsExternal() {
        claims.put("Role", "External");
        assertTrue(roleValidationStrategy.validate(claims));
    }

    @Test
    @DisplayName("Deve retornar false quando a role é inválida")
    void shouldReturnFalseWhenRoleIsInvalid() {
        claims.put("Role", "InvalidRole");
        assertFalse(roleValidationStrategy.validate(claims));
    }

    @Test
    @DisplayName("Deve retornar false quando a role é nula")
    void shouldReturnFalseWhenRoleIsNull() {
        claims.put("Role", null);
        assertFalse(roleValidationStrategy.validate(claims));
    }

} 