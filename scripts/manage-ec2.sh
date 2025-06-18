#!/bin/sh

# Script para gerenciar instância EC2

show_help() {
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  status     - Mostrar status da instância"
    echo "  logs       - Mostrar logs da aplicação"
    echo "  restart    - Reiniciar a aplicação"
    echo "  stop       - Parar a instância"
    echo "  start      - Iniciar a instância"
    echo "  delete     - Deletar a instância"
    echo "  test       - Testar a aplicação"
    echo "  help       - Mostrar esta ajuda"
}

get_instance_id() {
    aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[0].Instances[0].InstanceId' \
        --output text
}

get_public_ip() {
    # Tentar obter Elastic IP primeiro
    PUBLIC_IP=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-addresses \
        --query 'Addresses[0].PublicIp' \
        --output text)
    
    if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "None" ]; then
        # Tentar obter IP público da instância
        PUBLIC_IP=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
            --instance-ids $(get_instance_id) \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
    fi
    
    if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "None" ]; then
        # Usar IP privado como fallback
        PUBLIC_IP=$(aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
            --instance-ids $(get_instance_id) \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
    fi
    
    echo $PUBLIC_IP
}

case "$1" in
    "status")
        echo "Status da instância EC2:"
        aws --endpoint-url=$ENDPOINT_URL ec2 describe-instances \
            --instance-ids $(get_instance_id) \
            --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress,PrivateIpAddress,LaunchTime]' \
            --output table
        
        echo ""
        echo "Elastic IPs:"
        aws --endpoint-url=$ENDPOINT_URL ec2 describe-addresses \
            --query 'Addresses[].[AllocationId,PublicIp,InstanceId]' \
            --output table
        ;;
    
    "logs")
        INSTANCE_ID=$(get_instance_id)
        PUBLIC_IP=$(get_public_ip)
        echo "Logs da aplicação na instância $INSTANCE_ID ($PUBLIC_IP):"
        echo "Executando: docker logs app-container"
        ssh -i /app-key.pem -o StrictHostKeyChecking=no ec2-user@$PUBLIC_IP "docker logs app-container"
        ;;
    
    "restart")
        INSTANCE_ID=$(get_instance_id)
        PUBLIC_IP=$(get_public_ip)
        echo "Reiniciando aplicação na instância $INSTANCE_ID ($PUBLIC_IP):"
        ssh -i /app-key.pem -o StrictHostKeyChecking=no ec2-user@$PUBLIC_IP "cd /app && docker-compose restart"
        ;;
    
    "stop")
        INSTANCE_ID=$(get_instance_id)
        echo "Parando instância $INSTANCE_ID:"
        aws --endpoint-url=$ENDPOINT_URL ec2 stop-instances --instance-ids $INSTANCE_ID
        ;;
    
    "start")
        INSTANCE_ID=$(get_instance_id)
        echo "Iniciando instância $INSTANCE_ID:"
        aws --endpoint-url=$ENDPOINT_URL ec2 start-instances --instance-ids $INSTANCE_ID
        ;;
    
    "delete")
        INSTANCE_ID=$(get_instance_id)
        echo "Deletando instância $INSTANCE_ID:"
        aws --endpoint-url=$ENDPOINT_URL ec2 terminate-instances --instance-ids $INSTANCE_ID
        ;;
    
    "test")
        PUBLIC_IP=$(get_public_ip)
        echo "Testando aplicação em $PUBLIC_IP:8080"
        echo "Teste de conectividade:"
        curl -s -o /dev/null -w "Status: %{http_code}\n" http://$PUBLIC_IP:8080/actuator/health || echo "Aplicação não está respondendo"
        echo ""
        echo "Teste do endpoint JWT:"
        curl -X POST http://$PUBLIC_IP:8080/v1/validar/Jwt/teste -H "Content-Type: application/json" || echo "Endpoint não está respondendo"
        ;;
    
    "help"|*)
        show_help
        ;;
esac 