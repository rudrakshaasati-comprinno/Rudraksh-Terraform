output "rds_endpoint" {
  value = aws_db_instance.rds.address
}

output "rds_port" {
  value = aws_db_instance.rds.port
}

output "rds_id" {
  value = aws_db_instance.rds.id
}