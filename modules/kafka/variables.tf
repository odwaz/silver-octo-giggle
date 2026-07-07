variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name for Helm provider"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Kafka"
  type        = string
  default     = "kafka"
}

variable "replicas" {
  description = "Number of Kafka brokers"
  type        = number
  default     = 3
}

variable "storage_size" {
  description = "Storage per broker (e.g. 10Gi, 100Gi)"
  type        = string
  default     = "10Gi"
}

variable "storage_class" {
  description = "Kubernetes storage class for persistent volumes"
  type        = string
  default     = "gp2"
}

variable "use_persistent_storage" {
  description = "Use persistent storage (true for prod, false for dev/ephemeral)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
