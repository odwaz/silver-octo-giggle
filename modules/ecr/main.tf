locals {
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_ecr_repository" "services" {
  for_each = toset(var.repository_names)

  name                 = "${var.project}/${each.value}"
  image_tag_mutability = "MUTABLE"
  force_delete         = var.environment == "dev"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, { Service = each.value })
}

resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = toset(var.repository_names)
  repository = aws_ecr_repository.services[each.value].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Retain last ${var.image_retention_count} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.image_retention_count
      }
      action = { type = "expire" }
    }]
  })
}
