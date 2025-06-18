package com.desafioitau.api.jwt.domain.service;

import com.desafioitau.api.jwt.domain.strategy.JwtValidationStrategy;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class JwtServicePortImplTest {

    private JwtServicePortImpl jwtService;

    @Mock
    private JwtValidationStrategy strategy1;

    @Mock
    private JwtValidationStrategy strategy2;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        List<JwtValidationStrategy> strategies = Arrays.asList(strategy1, strategy2);
        jwtService = new JwtServicePortImpl(strategies);
    }

    @Test
    void validarJwt_QuandoTokenValido_DeveRetornarTrue() {
        // Arrange
        String tokenValido = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";
        when(strategy1.validate(any())).thenReturn(true);
        when(strategy2.validate(any())).thenReturn(true);

        // Act
        boolean resultado = jwtService.validarJwt(tokenValido);

        // Assert
        assertTrue(resultado);
        verify(strategy1, timeout(1000)).validate(any());
        verify(strategy2, timeout(1000)).validate(any());
    }

    @Test
    void validarJwt_QuandoTokenInvalido_DeveRetornarFalse() {
        // Arrange
        String tokenInvalido = "token.invalido";
        
        // Act
        boolean resultado = jwtService.validarJwt(tokenInvalido);

        // Assert
        assertFalse(resultado);
        verify(strategy1, never()).validate(any());
        verify(strategy2, never()).validate(any());
    }

    @Test
    void validarJwt_QuandoEstrategiaFalha_DeveRetornarFalse() {
        // Arrange
        String tokenValido = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";
        when(strategy1.validate(any())).thenReturn(false);
        when(strategy2.validate(any())).thenReturn(true);

        // Act
        boolean resultado = jwtService.validarJwt(tokenValido);

        // Assert
        assertFalse(resultado);
        verify(strategy1, timeout(1000)).validate(any());
        // Como a execução é paralela, não podemos garantir que strategy2 não será chamada
    }

    @Test
    void validarJwt_QuandoEstrategiaLancaExcecao_DevePropagarExcecao() {
        // Arrange
        String tokenValido = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";
        RuntimeException excecaoEsperada = new RuntimeException("Erro na validação");
        when(strategy1.validate(any())).thenThrow(excecaoEsperada);

        // Act & Assert
        RuntimeException excecao = assertThrows(RuntimeException.class, () -> {
            jwtService.validarJwt(tokenValido);
        });

        assertTrue(excecao.getMessage().contains("Erro na validação"));
        verify(strategy1, timeout(1000)).validate(any());
    }
} 