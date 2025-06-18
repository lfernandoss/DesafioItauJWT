package com.desafioitau.api.jwt.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.UUID;

@Component
public class CorrelationIDInterceptor extends HandlerInterceptorAdapter {

    Logger logger = LoggerFactory.getLogger(CorrelationIDInterceptor.class);
    private static String CORRELATION_ID_NAME = "correlationId";
    private String correlationId;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        correlationId = buscarCorrelationIdHeader(request);
        MDC.put(CORRELATION_ID_NAME, correlationId);
        logger.info("correlation ID :" + correlationId);
        return true;
    }

    private String buscarCorrelationIdHeader(HttpServletRequest request){
        correlationId = request.getHeader("Correlation-id");
        if (correlationId == null || correlationId.isEmpty()) {
            return UUID.randomUUID().toString();
        }
        return correlationId;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response,
                                Object handler, Exception ex) throws Exception {
        MDC.remove(CORRELATION_ID_NAME);
    }
}
