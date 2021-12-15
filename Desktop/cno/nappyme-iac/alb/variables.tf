variable "lb_name" {
  description   = "The name of the ALB "
  type          = string
}

variable "lb_internal" {
  description   = "Whether the ALB will be public / private"
  type          = string
}

variable "load_balancer_type" {
  description   = "The LB type"
  type          = string
}

variable "lb_idle_timeout" {
  description   = "The ALB's idle timeout"
  type          = string
}

variable "lb_ip_address_type" {
  description   = "The ALB's ip address type"
  type          = string
}

variable "environment" {
  description   = "Will be used in resources environement tags"
  type          = string
}

variable "tg_name" {
  description   = "The default target group's name"
  type          = string
  default       = "alb_target"
}

variable "tg_port" {
  description   = "The default target group's port"
  type          = string
  default       = 5000
}
variable "tg_protocol" {
  description   = "The default target group's Protocol"
  type          = string
  default       = "HTTP"
}

variable "target_type" {
  description   = "Type of target that you must specify when registering targets with this target group"
  type          = string
  default       = "instance"
}

variable "ckeck_port" {
  description   = "Check port"
  type          = string
  default       = 80
}

variable "check_protocol" {
  description   = "Check Protocol"
  type          = string
  default       = "HTTP"
}

variable "aws_region" {
  description = "Tthe AWS Region"
  type = string
}

variable "vpc_name" {
  description = "The VPC name"
  type = string
}

variable "cluster_name" {
  description = "The ID of the Cluster"
  type = string
}

variable "path" {
  description = "The path for health check"
  type = string
}

variable "matcher" {
  description = "The matcher for health check"
  type = string
}

variable "listener_port" {
  description = "The listener_port for health check"
  type = number
}

variable "listener_protocol" {
  description = "The listener Protocol for health check"
  type = string
}