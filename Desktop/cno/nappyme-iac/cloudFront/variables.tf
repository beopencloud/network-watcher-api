variable "bucket_name" {
  description = "The name of the bucket S3"
  type = string
}

variable "aws_region" {
  description = "The name of the region"
  type = string
}

variable "environment" {
  description = "The environment name"
  type = string
}

variable "waf_name" {
  description = "The WAF name"
  type = string
}

variable "scope" {
  description = "The scope value"
  type = string
}