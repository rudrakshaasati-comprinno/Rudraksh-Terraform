
# =========================================================
# KMS KEY
# =========================================================
resource "aws_kms_key" "kms" {
  description             = "${var.environment}-kms-key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "${var.environment}-kms-key"
    Environment = var.environment
  }
}

# =========================================================
# KMS ALIAS
# =========================================================
resource "aws_kms_alias" "alias" {
  name          = "alias/${var.environment}-kms"
  target_key_id = aws_kms_key.kms.id
}

