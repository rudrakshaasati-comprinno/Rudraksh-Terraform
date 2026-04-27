resource "aws_instance" "kafka" {
  ami           = var.ami
  instance_type = "t3.small"

  subnet_id              = var.private_app_subnet_ids[0]
  vpc_security_group_ids = [var.kafka_sg_id]

 
  tags = {
    Name        = "${var.environment}-kafka"
    Environment = var.environment
  }
}