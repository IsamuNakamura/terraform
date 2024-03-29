###############################################################################
# Terraform Remote Backend
################################################################################
terraform {
  # dynamodb_table, bucket, key, profileは、プロジェクトによって変更する
  backend "s3" {
    region         = "ap-northeast-1"
    dynamodb_table = "common-test-terraform-remote-backend"
    bucket         = "common-test-terraform-remote-backend"
    key            = "common-test/host_zone/terraform.tfstate"
    encrypt        = true
    profile        = "Administrator"
  }
}
