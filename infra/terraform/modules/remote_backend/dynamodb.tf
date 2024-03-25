# DynamoDBに保存されるキーを取得した場合のみリソースの更新が可能になる(複数ユーザー同時の更新を防ぐ)
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
# ref: https://medium.com/faun/3-tier-architecture-with-terraform-and-aws-part-3-setting-up-backend-s3-and-dynamodb-cb4d55d45d98
resource "aws_dynamodb_table" "remote_backend" {
  name         = "${var.dynamodb_table_name}-terraform-remote-backend"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID" #値はLockIDである必要がある ref: https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-locking

  attribute {
    name = "LockID" #値はLockIDである必要がある ref: https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-locking
    type = "S"
  }

  tags = merge(
    var.tags, {
      Name = "${var.dynamodb_table_name}-terraform-remote-backend",
      Tier = var.tier,
    }
  )
}
