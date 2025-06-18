output "alb_dns_name" {
  description = "DNS name do ALB"
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Nome do serviço ECS"
  value       = aws_ecs_service.app.name
}

output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "IDs das subnets"
  value       = aws_subnet.public[*].id
} 