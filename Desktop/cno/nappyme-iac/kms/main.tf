provider "aws" {
  region                 = var.aws_region
}

resource "aws_kms_key" "key" {
  description             = var.description
  key_usage               = "ENCRYPT_DECRYPT"
  policy                  = var.key_policy
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  is_enabled              = true
  tags = {
     Name = "kms-nappyme-${var.environment}"
  }
}

resource "aws_kms_alias" "key_alias" {
  name                    = "alias/${var.alias_name}"
  target_key_id           = aws_kms_key.key.id
}