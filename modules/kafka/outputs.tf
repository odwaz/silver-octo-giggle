output "bootstrap_servers" {
  description = "Kafka bootstrap servers address (internal to cluster)"
  value       = "${var.project}-kafka-kafka-bootstrap.${var.namespace}.svc.cluster.local:9092"
}

output "bootstrap_servers_tls" {
  description = "Kafka bootstrap servers address (TLS)"
  value       = "${var.project}-kafka-kafka-bootstrap.${var.namespace}.svc.cluster.local:9093"
}

output "namespace" {
  description = "Namespace where Kafka is deployed"
  value       = var.namespace
}
