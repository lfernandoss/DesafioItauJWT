package com.desafioitau.api.jwt.domain.model.erros;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;

import java.util.List;

@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ErrorResponse {

    @JsonProperty("codigo")
    private String codigo;

    @JsonProperty("mensagem")
    private String mensagem;

    @JsonProperty("descricao")
    private String descricao;

    @JsonProperty("erros")
    private List<ErroItem> erros;

}
