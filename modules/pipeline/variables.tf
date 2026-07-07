variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
}

variable "service_name" {
  description = "Name of the service this pipeline deploys"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository (org/repo format)"
  type        = string
}

variable "github_branch" {
  description = "Branch to trigger pipeline"
  type        = string
  default     = "main"
}

variable "ecr_repo_url" {
  description = "ECR repository URL for pushing images"
  type        = string
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection to GitHub"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
