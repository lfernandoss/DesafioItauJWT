package com.desafioitau.api.jwt.domain.strategy.impl;

import com.desafioitau.api.jwt.domain.model.enums.Role;
import com.desafioitau.api.jwt.domain.strategy.JwtValidationStrategy;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;

@Component
public class RoleValidationStrategy implements JwtValidationStrategy {

    @Override
    public boolean validate(Map<String, Object> claims) {
        return Optional.ofNullable(claims.get("Role"))
                .map(Object::toString)
                .filter(Role::isValid)
                .isPresent();
    }
    
} 