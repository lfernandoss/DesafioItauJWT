#!/bin/sh

# Script para verificar e corrigir problemas de rede

echo "=== Verificação e Correção de Rede ==="

# Verificar se o LocalStack está pronto
echo "1. Verificando LocalStack..."
if ! aws --endpoint-url=$ENDPOINT_URL sts get-caller-identity >/dev/null 2>&1; then
    echo "Erro: LocalStack não está respondendo"
    exit 1
fi
echo "✅ LocalStack está funcionando"

# Listar todas as instâncias
echo ""
echo "2. Listando todas as instâncias:"
aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
    --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress,PrivateIpAddress]' \
    --output table

# Listar Elastic IPs
echo ""
echo "3. Listando Elastic IPs:"
aws --endpoint-url=$ENDPOINT_URL ec2 describe-addresses \
    --query 'Addresses[].[AllocationId,PublicIp,InstanceId]' \
    --output table

# Listar VPCs e Subnets
echo ""
echo "4. Listando VPCs e Subnets:"
VPC_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-vpcs \
    --query 'Vpcs[0].VpcId' \
    --output text)

echo "VPC: $VPC_ID"

aws --endpoint-url=$ENDPOINT_URL ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[].[SubnetId,AvailabilityZone,CidrBlock]' \
    --output table

# Listar Security Groups
echo ""
echo "5. Listando Security Groups:"
aws --endpoint-url=$ENDPOINT_URL ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'SecurityGroups[].[GroupId,GroupName,Description]' \
    --output table

# Verificar Internet Gateway
echo ""
echo "6. Verificando Internet Gateway:"
IGW_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --query 'InternetGateways[0].InternetGatewayId' \
    --output text)

if [ "$IGW_ID" != "None" ] && [ -n "$IGW_ID" ]; then
    echo "✅ Internet Gateway: $IGW_ID"
else
    echo "❌ Internet Gateway não encontrado"
fi

# Verificar Route Tables
echo ""
echo "7. Verificando Route Tables:"
aws --endpoint-url=$ENDPOINT_URL ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'RouteTables[].[RouteTableId,Routes[0].DestinationCidrBlock,Routes[0].GatewayId]' \
    --output table

# Tentar obter IP de uma instância específica
echo ""
echo "8. Tentando obter IP de instância específica:"
INSTANCE_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[0].Instances[0].InstanceId' \
    --output text)

if [ "$INSTANCE_ID" != "None" ] && [ -n "$INSTANCE_ID" ]; then
    echo "Instância encontrada: $INSTANCE_ID"
    
    # Tentar diferentes métodos para obter IP
    echo "Método 1 - Public IP:"
    PUBLIC_IP=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
    echo "Public IP: $PUBLIC_IP"
    
    echo "Método 2 - Private IP:"
    PRIVATE_IP=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text)
    echo "Private IP: $PRIVATE_IP"
    
    echo "Método 3 - Elastic IP:"
    EIP=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-addresses \
        --query 'Addresses[0].PublicIp' \
        --output text)
    echo "Elastic IP: $EIP"
    
    # Usar o primeiro IP válido encontrado
    if [ "$EIP" != "None" ] && [ -n "$EIP" ]; then
        USABLE_IP=$EIP
        echo "✅ Usando Elastic IP: $USABLE_IP"
    elif [ "$PUBLIC_IP" != "None" ] && [ -n "$PUBLIC_IP" ]; then
        USABLE_IP=$PUBLIC_IP
        echo "✅ Usando Public IP: $USABLE_IP"
    elif [ "$PRIVATE_IP" != "None" ] && [ -n "$PRIVATE_IP" ]; then
        USABLE_IP=$PRIVATE_IP
        echo "✅ Usando Private IP: $USABLE_IP"
    else
        echo "❌ Nenhum IP válido encontrado"
        USABLE_IP=""
    fi
    
    if [ -n "$USABLE_IP" ]; then
        echo ""
        echo "9. Testando conectividade:"
        echo "Testando HTTP na porta 8080..."
        curl -s -o /dev/null -w "Status: %{http_code}, Tempo: %{time_total}s\n" \
            http://$USABLE_IP:8080/actuator/health || echo "❌ Não foi possível conectar"
    fi
else
    echo "❌ Nenhuma instância rodando encontrada"
fi

echo ""
echo "=== Verificação Concluída ===" 