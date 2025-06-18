package com.desafioitau.api.jwt.domain.ports.in;

public interface JwtServicePort {

   boolean validarJwt(String tokenJwt);

}
