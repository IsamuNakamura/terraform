################################################################################
# Terraform Remote Backend
################################################################################
terraform {
  # dynamodb_table, bucket, key, profileは、プロジェクトによって変更する
  backend "s3" {
    region         = "ap-northeast-1"
    dynamodb_table = "prd-terraform-test-terraform-remote-backend"
    bucket         = "prd-terraform-test-terraform-remote-backend"
    key            = "prd-terraform-test/common/terraform.tfstate"
    encrypt        = true
    profile        = "Administrator"
  }
}
