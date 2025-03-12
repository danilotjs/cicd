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

  backend "s3" {
      bucket         = "terraform-fullstate"
      key            = "devops.tfstate"
      region         = "us-east-1"
      encrypt        = "true"
      role_arn        = "arn:aws:iam::361769602634:role/terraform-tfstate-s3"
  }
}

provider "aws" {
  region  = var.aws_region
}