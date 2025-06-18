variable "app_name" {
  description = "Nome da aplicação"
  type        = string
  default     = "desafio-itau"
}

variable "environment" {
  description = "Ambiente (dev, prod, etc)"
  type        = string
  default     = "dev"
}

variable "container_port" {
  description = "Porta do container"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU units para o container"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memória para o container em MB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Número desejado de instâncias"
  type        = number
  default     = 3
}

variable "availability_zones" {
  description = "Lista de zonas de disponibilidade"
  type        = list(string)
  default     = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
}

variable "deployment_maximum_percent" {
  description = "Percentual máximo de deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Percentual mínimo saudável durante deployment"
  type        = number
  default     = 100
}

variable "image_tag" {
  description = "Tag da imagem Docker para deploy"
  type        = string
  default     = "latest"
} 