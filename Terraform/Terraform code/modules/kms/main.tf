
# KMS KEY

resource "aws_kms_key" "kms" {
  description             = "App KMS Key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name = "app-kms-key"
  }
}

resource "aws_kms_alias" "alias" {
  name          = "alias/app-kms"
  target_key_id = aws_kms_key.kms.id
}

