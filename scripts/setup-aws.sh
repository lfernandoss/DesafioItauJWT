#!/bin/sh

# Função para verificar se o LocalStack está pronto
wait_for_localstack() {
    echo "Verificando se o LocalStack está pronto..."
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Tentativa $attempt/$max_attempts - Testando conexão com LocalStack..."
        echo "ENDPOINT_URL: $ENDPOINT_URL"
        echo "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
        
        if aws --endpoint-url=$ENDPOINT_URL sts get-caller-identity >/dev/null 2>&1; then
            echo "LocalStack está pronto!"
            return 0
        fi
        
        echo "LocalStack ainda não está pronto..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    echo "Erro: LocalStack não ficou pronto após $max_attempts tentativas"
    return 1
}

# Verificar se o LocalStack está pronto
if ! wait_for_localstack; then
    exit 1
fi

# Definir região do Brasil
export AWS_DEFAULT_REGION=sa-east-1

echo "Iniciando criação dos recursos AWS básicos..."

# Criar VPC
echo "Criando VPC..."
VPC_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC criada: $VPC_ID"

# Criar Subnets em múltiplas AZs
echo "Criando Subnets..."
SUBNET1_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone sa-east-1a \
    --query 'Subnet.SubnetId' \
    --output text)

SUBNET2_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone sa-east-1b \
    --query 'Subnet.SubnetId' \
    --output text)

SUBNET3_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.3.0/24 \
    --availability-zone sa-east-1c \
    --query 'Subnet.SubnetId' \
    --output text)

echo "Subnets criadas: $SUBNET1_ID, $SUBNET2_ID, $SUBNET3_ID"

# Criar Security Group
echo "Criando Security Group..."
SG_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 create-security-group \
    --group-name app-sg \
    --description "Security group for app" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

echo "Security Group criado: $SG_ID"

# Permitir tráfego HTTP
echo "Configurando regras do Security Group..."
aws --endpoint-url=$ENDPOINT_URL ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0

# Permitir tráfego SSH (opcional)
echo "Configurando acesso SSH..."
aws --endpoint-url=$ENDPOINT_URL ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# Criar Internet Gateway
echo "Criando Internet Gateway..."
IGW_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 create-internet-gateway \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

echo "Internet Gateway criado: $IGW_ID"

# Anexar Internet Gateway à VPC
echo "Anexando Internet Gateway à VPC..."
aws --endpoint-url=$ENDPOINT_URL ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID

# Criar Route Table
echo "Criando Route Table..."
ROUTE_TABLE_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 create-route-table \
    --vpc-id $VPC_ID \
    --query 'RouteTable.RouteTableId' \
    --output text)

echo "Route Table criado: $ROUTE_TABLE_ID"

# Adicionar rota para Internet
echo "Configurando rota para Internet..."
aws --endpoint-url=$ENDPOINT_URL ec2 create-route \
    --route-table-id $ROUTE_TABLE_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

# Associar Route Table às Subnets
echo "Associando Route Table às Subnets..."
aws --endpoint-url=$ENDPOINT_URL ec2 associate-route-table \
    --route-table-id $ROUTE_TABLE_ID \
    --subnet-id $SUBNET1_ID

aws --endpoint-url=$ENDPOINT_URL ec2 associate-route-table \
    --route-table-id $ROUTE_TABLE_ID \
    --subnet-id $SUBNET2_ID

aws --endpoint-url=$ENDPOINT_URL ec2 associate-route-table \
    --route-table-id $ROUTE_TABLE_ID \
    --subnet-id $SUBNET3_ID

echo "Configuração AWS básica concluída!"
echo "Recursos criados:"
echo "- VPC: $VPC_ID"
echo "- Subnets: $SUBNET1_ID, $SUBNET2_ID, $SUBNET3_ID"
echo "- Security Group: $SG_ID"
echo "- Internet Gateway: $IGW_ID"
echo "- Route Table: $ROUTE_TABLE_ID"
echo ""
echo "Infraestrutura básica pronta para deploy de aplicações!" 