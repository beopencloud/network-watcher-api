variable "domain_name" {
  description   = "Domain name the certificate is issued for"
  type          = string
}

variable "environment" {
  description = "Free form description of this ACM certificate"
  type        = string
}

variable "region" {
  description = "Region Aws Certificate Manager"
  type = string
}