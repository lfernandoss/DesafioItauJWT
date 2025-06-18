package com.desafioitau.api.jwt.domain.model.enums;

public enum Role {
    ADMIN("Admin"),
    MEMBER("Member"),
    EXTERNAL("External");

    private final String value;

    Role(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    public static boolean isValid(String role) {
        for (Role r : values()) {
            if (r.value.equals(role)) {
                return true;
            }
        }
        return false;
    }
} 