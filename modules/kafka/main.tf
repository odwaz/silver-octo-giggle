locals {
  strimzi_version = "0.39.0"
}

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------

resource "kubernetes_namespace" "kafka" {
  metadata {
    name = var.namespace
    labels = {
      project     = var.project
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

# -----------------------------------------------------------------------------
# Strimzi Kafka Operator (Helm)
# -----------------------------------------------------------------------------

resource "helm_release" "strimzi_operator" {
  name       = "strimzi-kafka-operator"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  version    = local.strimzi_version
  namespace  = kubernetes_namespace.kafka.metadata[0].name

  set {
    name  = "watchNamespaces"
    value = "{${var.namespace}}"
  }

  wait = true
}

# -----------------------------------------------------------------------------
# Kafka Cluster (KRaft mode — no ZooKeeper)
# -----------------------------------------------------------------------------

resource "kubernetes_manifest" "kafka_cluster" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"
    metadata = {
      name      = "${var.project}-kafka"
      namespace = var.namespace
    }
    spec = {
      kafka = {
        version  = "3.7.0"
        replicas = var.replicas
        listeners = [
          {
            name = "plain"
            port = 9092
            type = "internal"
            tls  = false
          },
          {
            name = "tls"
            port = 9093
            type = "internal"
            tls  = true
          }
        ]
        config = {
          "offsets.topic.replication.factor"         = min(var.replicas, 3)
          "transaction.state.log.replication.factor" = min(var.replicas, 3)
          "transaction.state.log.min.isr"            = min(var.replicas, 2)
          "default.replication.factor"               = min(var.replicas, 3)
          "min.insync.replicas"                      = min(var.replicas, 2)
          "log.retention.hours"                      = 168
        }
        storage = var.use_persistent_storage ? {
          type = "persistent-claim"
          size = var.storage_size
          class = var.storage_class
          deleteClaim = false
        } : {
          type = "ephemeral"
        }
      }
      # KRaft mode — controller replaces ZooKeeper
      kraft = {
        replicas = var.replicas
        storage = var.use_persistent_storage ? {
          type = "persistent-claim"
          size = "5Gi"
          class = var.storage_class
          deleteClaim = false
        } : {
          type = "ephemeral"
        }
      }
    }
  }

  depends_on = [helm_release.strimzi_operator]
}
