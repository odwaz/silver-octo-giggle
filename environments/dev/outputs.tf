output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "RDS connection endpoint"
  value       = module.rds.endpoint
}

output "ecr_repositories" {
  description = "ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "kafka_bootstrap" {
  description = "Kafka bootstrap servers"
  value       = module.kafka.bootstrap_servers
}

output "grafana_service" {
  description = "Grafana service for port-forward"
  value       = module.monitoring.grafana_service
}
