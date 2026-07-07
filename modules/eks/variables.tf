variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster is deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.29"
}

variable "fargate_namespaces" {
  description = "Namespaces to create Fargate profiles for"
  type        = list(string)
  default     = ["default", "kube-system", "gimba-services", "kafka", "monitoring"]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
