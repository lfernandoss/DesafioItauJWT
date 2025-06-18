package com.desafioitau.api.jwt.domain.service;

import com.desafioitau.api.jwt.domain.ports.in.JwtServicePort;
import com.desafioitau.api.jwt.domain.strategy.JwtValidationStrategy;
import com.desafioitau.api.jwt.config.logs.annotation.LogJwtValidation;
import com.nimbusds.jwt.JWT;
import com.nimbusds.jwt.JWTParser;

import java.text.ParseException;
import java.util.List;
import java.util.Map;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@AllArgsConstructor
public class JwtServicePortImpl implements JwtServicePort {

    @Autowired
    private final List<JwtValidationStrategy> validationStrategies;

    @LogJwtValidation(message = "Executando validação JWT no serviço", logToken = true)
    public boolean validarJwt(String tokenJwt) {
        try {
            JWT jwt = JWTParser.parse(tokenJwt);

            Map<String, Object> claims = jwt.getJWTClaimsSet().getClaims();

            return validationStrategies.parallelStream()
                    .allMatch(strategy -> strategy.validate(claims));

        } catch (ParseException parceException) {
            return false;
        } catch (Exception ex) {
            log.error("Erro ao validar JWT: {}", ex.getMessage(), ex);
            throw ex;
        }
    }
}