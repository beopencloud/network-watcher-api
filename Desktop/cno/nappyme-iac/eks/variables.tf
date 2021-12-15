variable "cluster_name" {
  description = "cluster name"
  type = string
}

variable "environment" {
  description = "Cluster environment"
  type = string
}

variable "fargate_namespace" {
    description = "Fargate Namespaces"
  type = string
}

variable "desired_size" {
  description = "desired number of nodes"
  type = number
}

variable "max_size" {
  description = "Max number of nodes"
  type = number
}

variable "min_size" {
  description = "Minimum number of nodes"
  type = number
}

variable "eks_node_group_instance_types" {
  description = "Type of node instances group"
  type = list(string)
}
variable "aws_region" {
  description = "Region"
  type = string
}

variable "vpc_name" {
  description = "VPC Name"
  type = string
}

variable "db_instance_identifier" {
  description = "VPC Name"
  type = string
}

variable "name" {
  description = "Rds Name"
  type = string
}