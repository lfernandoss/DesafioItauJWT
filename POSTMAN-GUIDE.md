# 📮 Guia do Postman - Desafio Itaú JWT API

Este guia explica como usar a collection do Postman para testar a API de validação de JWT.

## 🚀 Importando a Collection

### 1. Abrir o Postman
- Abra o Postman Desktop ou acesse [postman.com](https://postman.com)

### 2. Importar a Collection
- Clique em **Import**
- Selecione o arquivo `postman-collection.json`
- Ou cole o conteúdo JSON na aba **Raw text**

### 3. Configurar Variáveis
Após importar, configure as variáveis de ambiente:

1. Clique em **Environments** → **New**
2. Nome: `Desafio Itaú - Local`
3. Adicione as variáveis:

| Variable | Initial Value | Current Value |
|----------|---------------|---------------|
| `base_url` | `http://localhost:8080` | `http://localhost:8080` |
| `custom_jwt_token` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ` |
| `ec2_base_url` | `http://IP_DA_INSTANCIA:8080` | `http://IP_DA_INSTANCIA:8080` |

4. Clique em **Save**

## 🧪 Testando a API

### 1. Health Check
- **Endpoint**: `GET {{base_url}}/actuator/health`
- **Descrição**: Verifica se a aplicação está funcionando
- **Resposta Esperada**: `{"status":"UP"}`

### 2. Application Info
- **Endpoint**: `GET {{base_url}}/actuator/info`
- **Descrição**: Obtém informações da aplicação
- **Resposta Esperada**: Informações do Spring Boot

### 3. Prometheus Metrics
- **Endpoint**: `GET {{base_url}}/actuator/prometheus`
- **Descrição**: Obtém métricas no formato Prometheus
- **Resposta Esperada**: Métricas em formato texto

### 4. JWT Validation

#### 4.1 Valid JWT Token
- **Endpoint**: `POST {{base_url}}/v1/validar/Jwt/{token}`
- **Headers**: 
  - `Content-Type: application/json`
  - `Correlation-id: {{$guid}}`
- **Resposta Esperada**: `true`

#### 4.2 Invalid JWT Token
- **Endpoint**: `POST {{base_url}}/v1/validar/Jwt/jwt.invalido`
- **Resposta Esperada**: `false` ou erro 400

#### 4.3 Empty JWT Token
- **Endpoint**: `POST {{base_url}}/v1/validar/Jwt/`
- **Resposta Esperada**: Erro 400

#### 4.4 Custom JWT Token
- **Endpoint**: `POST {{base_url}}/v1/validar/Jwt/{{custom_jwt_token}}`
- **Descrição**: Use a variável `custom_jwt_token` para testar tokens personalizados

## 🔄 Alternando entre Local e EC2

### Para testar localmente:
1. Selecione o ambiente `Desafio Itaú - Local`
2. A variável `base_url` deve ser `http://localhost:8080`
3. Execute as requisições

### Para testar na instância EC2:
1. Obtenha o IP da instância:
   ```bash
   docker-compose run ec2-manager sh /scripts/manage-ec2.sh status
   ```

2. Atualize a variável `ec2_base_url`:
   - Vá em **Environments** → **Desafio Itaú - Local**
   - Altere `ec2_base_url` para `http://IP_DA_INSTANCIA:8080`
   - Altere `base_url` para `{{ec2_base_url}}`

3. Execute as requisições

## 📊 Testes Automatizados

A collection inclui testes automatizados que verificam:

### Testes Básicos
- ✅ Status code 200 ou 204
- ✅ Response time < 2000ms
- ✅ Headers corretos

### Testes Específicos
- ✅ JWT validation retorna boolean
- ✅ Health check retorna "UP"
- ✅ Correlation-id é gerado automaticamente

## 🚀 Executando Testes em Lote

### 1. Runner do Postman
1. Clique em **Runner** (ícone de play)
2. Selecione a collection `Desafio Itaú - JWT API`
3. Escolha os requests que deseja executar
4. Configure:
   - **Iterations**: 10 (para testes de carga)
   - **Delay**: 100ms (entre requisições)
5. Clique em **Run Desafio Itaú - JWT API**

### 2. Newman (CLI)
```bash
# Instalar Newman
npm install -g newman

# Executar collection
newman run postman-collection.json -e environment.json

# Executar com relatório HTML
newman run postman-collection.json -e environment.json -r html
```

## 🔧 Customização

### Adicionando Novos Tokens JWT
1. Vá em **Environments** → **Desafio Itaú - Local**
2. Adicione uma nova variável:
   - **Variable**: `my_jwt_token`
   - **Initial Value**: `seu_token_jwt_aqui`
3. Use `{{my_jwt_token}}` nos requests

### Criando Novos Requests
1. Clique em **+** na collection
2. Configure:
   - **Method**: POST/GET/PUT/DELETE
   - **URL**: `{{base_url}}/seu/endpoint`
   - **Headers**: Conforme necessário
3. Adicione testes na aba **Tests**

## 📈 Monitoramento

### Logs no Console
- Abra o **Console** do Postman (View → Show Postman Console)
- Veja logs detalhados de cada requisição
- Monitore tempos de resposta

### Relatórios
- Use o **Runner** para gerar relatórios
- Exporte resultados para CSV/JSON
- Use Newman para relatórios HTML

## 🐛 Troubleshooting

### Problema: Connection Refused
- Verifique se a aplicação está rodando
- Confirme a URL em `base_url`
- Verifique se a porta está correta

### Problema: 404 Not Found
- Verifique se o endpoint está correto
- Confirme se a aplicação foi iniciada
- Verifique logs da aplicação

### Problema: 500 Internal Server Error
- Verifique logs da aplicação
- Confirme se o JWT está no formato correto
- Teste com um token válido

### Problema: Variáveis não funcionam
- Verifique se o ambiente está selecionado
- Confirme se as variáveis estão definidas
- Use `{{$guid}}` para IDs únicos

## 📝 Exemplos de Uso

### Teste Rápido
1. Execute **Health Check**
2. Execute **Valid JWT Token**
3. Verifique se ambos retornam sucesso

### Teste Completo
1. Execute toda a collection
2. Verifique todos os testes passaram
3. Analise os tempos de resposta

### Teste de Carga
1. Use o **Runner** com 50+ iterations
2. Monitore métricas no `/actuator/prometheus`
3. Verifique se não há timeouts

---
 