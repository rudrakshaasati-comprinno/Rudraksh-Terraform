
# =========================================================
# ECR REPOSITORY
# =========================================================
resource "aws_ecr_repository" "repo" {
  name = "${var.environment}-${var.repo_name}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.environment}-ecr"
    Environment = var.environment
  }
}

