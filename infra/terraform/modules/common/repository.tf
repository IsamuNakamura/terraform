# 外部DBサービスを利用する場合、定期バックアップが取得できなければ、Lambdaを実行してバックアップを取得する
# そのため、LambdaのコードをECRに保存するためのリポジトリを作成する
# resource "aws_ecr_repository" "vercel_storage_backup" {
#   name = "${join("/", split("-", var.label))}/lambda/vercel-storage-backup"
#   encryption_configuration {
#     encryption_type = "KMS"
#     kms_key         = var.kms_key_arn
#   }
#   image_scanning_configuration {
#     scan_on_push = true
#   }

#   tags = merge(
#     var.tags,
#     {
#       Tier = var.tier,
#     }
#   )
# }

# resource "aws_ecr_lifecycle_policy" "vercel_storage_backup" {
#   repository = aws_ecr_repository.vercel_storage_backup.name
#   policy = jsonencode({
#     "rules" = [
#       {
#         "rulePriority" = 1
#         "description"  = "Expire images older than 7 days"
#         "selection" = {
#           "tagStatus"   = "untagged"
#           "countType"   = "sinceImagePushed"
#           "countUnit"   = "days"
#           "countNumber" = 7
#         }
#         "action" = {
#           "type" = "expire"
#         }
#       },
#     ]
#   })
# }
