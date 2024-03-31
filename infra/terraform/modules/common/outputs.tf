################################################################################
# VPC
################################################################################
output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_public_ids" {
  value = { for subnet in aws_subnet.public : subnet.availability_zone => subnet.id }
}

output "subnet_private_ids" {
  value = { for subnet in aws_subnet.private : subnet.availability_zone => subnet.id }
}

output "subnet_private_arns" {
  value = { for subnet in aws_subnet.private : subnet.availability_zone => subnet.arn }
}

################################################################################
# S3
################################################################################
output "log_export_bucket" {
  value = {
    id                 = aws_s3_bucket.log_export.id,
    arn                = aws_s3_bucket.log_export.arn,
    bucket_domain_name = aws_s3_bucket.log_export.bucket_domain_name,
  }
}

output "rds_backup_bucket" {
  value = {
    id                 = aws_s3_bucket.rds_backup.id,
    arn                = aws_s3_bucket.rds_backup.arn,
    bucket_domain_name = aws_s3_bucket.rds_backup.bucket_domain_name,
  }
}

# 外部DBサービスを利用する場合、定期バックアップ実行用のLambdaをLambdaモジュールで使用できるようにする
# ################################################################################
# # ECR
# ################################################################################
# output "vercel_storage_backup_ecr_repository_url" {
#   value = aws_ecr_repository.vercel_storage_backup.repository_url
# }

