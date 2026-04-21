variable "environment" {
  type        = string
  description = "Environment name (dev/qa/prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
}