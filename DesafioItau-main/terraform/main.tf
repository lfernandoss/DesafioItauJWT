terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
  
  # Configuração para LocalStack
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style          = true

  endpoints {
    ec2     = "http://localhost:4566"
    ecs     = "http://localhost:4566"
    elbv2   = "http://localhost:4566"
    iam     = "http://localhost:4566"
    logs    = "http://localhost:4566"
  }
} 