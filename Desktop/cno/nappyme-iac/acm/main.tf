
provider "aws" {
    region = var.region
}
resource "aws_acm_certificate" "certificate" {
  domain_name       = var.domain_name
  validation_method = "EMAIL"
  tags = {
    "Name" = "${var.environment}-acm-nappyme-certificate"
  }
}


resource "aws_acm_certificate_validation" "valid_cert" {
  certificate_arn         = aws_acm_certificate.certificate.arn
}

