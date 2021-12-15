variable "domain_name" {
  type        = string
  description = "The Domain name"
}
variable "environment" {
  type        = string
  description = "Environment this Route 53 zone belongs to"
}

variable "aws_region" {
  type        = string
  description = "The aws region "
}