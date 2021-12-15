variable "environment" {
  description = "The environment"
  type = string
}

variable "bucket_name" {
  description = "The name of The Bucket S3"
  type = string
}

variable "acl" {
  description = "The ACL name"
  type = string
}
variable "aws_region" {
  description = "The Region"
  type = string
}