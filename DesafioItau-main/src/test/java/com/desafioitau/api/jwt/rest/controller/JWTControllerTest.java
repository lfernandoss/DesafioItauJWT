package com.desafioitau.api.jwt.rest.controller;

import com.desafioitau.api.jwt.domain.ports.in.JwtServicePort;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@DisplayName("Testes do JwtController")
class JWTControllerTest {

    private static final String JWT_VALIDO = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ";
    private static final String JWT_INVALIDO = "jwt.invalido";
    private static final String JWT_NULO = null;
    private static final String JWT_VAZIO = "";

    @Mock
    private JwtServicePort jwtServicePort;

    @InjectMocks
    private JwtController jwtController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Nested
    @DisplayName("Testes do método validarJwt")
    class ValidarJwtTests {

        @Test
        @DisplayName("Deve retornar true quando JWT é válido")
        void validarJwt_QuandoJwtValido_DeveRetornarTrue() {
            // Arrange
            when(jwtServicePort.validarJwt(JWT_VALIDO)).thenReturn(true);

            // Act
            ResponseEntity<Boolean> response = jwtController.validarJwt(JWT_VALIDO);

            // Assert
            assertAll(
                () -> assertNotNull(response, "Response não deve ser nulo"),
                () -> assertEquals(HttpStatus.OK, response.getStatusCode(), "Status code deve ser 200"),
                () -> assertTrue(response.getBody(), "JWT deve ser válido"),
                () -> verify(jwtServicePort, times(1)).validarJwt(JWT_VALIDO)
            );
        }

        @Test
        @DisplayName("Deve retornar false quando JWT é inválido")
        void validarJwt_QuandoJwtInvalido_DeveRetornarFalse() {
            // Arrange
            when(jwtServicePort.validarJwt(JWT_INVALIDO)).thenReturn(false);

            // Act
            ResponseEntity<Boolean> response = jwtController.validarJwt(JWT_INVALIDO);

            // Assert
            assertAll(
                () -> assertNotNull(response, "Response não deve ser nulo"),
                () -> assertEquals(HttpStatus.OK, response.getStatusCode(), "Status code deve ser 200"),
                () -> assertFalse(response.getBody(), "JWT deve ser inválido"),
                () -> verify(jwtServicePort, times(1)).validarJwt(JWT_INVALIDO)
            );
        }

        @Test
        @DisplayName("Deve retornar false quando JWT é nulo")
        void validarJwt_QuandoJwtNulo_DeveRetornarFalse() {
            // Arrange
            when(jwtServicePort.validarJwt(JWT_NULO)).thenReturn(false);

            // Act
            ResponseEntity<Boolean> response = jwtController.validarJwt(JWT_NULO);

            // Assert
            assertAll(
                () -> assertNotNull(response, "Response não deve ser nulo"),
                () -> assertEquals(HttpStatus.OK, response.getStatusCode(), "Status code deve ser 200"),
                () -> assertFalse(response.getBody(), "JWT deve ser inválido"),
                () -> verify(jwtServicePort, times(1)).validarJwt(JWT_NULO)
            );
        }

        @Test
        @DisplayName("Deve retornar false quando JWT está vazio")
        void validarJwt_QuandoJwtVazio_DeveRetornarFalse() {
            // Arrange
            when(jwtServicePort.validarJwt(JWT_VAZIO)).thenReturn(false);

            // Act
            ResponseEntity<Boolean> response = jwtController.validarJwt(JWT_VAZIO);

            // Assert
            assertAll(
                () -> assertNotNull(response, "Response não deve ser nulo"),
                () -> assertEquals(HttpStatus.OK, response.getStatusCode(), "Status code deve ser 200"),
                () -> assertFalse(response.getBody(), "JWT deve ser inválido"),
                () -> verify(jwtServicePort, times(1)).validarJwt(JWT_VAZIO)
            );
        }
    }
} 