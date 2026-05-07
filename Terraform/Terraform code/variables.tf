
# Common Variables

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "repo_name" {
  description = "ECR repository name"
  type        = string
}

variable "kafka_ami" {
  description = "AMI ID for Kafka EC2"
  type        = string
}

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
  sensitive   = true
}

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
