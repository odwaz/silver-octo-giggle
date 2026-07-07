terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }

  # backend "s3" {
  #   bucket         = "gimba-terraform-state"
  #   key            = "environments/dev/terraform.tfstate"
  #   region         = "af-south-1"
  #   dynamodb_table = "gimba-terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  services = {
    reactive-wallet = { repo = "odwaz/reactive-wallet", branch = "main" }
    real-time-cdp   = { repo = "odwaz/real-time-cdp", branch = "main" }
    sme-directory   = { repo = "odwaz/sme_directory", branch = "master" }
  }
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------

module "networking" {
  source = "../../modules/networking"

  project            = var.project
  environment        = var.environment
  region             = var.region
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = local.azs
  enable_nat_ha      = false # Single NAT for dev
}

# -----------------------------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------------------------

module "eks" {
  source = "../../modules/eks"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  kubernetes_version = "1.29"

  fargate_namespaces = ["default", "kube-system", "gimba-services", "kafka", "monitoring"]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# -----------------------------------------------------------------------------
# RDS PostgreSQL
# -----------------------------------------------------------------------------

module "rds" {
  source = "../../modules/rds"

  project            = var.project
  environment        = var.environment
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id  = module.networking.rds_security_group_id

  instance_class = "db.t3.micro"
  db_name        = "gimba"
  db_username    = "gimba_admin"
  db_password    = var.db_password
  multi_az       = false
}

# -----------------------------------------------------------------------------
# ECR Repositories
# -----------------------------------------------------------------------------

module "ecr" {
  source = "../../modules/ecr"

  project          = var.project
  environment      = var.environment
  repository_names = keys(local.services)
}

# -----------------------------------------------------------------------------
# Kafka (Strimzi on EKS)
# -----------------------------------------------------------------------------

module "kafka" {
  source = "../../modules/kafka"

  project                = var.project
  environment            = var.environment
  cluster_name           = module.eks.cluster_name
  replicas               = 1 # Single broker for dev
  use_persistent_storage = false

  depends_on = [module.eks]
}

# -----------------------------------------------------------------------------
# Monitoring (Prometheus + Grafana)
# -----------------------------------------------------------------------------

module "monitoring" {
  source = "../../modules/monitoring"

  project                = var.project
  environment            = var.environment
  grafana_admin_password = var.grafana_admin_password

  depends_on = [module.eks]
}

# -----------------------------------------------------------------------------
# CI/CD Pipelines (one per service)
# -----------------------------------------------------------------------------

module "pipeline_wallet" {
  source = "../../modules/pipeline"

  project                 = var.project
  environment             = var.environment
  service_name            = "reactive-wallet"
  github_repo             = local.services["reactive-wallet"].repo
  github_branch           = local.services["reactive-wallet"].branch
  ecr_repo_url            = module.ecr.repository_urls["reactive-wallet"]
  codestar_connection_arn = var.codestar_connection_arn
}

module "pipeline_cdp" {
  source = "../../modules/pipeline"

  project                 = var.project
  environment             = var.environment
  service_name            = "real-time-cdp"
  github_repo             = local.services["real-time-cdp"].repo
  github_branch           = local.services["real-time-cdp"].branch
  ecr_repo_url            = module.ecr.repository_urls["real-time-cdp"]
  codestar_connection_arn = var.codestar_connection_arn
}

module "pipeline_sme" {
  source = "../../modules/pipeline"

  project                 = var.project
  environment             = var.environment
  service_name            = "sme-directory"
  github_repo             = local.services["sme-directory"].repo
  github_branch           = local.services["sme-directory"].branch
  ecr_repo_url            = module.ecr.repository_urls["sme-directory"]
  codestar_connection_arn = var.codestar_connection_arn
}
