
variable "token_creation" {
  description = "Toke used to create secret"
  type = string
}
variable "environment" {
  description = "Refernce token"
  type = string
}

variable "region" {
  description = "Region EFS"
  type = string
}
 
variable "cluster_name" {
  description  = "The cluster name"
  type = string
}

variable "cluster_id" {
  description  = "The cluster ID"
  type = string
}

variable "vpc_name" {
  description  = "The vpc name"
  type = string
}


