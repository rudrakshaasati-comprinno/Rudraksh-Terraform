output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb_sg.id
}

output "ecs_sg_id" {
  description = "ECS Security Group ID"
  value       = aws_security_group.ecs_sg.id
}

output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}

output "memcached_sg_id" {
  description = "Memcached Security Group ID"
  value       = aws_security_group.memcached_sg.id
}

output "kafka_sg_id" {
  description = "Kafka Security Group ID"
  value       = aws_security_group.kafka_sg.id
}