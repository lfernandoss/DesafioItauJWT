package com.desafioitau.api.jwt.integration.steps;

import io.cucumber.java.pt.Dado;
import io.cucumber.java.pt.Entao;
import io.cucumber.java.pt.Quando;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.junit.jupiter.api.Assertions.*;

public class JwtValidationSteps {

    @Autowired
    private TestRestTemplate restTemplate;

    private String tokenJwt;
    private ResponseEntity<Boolean> response;

    @Dado("que eu tenho um token JWT válido")
    public void queEuTenhoUmTokenJwtValido() {
        tokenJwt = JwtTestTokens.TOKEN_JWT_VALIDO;
    }

    @Dado("que eu tenho um token JWT com formato inválido")
    public void queEuTenhoUmTokenJwtComFormatoInvalido() {
        tokenJwt = JwtTestTokens.TOKEN_JWT_FORMATO_INVALIDO;
    }

    @Dado("que eu tenho um token JWT com caracteres numéricos no nome")
    public void queEuTenhoUmTokenJwtComCaracteresNumericosNoNome() {
        tokenJwt = JwtTestTokens.TOKEN_JWT_NOME_NUMERICO;
    }

    @Dado("que eu tenho um token JWT com mais de três claims")
    public void queEuTenhoUmTokenJwtComMaisDeTresClaims() {
        tokenJwt = JwtTestTokens.TOKEN_JWT_MAIS_CLAIMS;
    }

    @Quando("eu enviar o token para validação")
    public void euEnviarOTokenParaValidacao() {
        response = restTemplate.postForEntity("/v1/validar/Jwt/" + tokenJwt, null, Boolean.class);
    }

    @Entao("o sistema deve retornar que o token é válido")
    public void oSistemaDeveRetornarQueOTokenEValido() {
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody());
    }

    @Entao("o sistema deve retornar que o token é inválido")
    public void oSistemaDeveRetornarQueOTokenEInvalido() {
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertFalse(response.getBody());
    }
} 