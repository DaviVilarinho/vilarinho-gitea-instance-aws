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
  s3_path_to_gitea = "gitea/"
}
