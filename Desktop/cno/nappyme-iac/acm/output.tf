output "acm_certificate_arn" {
    description = "arn of certificate"
    value       = aws_acm_certificate.certificate.arn
}

/*
output "acm_certificate_dns_validataion_record" {
  description  = "record which is used to validate acm certification"
  value        = aws_route53_record.this[var.domain_name].name
}
*/