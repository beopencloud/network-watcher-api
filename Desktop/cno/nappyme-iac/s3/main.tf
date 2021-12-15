provider "aws" {
    region = var.aws_region
}
resource "aws_s3_bucket" "nappyme_bucket" {
  bucket = var.bucket_name
  acl = var.acl
  tags = {
    "Name" = "${var.environment}-nappyme-s3"
  }
}

resource "aws_s3_bucket_policy" "policy_nappyme" {
  bucket = aws_s3_bucket.nappyme_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "Allow"
        Effect    = "Allow"
        Principal = "*"
        "Action": [
        "s3:GetObject"
      ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.nappyme_bucket.id}/*"
      },
    ]
  })
}

