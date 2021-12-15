variable "identifier" {
    type = string
    description = ""
}
variable "engine" {
    type = string
    description = "value"
}

variable "engine_version" {
    type = string
    description = "value"
}

variable "instance_class" {
    type = string
    description = "value"
}

variable "allocated_storage" {
    type = number
    description = "value"
}

variable "name" {
    type = string
    description = "value"
}


variable "db_subnet_group_name" {
    type = string
    description = "value"
}

variable "parameter_group_name" {
    type = string
    description = "value"
}

variable "skip_final_snapshot" {
    type = bool
    description = "value"
}

variable "deletion_protection" {
    type = bool
    description = "value"
  
}

variable "aws_region" {
    type = string
    description = "value"
}


variable "tags" {
    type = map
    description = "value"
}

variable "kms_key_id" {
    type = string
    description = "value"
}

variable "environment" {
    type = string
    description = "value"
}
variable "rds_sg" {
    type = string
    description = "value"
}
variable "rds_port" {
    type = string
    description = "value"
}

variable "storage_type" {
    type = string
    description = "value"
}
variable "vpc_name" {
    type = string
    description = "value"
}

variable "cluster_id" {
    type = string
    description = "value"
}
variable "cluster_name" {
    type = string
    description = "value"
}
variable "username" {
    type = string
    description = "value"
}
variable "password" {
    type = string
    description = "value"
}