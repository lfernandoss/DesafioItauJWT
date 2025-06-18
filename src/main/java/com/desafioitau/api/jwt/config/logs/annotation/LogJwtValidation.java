package com.desafioitau.api.jwt.config.logs.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Anotação para logar a validação de JWT
 * Pode ser aplicada em métodos que realizam validação de tokens JWT
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface LogJwtValidation {
    
    /**
     * Nível de log a ser utilizado
     * @return nível de log (padrão: INFO)
     */
    String level() default "INFO";
    
    /**
     * Mensagem personalizada para o log
     * @return mensagem do log
     */
    String message() default "Validando JWT";
    
    /**
     * Se deve logar o token JWT (cuidado com segurança)
     * @return true se deve logar o token, false caso contrário
     */
    boolean logToken() default false;
} 