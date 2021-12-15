variable "repository_name" {
  description   = "repository name"
  type          = string
}

variable "aws_region" {
  description   = "Region name"
  type          = string
}

variable "image_tag_mutability" {
  description   = "The tags mutability settings for the repository. Must be one of : `MUTABLE` or `IMMUTABLE` "
  type          = string
}

variable "scan_on_push" {
  description   = "Indicates whether images are scanned after being push the the repository"
  type          = bool
}

variable "repository_policy" {
  description   = "The acces policy of the repository"
  type          = string
  default       = ""
}

variable "lifecycle_policy" {
  description   = "The lifecycle policy of the repository"
  type          = string
  default       = ""
}

variable "environment" {
  description = "The Environment "
  type = string
}