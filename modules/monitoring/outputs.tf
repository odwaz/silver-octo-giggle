output "grafana_service" {
  description = "Grafana service name for port-forwarding"
  value       = "kube-prometheus-stack-grafana"
}

output "prometheus_service" {
  description = "Prometheus service name for port-forwarding"
  value       = "kube-prometheus-stack-prometheus"
}

output "namespace" {
  description = "Namespace where monitoring is deployed"
  value       = var.namespace
}
