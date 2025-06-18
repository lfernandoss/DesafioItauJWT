package com.desafioitau.api.jwt.rest.controller;

import com.desafioitau.api.jwt.domain.ports.in.JwtServicePort;
import com.desafioitau.api.jwt.rest.validator.JwtValid;
import com.desafioitau.api.jwt.config.logs.annotation.LogJwtValidation;

import io.micrometer.core.annotation.Timed;
import lombok.extern.slf4j.Slf4j;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/v1/validar/Jwt")
public class JwtController {

    @Autowired
    private JwtServicePort jwtServicePort;

    @PostMapping("/{tokenJwt}")
    @Timed(value = "jwt.validarJwt", percentiles = {0.5, 0.95, 0.99})
    @LogJwtValidation(message = "Validando token JWT", logToken = false)
    public ResponseEntity<Boolean> validarJwt(@JwtValid @PathVariable String tokenJwt) {
        return ResponseEntity.ok(jwtServicePort.validarJwt(tokenJwt));
    }
}