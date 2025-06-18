#!/bin/sh

# Função para verificar se o LocalStack está pronto
wait_for_localstack() {
    echo "Verificando se o LocalStack está pronto..."
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Tentativa $attempt/$max_attempts - Testando conexão com LocalStack..."
        
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

echo "Iniciando deploy da aplicação em EC2..."

# Verificar se a infraestrutura existe, se não, criar
echo "Verificando infraestrutura existente..."

# Verificar VPC
VPC_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-vpcs \
    --query 'Vpcs[0].VpcId' \
    --output text)

if [ "$VPC_ID" = "None" ] || [ -z "$VPC_ID" ]; then
    echo "VPC não encontrada. Criando nova VPC..."
    VPC_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 create-vpc \
        --cidr-block 10.0.0.0/16 \
        --query 'Vpc.VpcId' \
        --output text)
    echo "VPC criada: $VPC_ID"
else
    echo "VPC encontrada: $VPC_ID"
fi

# Verificar Subnets
SUBNET1_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[0].SubnetId' \
    --output text)

if [ "$SUBNET1_ID" = "None" ] || [ -z "$SUBNET1_ID" ]; then
    echo "Subnets não encontradas. Criando novas subnets..."
    SUBNET1_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 create-subnet \
        --vpc-id $VPC_ID \
        --cidr-block 10.0.1.0/24 \
        --availability-zone sa-east-1a \
        --query 'Subnet.SubnetId' \
        --output text)
    echo "Subnet criada: $SUBNET1_ID"
else
    echo "Subnet encontrada: $SUBNET1_ID"
fi

# Verificar Security Group
SG_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=app-sg" \
    --query 'SecurityGroups[0].GroupId' \
    --output text)

if [ "$SG_ID" = "None" ] || [ -z "$SG_ID" ]; then
    echo "Security Group não encontrado. Criando novo Security Group..."
    SG_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 create-security-group \
        --group-name app-sg \
        --description "Security group for app" \
        --vpc-id $VPC_ID \
        --query 'GroupId' \
        --output text)
    
    echo "Security Group criado: $SG_ID"
    
    # Configurar regras do Security Group
    echo "Configurando regras do Security Group..."
    aws --endpoint-url=$ENDPOINT_URL ec2 authorize-security-group-ingress \
        --group-id $SG_ID \
        --protocol tcp \
        --port 8080 \
        --cidr 0.0.0.0/0
    
    aws --endpoint-url=$ENDPOINT_URL ec2 authorize-security-group-ingress \
        --group-id $SG_ID \
        --protocol tcp \
        --port 22 \
        --cidr 0.0.0.0/0
else
    echo "Security Group encontrado: $SG_ID"
fi

# Verificar Internet Gateway
IGW_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --query 'InternetGateways[0].InternetGatewayId' \
    --output text)

if [ "$IGW_ID" = "None" ] || [ -z "$IGW_ID" ]; then
    echo "Internet Gateway não encontrado. Criando novo Internet Gateway..."
    IGW_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 create-internet-gateway \
        --query 'InternetGateway.InternetGatewayId' \
        --output text)
    
    echo "Internet Gateway criado: $IGW_ID"
    
    # Anexar Internet Gateway à VPC
    echo "Anexando Internet Gateway à VPC..."
    aws --endpoint-url=$ENDPOINT_URL ec2 attach-internet-gateway \
        --internet-gateway-id $IGW_ID \
        --vpc-id $VPC_ID
else
    echo "Internet Gateway encontrado: $IGW_ID"
fi

# Verificar Route Table
ROUTE_TABLE_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'RouteTables[0].RouteTableId' \
    --output text)

if [ "$ROUTE_TABLE_ID" = "None" ] || [ -z "$ROUTE_TABLE_ID" ]; then
    echo "Route Table não encontrado. Criando novo Route Table..."
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
    
    # Associar Route Table à Subnet
    echo "Associando Route Table à Subnet..."
    aws --endpoint-url=$ENDPOINT_URL ec2 associate-route-table \
        --route-table-id $ROUTE_TABLE_ID \
        --subnet-id $SUBNET1_ID
else
    echo "Route Table encontrado: $ROUTE_TABLE_ID"
fi

# Criar Key Pair (se não existir)
echo "Verificando/Criando Key Pair..."
if ! aws --endpoint-url=$ENDPOINT_URL ec2 describe-key-pairs --key-names app-key >/dev/null 2>&1; then
    echo "Criando Key Pair..."
    aws --endpoint-url=$ENDPOINT_URL ec2 create-key-pair \
        --key-name app-key \
        --query 'KeyMaterial' \
        --output text > /app-key.pem
    
    chmod 400 /app-key.pem
    echo "Key Pair criado: app-key"
else
    echo "Key Pair já existe: app-key"
fi

# Criar Elastic IP para a instância
echo "Criando Elastic IP..."
EIP_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 allocate-address \
    --domain vpc \
    --query 'AllocationId' \
    --output text)

echo "Elastic IP criado: $EIP_ID"

# Obter o IP público
PUBLIC_IP=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-addresses \
    --allocation-ids $EIP_ID \
    --query 'Addresses[0].PublicIp' \
    --output text)

echo "IP Público alocado: $PUBLIC_IP"

# Script de inicialização da instância
USER_DATA=$(cat << 'EOF'
#!/bin/bash
# Atualizar sistema
yum update -y

# Instalar Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Instalar Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Criar diretório da aplicação
mkdir -p /app
cd /app

# Criar docker-compose.yml para a aplicação
cat > docker-compose.yml << 'DOCKER_COMPOSE_EOF'
version: '3.8'
services:
  app:
    image: app:latest
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=dev
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
      - AWS_ENDPOINT_URL=http://host.docker.internal:4566
    restart: unless-stopped
DOCKER_COMPOSE_EOF

# Baixar e executar a aplicação
docker-compose up -d

# Configurar firewall
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

echo "Aplicação iniciada com sucesso!"
EOF
)

# Codificar User Data em base64
USER_DATA_B64=$(echo "$USER_DATA" | base64 -w 0)

# Criar instância EC2
echo "Criando instância EC2..."
echo "Usando:"
echo "- VPC: $VPC_ID"
echo "- Subnet: $SUBNET1_ID"
echo "- Security Group: $SG_ID"
echo "- Key Pair: app-key"

INSTANCE_ID=$(aws --endpoint-url=$ENDPOINT_URL ec2 run-instances \
    --image-id ami-12345678 \
    --count 1 \
    --instance-type t2.micro \
    --key-name app-key \
    --security-group-ids $SG_ID \
    --subnet-id $SUBNET1_ID \
    --user-data "$USER_DATA_B64" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Instância EC2 criada: $INSTANCE_ID"

# Aguardar a instância estar rodando
echo "Aguardando instância estar rodando..."
aws --endpoint-url=$ENDPOINT_URL ec2 wait instance-running \
    --instance-ids $INSTANCE_ID

# Associar Elastic IP à instância
echo "Associando Elastic IP à instância..."
aws --endpoint-url=$ENDPOINT_URL ec2 associate-address \
    --instance-id $INSTANCE_ID \
    --allocation-id $EIP_ID

# Aguardar um pouco mais para o User Data executar
echo "Aguardando inicialização da aplicação..."
sleep 30

# Verificar se o IP foi associado corretamente
echo "Verificando IP da instância..."
FINAL_IP=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

if [ "$FINAL_IP" = "None" ] || [ -z "$FINAL_IP" ]; then
    echo "Usando Elastic IP como fallback: $PUBLIC_IP"
    FINAL_IP=$PUBLIC_IP
fi

echo "Deploy da aplicação em EC2 concluído!"
echo "Recursos criados:"
echo "- VPC: $VPC_ID"
echo "- Subnet: $SUBNET1_ID"
echo "- Security Group: $SG_ID"
echo "- Internet Gateway: $IGW_ID"
echo "- Route Table: $ROUTE_TABLE_ID"
echo "- Key Pair: app-key"
echo "- Elastic IP: $EIP_ID"
echo "- Instância EC2: $INSTANCE_ID"
echo "- IP Público: $FINAL_IP"
echo ""
echo "A aplicação está sendo executada em: http://$FINAL_IP:8080"
echo ""
echo "Para testar a aplicação:"
echo "curl http://$FINAL_IP:8080/actuator/health"
echo "curl -X POST http://$FINAL_IP:8080/v1/validar/Jwt/seu_token_jwt -H 'Content-Type: application/json'"
echo ""
echo "Para acessar a instância via SSH:"
echo "ssh -i app-key.pem ec2-user@$FINAL_IP" 