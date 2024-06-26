###############################################################################
# Terraform Remote Backend
################################################################################
terraform {
  # dynamodb_table, bucket, key, profileは、プロジェクトによって変更する
  backend "s3" {
    region         = "ap-northeast-1"
    dynamodb_table = "common-terraform-test-remote-backend"
    bucket         = "common-terraform-test-remote-backend"
    key            = "common-terraform-test/host_zone/terraform.tfstate"
    encrypt        = true
    profile        = "Administrator"
  }
}
