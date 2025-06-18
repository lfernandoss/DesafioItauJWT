# language: pt
Funcionalidade: Validação de JWT
  Como um usuário do sistema
  Eu quero validar tokens JWT
  Para garantir que eles atendem aos critérios de validação

  Cenário: Validar JWT com claims válidas
    Dado que eu tenho um token JWT válido
    Quando eu enviar o token para validação
    Então o sistema deve retornar que o token é válido

  Cenário: Validar JWT com formato inválido
    Dado que eu tenho um token JWT com formato inválido
    Quando eu enviar o token para validação
    Então o sistema deve retornar que o token é inválido

  Cenário: Validar JWT com caracteres numéricos no nome
    Dado que eu tenho um token JWT com caracteres numéricos no nome
    Quando eu enviar o token para validação
    Então o sistema deve retornar que o token é inválido

  Cenário: Validar JWT com mais de três claims
    Dado que eu tenho um token JWT com mais de três claims
    Quando eu enviar o token para validação
    Então o sistema deve retornar que o token é inválido 