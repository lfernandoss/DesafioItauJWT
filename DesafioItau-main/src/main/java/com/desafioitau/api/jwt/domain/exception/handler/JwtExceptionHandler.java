package com.desafioitau.api.jwt.domain.exception.handler;

import com.desafioitau.api.jwt.domain.model.erros.ErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class JwtExceptionHandler {


    @ExceptionHandler
    public ResponseEntity<Object> handleException(final RuntimeException ex) {
        final ErrorResponse errorResponse = ErrorResponse.builder()
                .codigo(String.valueOf(HttpStatus.BAD_REQUEST))
                .mensagem(ex.getMessage())
                .build();
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

}
