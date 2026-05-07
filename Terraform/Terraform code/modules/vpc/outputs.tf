# VPC Outputs

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnets_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_app_subnets_ids" {
  description = "Application subnet IDs"
  value       = aws_subnet.app[*].id
}

output "private_db_subnets_ids" {
  description = "Database subnet IDs"
  value       = aws_subnet.db[*].id
}
