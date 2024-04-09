resource "aws_ecr_repository" "backend" {
  for_each = { for service_name in var.service_names : service_name => service_name }

  name = "${join("/", split("-", var.label))}/backend/${each.value}"
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_ecr_lifecycle_policy" "backend" {
  for_each   = aws_ecr_repository.backend
  repository = each.value.name
  policy = jsonencode({
    "rules" = [
      {
        "rulePriority" = 1
        "description"  = "Expire images older than 7 days"
        "selection" = {
          "tagStatus"   = "untagged"
          "countType"   = "sinceImagePushed"
          "countUnit"   = "days"
          "countNumber" = 7
        }
        "action" = {
          "type" = "expire"
        }
      },
    ]
  })
}
