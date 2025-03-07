# ---------------------------------------------------------------------------------------------------------------------
# AWS PROVIDER FOR TF CLOUD
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" 
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  region  = var.aws_region
  access_key = var.aws_cicd_deployment_access_key
  secret_key = var.aws_cicd_deployment_secret_key
}