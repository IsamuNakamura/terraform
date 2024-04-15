###############################################################################
# Terraform Remote Backend
################################################################################
terraform {
  # dynamodb_table, bucket, key, profileは、プロジェクトによって変更する
  backend "s3" {
    region         = "ap-northeast-1"
    dynamodb_table = "common-terraform-test-terraform-remote-backend"
    bucket         = "common-terraform-test-terraform-remote-backend"
    key            = "common-terraform-test/accounts/github-actions/terraform.tfstate"
    encrypt        = true
    profile        = "Administrator"
  }
}
