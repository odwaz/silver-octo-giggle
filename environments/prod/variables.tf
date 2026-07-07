variable "region" {
  description = "AWS region"
  type        = string
  default     = "af-south-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "gimba"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection to GitHub"
  type        = string
}

variable "domain_name" {
  description = "Production domain name"
  type        = string
}
