# Platform Infrastructure

Terraform modules provisioning the AWS infrastructure for the Gimba platform — microservices running on EKS with PostgreSQL, Kafka (Strimzi), CI/CD pipelines, and observability.

## Services Deployed

| Service | Description | Port |
|---------|-------------|------|
| **reactive-wallet** | OAuth2 merchant wallet & payments API | 8000 |
| **real-time-cdp** | Event-driven Customer Data Platform (Kafka) | 8080 |
| **sme-directory** | SME trust & discovery platform | 8080 |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  AWS Account                                                     │
│                                                                   │
│  ┌─────────────┐    ┌──────────────────────────────────────────┐ │
│  │ Route 53    │───▶│  ALB (HTTPS, ACM cert)                   │ │
│  └─────────────┘    └────────────────┬─────────────────────────┘ │
│                                      │                            │
│  ┌───────────────────────────────────▼────────────────────────┐  │
│  │  EKS Cluster                                                │  │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │  │
│  │  │ wallet-api   │ │ cdp-engine   │ │ sme-directory│       │  │
│  │  │ (Fargate)    │ │ (Fargate)    │ │ (Fargate)    │       │  │
│  │  └──────────────┘ └──────────────┘ └──────────────┘       │  │
│  │  ┌──────────────────────────────────────────────────┐      │  │
│  │  │ Kafka (Strimzi operator)                          │      │  │
│  │  │ 3 brokers, KRaft mode                            │      │  │
│  │  └──────────────────────────────────────────────────┘      │  │
│  │  ┌──────────────────────────────────────────────────┐      │  │
│  │  │ Prometheus + Grafana (kube-prometheus-stack)       │      │  │
│  │  └──────────────────────────────────────────────────┘      │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐  │
│  │ RDS PostgreSQL   │  │ ECR (3 repos)    │  │ S3 (artifacts)│  │
│  │ Multi-AZ         │  │                  │  │               │  │
│  └──────────────────┘  └──────────────────┘  └───────────────┘  │
│                                                                   │
│  ┌──────────────────┐  ┌──────────────────┐                     │
│  │ CodePipeline     │  │ CloudWatch Logs  │                     │
│  │ (per service)    │  │                  │                     │
│  └──────────────────┘  └──────────────────┘                     │
└─────────────────────────────────────────────────────────────────┘
```

## Module Structure

```
.
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
├── modules/
│   ├── networking/        # VPC, subnets, NAT, security groups
│   ├── eks/               # EKS cluster + Fargate profiles
│   ├── rds/               # PostgreSQL Multi-AZ
│   ├── ecr/               # Container registries
│   ├── kafka/             # Strimzi operator + cluster via Helm
│   ├── monitoring/        # kube-prometheus-stack via Helm
│   ├── pipeline/          # CodePipeline + CodeBuild per service
│   └── dns/               # Route 53 + ACM certificates
├── .gitignore
├── backend.tf
├── providers.tf
└── README.md
```

## Usage

```bash
# Initialise (one-time)
cd environments/dev
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy (careful)
terraform destroy
```

## State Management

State is stored in S3 with DynamoDB locking:
- **Bucket:** `gimba-terraform-state-{account_id}`
- **Lock table:** `gimba-terraform-locks`
- **Key:** `environments/{env}/terraform.tfstate`

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.5
- kubectl
- Helm 3

## Environments

| Environment | Purpose | EKS Node Type | RDS Instance |
|-------------|---------|---------------|--------------|
| dev | Development & testing | Fargate | db.t3.micro |
| prod | Production | Fargate | db.r6g.large |
