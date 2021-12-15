variable "name" {
  description  = "A friendly name of the WebACL"
  type         = string
}

variable "scope" {
  description  = "Whether this is for an AWS CloudFront distribution or Region application"
  type         = string
}

variable "description" {
  description  = "WAF description"
  type         = string
}

variable "cloudwatch_metrics_enabled" {
  description  = "cloudWatch metric"
  type         = bool
  default      = false
}


variable "sampled_requests_enabled" {
  description  = "request sampled"
  type         = bool
  default      = false
}

variable "name_rule_ddos" {
  description  = "DDOS rule name"
  type         = string
  default      = "ddos_rule"
}

variable "priority_ddos" {
  description  = "priority DDOS rule"
  type         = number
  default      = 10
}

variable "limit_request" {
  description  = "Number of request with the same IP in 5mn"
  type         = number
  default      = 10000
}
variable "aggregate_key_type" {
  description  = "Type of Aggregate"
  type         = string
  default      = "IP"
}
variable "name_rule_sql_injection" {
  description  = "Sql injection rule name"
  type         = string
  default      = "sql_injection_rule"
}
variable "priority_sql_injection" {
  description  = "priority SQL injection rule"
  type         = number
  default      = 20
}
variable "prioriry_text_transformation_sql_injection" {
  description  = "SQL injection priority text transformation"
  type         = number
  default      = 5
}

variable "type_text_transformation_sql_injection" {
  description  = "SQL injection text transformation"
  type         = string
  default      = "NONE"
}

variable "name_rule_xss" {
  description  = "XSS rule name"
  type         = string
  default      = "xss_rule"
}
variable "priority_xss" {
  description  = "priority XSS rule"
  type         = number
  default      = 30
}
variable "prioriry_text_transformation_xss" {
  description  = "SQL injection priority text transformation"
  type         = number
  default      = 10
}

variable "type_text_transformation_xss" {
  description  = "XSS text transformation"
  type         = string
  default      = "NONE"
}

variable "aws_region" {
  description = "Region waf"
  type = string
}

