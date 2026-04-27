# VPC Module Variables
# Configures network infrastructure with multi-tier subnet architecture

variable "region" {
  type        = string
  description = "AWS region for VPC deployment. Example: us-east-1, us-west-2"
}

variable "environment" {
  type        = string
  description = "Deployment environment identifier. Values: dev, staging, production"
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "vpc_conf" {
  type        = any
  description = <<-EOT
    Network configuration object containing:
    - vpc.cidr_vpc: VPC CIDR block (e.g., 10.0.0.0/16)
    - subnets.public_subnets.cidr: List of public subnet CIDR blocks
    - subnets.private_app_subnets.cidr: List of application layer subnet CIDR blocks
    - subnets.private_db_subnets.cidr: List of database layer subnet CIDR blocks
    - nat_gateway.additional_tags: Custom tags for NAT gateway
    - vpc.additional_tags: Custom tags for VPC resources
  EOT
}