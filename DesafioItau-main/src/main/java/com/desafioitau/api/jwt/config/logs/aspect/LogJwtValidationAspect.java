package com.desafioitau.api.jwt.config.logs.aspect;

import com.desafioitau.api.jwt.config.logs.annotation.LogJwtValidation;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;

/**
 * Aspect para interceptar e logar a execução de métodos anotados com @LogJwtValidation
 */
@Slf4j
@Aspect
@Component
public class LogJwtValidationAspect {

    @Around("@annotation(com.desafioitau.api.jwt.config.logs.annotation.LogJwtValidation)")
    public Object logJwtValidation(ProceedingJoinPoint joinPoint) throws Throwable {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        LogJwtValidation annotation = method.getAnnotation(LogJwtValidation.class);
        
        String methodName = method.getName();
        String className = method.getDeclaringClass().getSimpleName();
        String customMessage = annotation.message();
        boolean logToken = annotation.logToken();
        
        // Log de início da validação
        log.info("{} - Iniciando validação JWT em {}.{}", customMessage, className, methodName);
        
        // Log do token se configurado (cuidado com segurança)
        if (logToken && joinPoint.getArgs().length > 0) {
            Object token = joinPoint.getArgs()[0];
            if (token instanceof String) {
                String tokenStr = (String) token;
                // Log apenas os primeiros e últimos caracteres por segurança
                if (tokenStr.length() > 10) {
                    log.info("Token JWT: {}...{}", 
                        tokenStr.substring(0, 10), 
                        tokenStr.substring(tokenStr.length() - 10));
                } else {
                    log.info("Token JWT: {}", tokenStr);
                }
            }
        }
        
        long startTime = System.currentTimeMillis();
        Object result = null;
        boolean success = false;
        
        try {
            result = joinPoint.proceed();
            success = true;
            return result;
        } catch (Exception e) {
            log.error("{} - Erro na validação JWT em {}.{}: {}", 
                customMessage, className, methodName, e.getMessage());
            throw e;
        } finally {
            long endTime = System.currentTimeMillis();
            long duration = endTime - startTime;
            
            if (success) {
                log.info("{} - Validação JWT concluída com sucesso em {}.{} (duração: {}ms)", 
                    customMessage, className, methodName, duration);
            } else {
                log.error("{} - Validação JWT falhou em {}.{} (duração: {}ms)", 
                    customMessage, className, methodName, duration);
            }
        }
    }
} 