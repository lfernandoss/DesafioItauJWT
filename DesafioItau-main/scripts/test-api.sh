#!/bin/sh

# Script para testar a API após deploy

echo "=== Teste da API JWT ==="

# Obter IP da instância (tentar Elastic IP primeiro)
echo "Obtendo IP da instância EC2..."
PUBLIC_IP=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-addresses \
    --query 'Addresses[0].PublicIp' \
    --output text)

if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "None" ]; then
    echo "Tentando obter IP da instância diretamente..."
    PUBLIC_IP=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
fi

if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "None" ]; then
    echo "Erro: Não foi possível obter o IP da instância"
    echo "Tentando usar IP interno..."
    PUBLIC_IP=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text)
fi

if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "None" ]; then
    echo "Erro: Não foi possível obter nenhum IP da instância"
    echo "Listando todas as instâncias:"
    aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
        --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress,PrivateIpAddress]' \
        --output table
    exit 1
fi

echo "IP da instância: $PUBLIC_IP"
echo ""

# Aguardar aplicação inicializar
echo "Aguardando aplicação inicializar..."
sleep 15

# Teste 1: Health Check
echo "1. Testando Health Check..."
curl -s -w "Status: %{http_code}, Tempo: %{time_total}s\n" \
  http://$PUBLIC_IP:8080/actuator/health
echo ""

# Teste 2: JWT Válido
echo "2. Testando JWT Válido..."
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Correlation-id: teste-$(date +%s)" \
  -w "Status: %{http_code}, Tempo: %{time_total}s\n" \
  http://$PUBLIC_IP:8080/v1/validar/Jwt/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ
echo ""

# Teste 3: JWT Inválido
echo "3. Testando JWT Inválido..."
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Correlation-id: teste-$(date +%s)" \
  -w "Status: %{http_code}, Tempo: %{time_total}s\n" \
  http://$PUBLIC_IP:8080/v1/validar/Jwt/jwt.invalido
echo ""

# Teste 4: Métricas
echo "4. Testando Métricas Prometheus..."
curl -s -w "Status: %{http_code}, Tempo: %{time_total}s\n" \
  http://$PUBLIC_IP:8080/actuator/prometheus | head -5
echo ""

# Teste 5: Info da Aplicação
echo "5. Testando Info da Aplicação..."
curl -s -w "Status: %{http_code}, Tempo: %{time_total}s\n" \
  http://$PUBLIC_IP:8080/actuator/info
echo ""

echo "=== Testes Concluídos ==="
echo "URL da aplicação: http://$PUBLIC_IP:8080"
echo ""
echo "Comandos curl para uso manual:"
echo "curl http://$PUBLIC_IP:8080/actuator/health"
echo "curl -X POST http://$PUBLIC_IP:8080/v1/validar/Jwt/seu_token -H 'Content-Type: application/json'" 