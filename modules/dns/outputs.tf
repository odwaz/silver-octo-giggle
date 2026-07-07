output "certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "zone_id" {
  description = "Route 53 hosted zone ID"
  value       = local.zone_id
}

output "nameservers" {
  description = "Nameservers (only populated if zone was created)"
  value       = var.create_zone ? aws_route53_zone.main[0].name_servers : []
}
