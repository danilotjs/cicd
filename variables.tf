# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "stack" {
  description = "Nome da stack"
  default     = "devops"
}

variable "vpc_cidr" {
  description = "CIDR para a VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Valores CIDR da Subnet Publica"
  default     = ["10.0.0.0/20"] 
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Valores CIDR da Subnet Privada"
  default     = ["10.0.128.0/20"] 
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a"]
}