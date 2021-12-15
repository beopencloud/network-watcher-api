variable "cluster_id" {
  type = string
  description = "Put the cluster in here"
}
variable "region" {
  type = string
  description = "cluster name"
}


variable "cluster_name" {
  type = string
  description = "cluster name"
}



variable "vpc_name" {
  description = "vpc name"
  type = string
}


variable "environment" {
  description   = "tag environment"
  type          = string
}

