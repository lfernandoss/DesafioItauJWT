# 🚀 Desafio Itaú - API JWT com Infraestrutura AWS

Este projeto implementa uma API de validação de JWT com infraestrutura AWS completa usando LocalStack para desenvolvimento e testes.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Funcionalidades](#funcionalidades)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Uso](#uso)
- [API Endpoints](#api-endpoints)
- [Infraestrutura AWS](#infraestrutura-aws)
- [Testes](#testes)
- [Monitoramento](#monitoramento)
- [Troubleshooting](#troubleshooting)

## 🎯 Visão Geral

Este projeto demonstra uma aplicação Spring Boot que valida tokens JWT com regras específicas de negócio, deployada em uma infraestrutura AWS completa simulada pelo LocalStack. A solução inclui:

- **API REST** para validação de JWT com regras específicas
- **Padrão Strategy** para validações flexíveis
- **Infraestrutura AWS** completa (VPC, ECS, ALB, CloudWatch)
- **Deploy automatizado** em ECS Fargate
- **Testes BDD** com Cucumber
- **Monitoramento** com métricas Prometheus
- **Logs centralizados**
- **Gerenciamento** via scripts automatizados e Terraform

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                        LocalStack                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │     ECS     │  │     IAM     │  │    Logs     │            │
│  │             │  │             │  │             │            │
│  │ - Cluster   │  │ - Roles     │  │ - Log Groups│            │
│  │ - Services  │  │ - Policies  │  │ - Streams   │            │
│  │ - Tasks     │  │             │  │             │            │
│  │ - ALB       │  │             │  │             │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ECS Fargate Service                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │   Docker    │  │   Docker    │  │   Load      │            │
│  │   Engine    │  │  Compose    │  │  Balancer   │            │
│  │             │  │             │  │             │            │
│  │ - Container │  │ - App Config│  │ - Health    │            │
│  │ - Network   │  │ - Volumes   │  │   Checks    │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Aplicação Spring Boot                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │   JWT API   │  │  Strategy   │  │  Prometheus │            │
│  │             │  │   Pattern   │  │             │            │
│  │ - Validação │  │ - Claims    │  │ - Métricas  │            │
│  │ - Controller│  │ - Name      │  │ - Endpoints │            │
│  │ - Service   │  │ - Role      │  │ - Monitoring│            │
│  │ - Validator │  │ - Seed      │  │             │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

## 🛠️ Tecnologias

### Backend
- **Java 17** - Linguagem principal
- **Spring Boot 2.7.9** - Framework web
- **Spring Security** - Segurança e validação
- **Maven** - Gerenciamento de dependências
- **JWT** - JSON Web Tokens (JJWT)
- **Micrometer** - Métricas e monitoramento
- **Prometheus** - Coleta de métricas
- **Resilience4j** - Circuit breaker e resiliência
- **MapStruct** - Mapeamento de objetos
- **Lombok** - Redução de boilerplate

### Testes
- **JUnit 5** - Testes unitários
- **Cucumber** - Testes BDD
- **Spring Boot Test** - Testes de integração
- **TestRestTemplate** - Testes de API

### Infraestrutura
- **Docker** - Containerização
- **Docker Compose** - Orquestração local
- **LocalStack** - Simulação AWS local
- **Terraform** - Infraestrutura como código
- **AWS CLI** - Gerenciamento AWS
- **Alpine Linux** - Imagem base para scripts

### AWS Services (LocalStack)
- **ECS Fargate** - Containers serverless
- **Application Load Balancer** - Balanceamento de carga
- **VPC** - Rede privada virtual
- **IAM** - Gerenciamento de identidade
- **CloudWatch Logs** - Logs centralizados

## 🚀 Funcionalidades

### Validação de JWT com Regras Específicas

A API implementa validações rigorosas de tokens JWT usando o padrão Strategy:

#### 1. **Validação de Claims Size**
- Verifica se o JWT possui exatamente 3 claims
- Rejeita tokens com claims extras ou faltantes

#### 2. **Validação de Nome**
- Verifica se existe o claim "Name"
- Nome não pode estar vazio
- Máximo de 256 caracteres
- **Não pode conter números** (regra específica do negócio)

#### 3. **Validação de Role**
- Verifica se existe o claim "Role"
- Aceita apenas roles válidos: `Admin`, `Member`, `External`
- Validação case-sensitive

#### 4. **Validação de Seed**
- Verifica se existe o claim "Seed"
- Seed deve ser um número primo

### Padrão Strategy para Validações

```java
// Interface Strategy
public interface JwtValidationStrategy {
    boolean validate(Map<String, Object> claims);
}

// Implementações específicas
- ClaimsSizeValidationStrategy
- NameValidationStrategy  
- RoleValidationStrategy
- SeedValidationStrategy
```

### Validação de Entrada

- **Validador Customizado**: `@JwtValid` para validar formato do token
- **Validação de Estrutura**: Verifica se o JWT possui 3 partes (header.payload.signature)
- **Tratamento de Erros**: Handler global com respostas padronizadas

### Testes BDD com Cucumber

```gherkin
Funcionalidade: Validação de JWT
  Cenário: Validar JWT com claims válidas
  Cenário: Validar JWT com formato inválido
  Cenário: Validar JWT com caracteres numéricos no nome
  Cenário: Validar JWT com mais de três claims
```

### Infraestrutura como Código (Terraform)

- **ECS Fargate**: Deploy serverless
- **Application Load Balancer**: Balanceamento de carga
- **Auto Scaling**: Escalabilidade automática
- **Health Checks**: Verificações de saúde
- **CloudWatch Logs**: Logs centralizados

## 📋 Pré-requisitos

- **Docker** (versão 20.10+)
- **Docker Compose** (versão 2.0+)
- **Java 17** (para desenvolvimento local)
- **Maven** (para desenvolvimento local)
- **Terraform** (versão 1.0+)
- **Postman** (para testes da API)

## 🚀 Instalação

### 1. Clone o repositório
```bash
git clone <url-do-repositorio>
cd DesafioItau-main
```

### 2. Build da aplicação
```bash
# Build local (opcional)
mvn clean install -DskipTests

# Ou usar Docker
docker build -t app:latest .
```

### 3. Configurar ambiente
```bash
# Criar arquivo .env (opcional)
cp .env.example .env
```

## 💻 Uso

### Opção 1: Execução Local (Desenvolvimento)

```bash
# Executar apenas a aplicação
docker-compose up app

# Ou executar com Maven
mvn spring-boot:run
```

### Opção 2: Infraestrutura Completa (Produção Simulada)

```bash
# 1. Criar infraestrutura AWS com Terraform
docker-compose up terraform-init
docker-compose up terraform-apply

# 2. Deploy da aplicação em ECS
docker-compose up ecs-deploy

# 3. Gerenciar o serviço
docker-compose run ecs-manager sh /scripts/manage-ecs.sh status
```

### Opção 3: Execução Completa

```bash
# Executar tudo de uma vez
docker-compose up
```

## 🔌 API Endpoints

### Base URL
- **Local**: `http://localhost:8080`
- **ECS**: `http://IP_DO_ALB:80`

### Endpoints Disponíveis

#### 1. Validação de JWT
```http
POST /v1/validar/Jwt/{tokenJwt}
```

**Headers:**
```
Content-Type: application/json
Correlation-id: {uuid} (opcional)
```

**Exemplo de Token Válido:**
```bash
curl -X POST \
  http://localhost:8080/v1/validar/Jwt/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJOYW1lIjoiSm9obiBEb2UiLCJSb2xlIjoiQWRtaW4iLCJTZWVkIjoiMTMifQ \
  -H "Content-Type: application/json" \
  -H "Correlation-id: teste-123"
```

**Resposta:**
```json
true
```

**Exemplo de Token Inválido (nome com números):**
```bash
curl -X POST \
  http://localhost:8080/v1/validar/Jwt/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJOYW1lIjoiSm9obiBEb2UgMTIzIiwiUm9sZSI6IkFkbWluIiwiU2VlZCI6IjEzIn0 \
  -H "Content-Type: application/json"
```

**Resposta:**
```json
false
```

#### 2. Health Check
```http
GET /actuator/health
```

**Resposta:**
```json
{
  "status": "UP"
}
```

#### 3. Métricas Prometheus
```http
GET /actuator/prometheus
```

#### 4. Informações da Aplicação
```http
GET /actuator/info
```

## ☁️ Infraestrutura AWS

### Recursos Criados (Terraform)

1. **VPC** - Rede privada virtual
2. **Subnets** - Subnets públicas e privadas
3. **Security Groups** - Regras de firewall
4. **Internet Gateway** - Conexão com internet
5. **Route Tables** - Configuração de rotas
6. **ECS Cluster** - Cluster Fargate
7. **ECS Service** - Serviço da aplicação
8. **Application Load Balancer** - Balanceamento de carga
9. **Target Group** - Grupo de destino
10. **IAM Roles** - Permissões para ECS
11. **CloudWatch Log Group** - Logs centralizados

### Gerenciamento da Infraestrutura

```bash
# Ver status do serviço ECS
docker-compose run ecs-manager sh /scripts/manage-ecs.sh status

# Ver logs da aplicação
docker-compose run ecs-manager sh /scripts/manage-ecs.sh logs

# Testar aplicação
docker-compose run ecs-manager sh /scripts/manage-ecs.sh test

# Reiniciar aplicação
docker-compose run ecs-manager sh /scripts/manage-ecs.sh restart

# Parar serviço
docker-compose run ecs-manager sh /scripts/manage-ecs.sh stop

# Iniciar serviço
docker-compose run ecs-manager sh /scripts/manage-ecs.sh start

# Deletar infraestrutura
docker-compose run terraform-destroy
```

## 🧪 Testes

### Testes Unitários
```bash
mvn test
```

### Testes de Integração
```bash
mvn verify
```

### Testes BDD (Cucumber)
```bash
# Executar testes BDD
mvn test -Dtest=*CucumberTest

# Ou executar feature específica
mvn test -Dcucumber.features=src/test/resources/features/validacao_jwt.feature
```

### Testes da API
```bash
# Usar a collection do Postman (veja POSTMAN-GUIDE.md)
# Ou usar curl

# Teste de conectividade
curl http://localhost:8080/actuator/health

# Teste de validação JWT válido
curl -X POST \
  http://localhost:8080/v1/validar/Jwt/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJOYW1lIjoiSm9obiBEb2UiLCJSb2xlIjoiQWRtaW4iLCJTZWVkIjoiMTMifQ \
  -H "Content-Type: application/json"

# Teste de validação JWT inválido (nome com números)
curl -X POST \
  http://localhost:8080/v1/validar/Jwt/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJOYW1lIjoiSm9obiBEb2UgMTIzIiwiUm9sZSI6IkFkbWluIiwiU2VlZCI6IjEzIn0 \
  -H "Content-Type: application/json"
```

## 📊 Monitoramento

### Métricas Disponíveis
- **JWT Validation** - Tempo de validação
- **HTTP Requests** - Requisições por endpoint
- **System Metrics** - CPU, memória, etc.
- **Circuit Breaker** - Métricas de resiliência

### Acesso às Métricas
```bash
# Prometheus
curl http://localhost:8080/actuator/prometheus

# Health Check
curl http://localhost:8080/actuator/health

# Info
curl http://localhost:8080/actuator/info
```

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. LocalStack não inicia
```bash
# Verificar se a porta 4566 está livre
netstat -an | grep 4566

# Reiniciar LocalStack
docker-compose restart localstack

# Ver logs
docker-compose logs localstack
```

#### 2. Aplicação não responde
```bash
# Verificar se está rodando
docker-compose ps

# Ver logs da aplicação
docker-compose logs app

# Verificar portas
netstat -an | grep 8080
```

#### 3. ECS não cria
```bash
# Verificar se a infraestrutura foi criada
docker-compose run ecs-manager sh /scripts/manage-ecs.sh status

# Verificar logs do deploy
docker-compose logs ecs-deploy
```

#### 4. Problemas de conectividade
```bash
# Verificar Security Groups
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups

# Verificar VPC
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs
```

#### 5. Testes falhando
```bash
# Verificar se a aplicação está rodando
curl http://localhost:8080/actuator/health

# Executar testes com debug
mvn test -X

# Verificar logs dos testes
mvn test -Dspring.profiles.active=test
```

### Logs Úteis

```bash
# Logs do LocalStack
docker-compose logs localstack

# Logs da aplicação
docker-compose logs app

# Logs do deploy
docker-compose logs ecs-deploy

# Logs do gerenciador
docker-compose logs ecs-manager

# Logs do Terraform
docker-compose logs terraform-apply
```

## 📁 Estrutura do Projeto

```
DesafioItau-main/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/desafioitau/api/jwt/
│   │   │       ├── config/           # Configurações
│   │   │       ├── domain/           # Lógica de negócio
│   │   │       │   ├── model/        # Modelos e enums
│   │   │       │   ├── service/      # Serviços
│   │   │       │   ├── strategy/     # Padrão Strategy
│   │   │       │   └── exception/    # Tratamento de erros
│   │   │       └── rest/             # Controllers REST
│   │   │           ├── controller/   # Controllers
│   │   │           ├── dto/          # DTOs
│   │   │           └── validator/    # Validadores customizados
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       ├── java/
│       │   └── com/desafioitau/api/jwt/
│       │       ├── integration/      # Testes BDD com Cucumber
│       │       ├── domain/           # Testes de domínio
│       │       └── rest/             # Testes de API
│       └── resources/
│           ├── features/             # Features Cucumber
│           └── application-test.yml
├── terraform/                        # Infraestrutura como código
│   ├── main.tf
│   ├── variables.tf
│   ├── ecs.tf
│   ├── network.tf
│   └── outputs.tf
├── scripts/
│   ├── setup-aws.sh                  # Criação da infraestrutura
│   ├── deploy-ecs.sh                 # Deploy em ECS
│   └── manage-ecs.sh                 # Gerenciamento ECS
├── docker-compose.yml                # Orquestração
├── Dockerfile                        # Imagem da aplicação
├── pom.xml                          # Dependências Maven
├── README.md                        # Este arquivo
├── POSTMAN-GUIDE.md                 # Guia do Postman
├── EC2-DEPLOY.md                    # Guia específico EC2
└── postman-collection.json          # Collection do Postman
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📚 Documentação Adicional

- [Guia do Postman](POSTMAN-GUIDE.md) - Como usar a collection do Postman
- [Collection Postman](postman-collection.json) - Collection completa para testes

## 📝 TODOs - Melhorias Futuras

### 🔍 Logs e Observabilidade

- [ ] **Implementar Logging Estruturado**
  - [ ] Configurar Logback com formato JSON estruturado
  - [ ] Adicionar correlation-id em todos os logs
  - [ ] Implementar MDC (Mapped Diagnostic Context) para rastreamento
  - [ ] Configurar níveis de log por ambiente (dev/prod)



### 📊 Métricas de Regras de Negócio

- [ ] **Métricas Específicas de Validação**
  - [ ] Contador de validações por tipo de claim (Name, Role, Seed)
  - [ ] Taxa de rejeição por regra de negócio
  - [ ] Tempo médio de validação por strategy
  - [ ] Distribuição de roles utilizados nos tokens

- [ ] **Métricas de Qualidade**
  - [ ] Porcentagem de tokens com formato inválido
  - [ ] Frequência de tokens com números no nome
  - [ ] Distribuição de seeds primos vs não-primos
  - [ ] Métricas de complexidade dos nomes (tamanho, caracteres especiais)


### ☁️ Deploy na AWS com Datadog

- [ ] **Configuração do Datadog Agent**
  - [ ] Criar Dockerfile com Datadog Agent integrado
  - [ ] Configurar coleta de métricas customizadas
  - [ ] Implementar APM (Application Performance Monitoring)
  - [ ] Configurar log forwarding para Datadog

- [ ] **Arquivos de Deploy AWS**
  - [ ] `datadog-agent.yaml` - Configuração do agente
  - [ ] `datadog-values.yaml` - Valores para Helm chart
  - [ ] `aws-deploy.sh` - Script de deploy automatizado
  - [ ] `datadog-dashboard.json` - Dashboard customizado

- [ ] **Infraestrutura como Código**
  - [ ] Atualizar Terraform para incluir Datadog
  - [ ] Configurar IAM roles para Datadog
  - [ ] Implementar auto-scaling baseado em métricas


### 🔧 Melhorias Técnicas

- [ ] **Performance e Escalabilidade**
  - [ ] Implementar cache Redis para validações
  - [ ] Otimizar algoritmo de verificação de primalidade


- [ ] **DevOps e CI/CD**
  - [ ] Configurar GitHub Actions para deploy automático
  - [ ] Implementar blue-green deployment
  - [ ] Adicionar testes de performance automatizados
  - [ ] Configurar rollback automático em caso de falha




