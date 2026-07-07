variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
}

variable "domain_name" {
  description = "Root domain name (e.g. gimba.co.za)"
  type        = string
}

variable "create_zone" {
  description = "Whether to create a new hosted zone (false if zone already exists)"
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "Existing Route 53 zone ID (required if create_zone = false)"
  type        = string
  default     = ""
}

variable "alb_dns_name" {
  description = "ALB DNS name for the A record alias"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB hosted zone ID for the alias target"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
