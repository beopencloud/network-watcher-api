provider "aws" {
    region = var.aws_region
}

resource "aws_ecr_repository" "ecr_repository" {
  name                  = var.repository_name
  image_tag_mutability  = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push        = var.scan_on_push
  }
  tags = {
    "Name" = "registry-nappyme-${var.environment}"
  }
}

resource "aws_ecr_repository_policy" "ecr_repository_policy" {
 repository = aws_ecr_repository.ecr_repository.name
 policy = var.repository_policy
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name
  policy = var.lifecycle_policy
}