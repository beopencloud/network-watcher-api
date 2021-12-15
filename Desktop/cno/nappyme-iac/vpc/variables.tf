
variable "vpc_name" {
  description = "vpc name"
  type = string
}
variable "cidr_block_vpc" {
  description   = "cidr block ip"
  type          = string
}

variable "public_subnets_eks_1" {
  description = "public_subnets_eks_1"
  type = list(string)
}

variable "public_subnets_eks_2" {
  description = "public_subnets_eks_2"
  type = list(string)
}

variable "private_subnets_eks_1" {
  description = "private_subnets_cidr_az0"
  type = list(string)
}

variable "private_subnets_eks_2" {
  description = "private_subnets_cidr_az1"
  type        = list(string)
}

variable "private_subnets_rds_1" {
  description = "private_subnets_cidr_az1"
  type        = list(string)
}
variable "private_subnets_rds_2" {
  description = "private_subnets_cidr_az1"
  type        = list(string)
}

variable "aws_region" {
  description = "The region"
  type = string
}


variable "cluster_name" {
  description   = "the cluster_name"
  type          = string
}

variable "environment" {
  description   = "tag environment"
  type          = string
}

variable "cidr_block-internet_gw" {
  description   = "cidr_block-internet_gw"
  type          = string
}

variable "availability_zones_0" {
  description = "availability_zones_0"
  type = list(string)
}

variable "availability_zones_1" {
  description = "availability_zones_1"
  type = list(string)
}

variable "cidr_block_nat_gw_az0" {
  description = "cidr_block_nat_gw_az0"
  type = string
}

variable "cidr_block_nat_gw_az1" {
  description = "cidr_block_nat_gw_az1"
  type = string
}
