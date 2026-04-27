# VPC Outputs
# Exports VPC and subnet identifiers for use by dependent modules

output "vpc_id" {
	description = "The ID of the created VPC"
	value = aws_vpc.rudra_vpc.id
}

output "public_subnets" {
	description = "Complete public tier subnet objects"
	value = aws_subnet.public_tier_subnets[*]
}

output "public_subnets_ids" {
	description = "List of public tier subnet IDs for ALB deployment"
	value = aws_subnet.public_tier_subnets[*].id
}

output "private_app_subnets" {
  description = "Complete application layer subnet objects"
  value = aws_subnet.app_layer_subnets[*]
}

output "private_app_subnets_ids" {
	description = "List of application layer subnet IDs for ECS, Kafka, and ElastiCache deployment"
	value = aws_subnet.app_layer_subnets[*].id
}

output "private_db_subnets" {
  description = "Complete database layer subnet objects"
  value = aws_subnet.database_layer_subnets[*]
}

output "private_db_subnets_ids" {
	description = "List of database layer subnet IDs for RDS deployment"
	value = aws_subnet.database_layer_subnets[*].id
}