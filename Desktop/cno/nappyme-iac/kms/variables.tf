variable "description" {
  description   = "The description of the KMS Key"
  type          = string
  default       = "The kms used to encrypt the database"
}

variable "aws_region" {
  description   = "The Region"
  type          = string
}

variable "key_policy" {
  description   = "The policy of the Key Usage"
  type          = string
  default       = ""
}

variable "deletion_window_in_days" {
  description   = "The duration in days after which the key is deleted after descruction of resources"
  type          = number
}

variable "environment" {
  description   = "The environment this Key belongs to"
  type          = string
}

variable "alias_name" {
  description   = "The name of the Key alias"
  type          = string
}