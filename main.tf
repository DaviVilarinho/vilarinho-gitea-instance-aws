terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.15.1"
    }
  }

  backend "s3" {
    bucket = "vilarinho-state"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1" 

  default_tags {
    tags = {
      Application = "gitea"
      Group = "terraform-managed"
    }
  }
}

locals {
  website = "vilarinho.click" 
  compose_path = "assets/docker-compose.yml"
  app_ini_path = "assets/app.ini"
}

resource "tls_private_key" "gitea_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "gitea" {
  key_name   = "gitea-instance-key"
  public_key = tls_private_key.gitea_key.public_key_openssh
}
