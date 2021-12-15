output "zone_id" {
  value       = aws_route53_zone.zone_public.zone_id
  description = "The hosted zone id"
}

output "name_server" {
  value       = aws_route53_zone.zone_public.name_servers
  description = "A list of name servers in associated delegation set"
}