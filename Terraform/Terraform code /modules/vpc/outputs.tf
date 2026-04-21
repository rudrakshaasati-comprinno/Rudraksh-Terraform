//============= Define and expose values or data produced by the resources using output =============//

output "vpc_id" {
	value = aws_vpc.vpc.id
}

output "public_subnets" {
	value = aws_subnet.public_subnets[*]
}

output "public_subnets_ids" {
	value = aws_subnet.public_subnets[*].id
}

output "private_app_subnets" {
  value = aws_subnet.private_app_subnets[*]
}

output "private_app_subnets_ids" {
	value = aws_subnet.private_app_subnets[*].id
}

output "private_db_subnets" {
  value = aws_subnet.private_db_subnets[*]
}

output "private_db_subnets_ids" {
	value = aws_subnet.private_db_subnets[*].id
}