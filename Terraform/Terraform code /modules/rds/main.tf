# =========================================================
# DB SUBNET GROUP
# =========================================================
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# =========================================================
# PARAMETER GROUP (OPTIONAL BUT GOOD PRACTICE)
# =========================================================
resource "aws_db_parameter_group" "mysql" {
  name   = "${var.environment}-mysql-param"
  family = "mysql8.4"

  parameter {
    name  = "time_zone"
    value = "Asia/Calcutta"
  }
}

# =========================================================
# RDS INSTANCE
# =========================================================
resource "aws_db_instance" "rds" {
  identifier = "${var.environment}-rds"

  engine         = "mysql"


  instance_class    = var.instance_class
  allocated_storage = 20

  db_name  = var.db_name
  username = var.username
  password = var.password

  port = 3306

  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.mysql.name

  publicly_accessible = false

  multi_az = false
  storage_encrypted = true
  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name        = "${var.environment}-rds"
    Environment = var.environment
  }
}