# Terraform State File #
# Private S3 storage #
terraform {
  backend "s3" {
    bucket = "rocky-terraform"
    key = "terraform.tfstate"
    region = "us-east-1"
    profile = "skillstorm"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }
}
provider "aws" {
  # profile = "skillstorm"
  region  = "us-east-1"
}

