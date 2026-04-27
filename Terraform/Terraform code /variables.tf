
#Common Variables 

variable "region" {
  description = "AWS region to deploy the resources in"
  type        = string
}

variable "environment" {
  description = "Environment tag (dev/qa/prod)"
  type        = string
}

#VPC 

variable "vpc_conf" {
  description = <<-EOT
    VPC and subnet configuration for multi-tier architecture:
    - vpc.cidr_vpc: VPC CIDR block (e.g., 10.0.0.0/16)
    - subnets.public_subnets.cidr: Public tier CIDR blocks (internet-facing)
    - subnets.private_app_subnets.cidr: Application tier CIDR blocks (ECS, Kafka, ElastiCache)
    - subnets.private_db_subnets.cidr: Database tier CIDR blocks (RDS)
    - Additional tags for resource identification and cost allocation
  EOT
  type        = any
}

#S3 

variable "bucket_name" {
  description = "S3 bucket name suffix"
  type        = string
}

#ECR 

variable "repo_name" {
  description = "ECR repository name"
  type        = string
}

#Kafka 

variable "kafka_ami" {
  description = "AMI ID for Kafka EC2"
  type        = string
}

#RDS 

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true   # 🔥 IMPORTANT
}

#Elasticache 

variable "memcached_node_type" {
  description = "Memcached node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "memcached_nodes" {
  description = "Number of memcached nodes"
  type        = number
  default     = 1
}