# Terraform Configuration for Travion Infrastructure
# Optional - use for cloud deployments (AWS/GCP/Azure)

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "travion-terraform-state"
    key    = "infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# Example: EC2 instance for VPS
resource "aws_instance" "travion_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name        = "travion-server"
    Environment = var.environment
  }

  user_data = file("${path.module}/../scripts/setup_vps.sh")
}

# Example: RDS for MongoDB (or use DocumentDB)
# resource "aws_db_instance" "mongodb" {
#   ...
# }
