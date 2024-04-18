data "aws_region" "this" {}

data "terraform_remote_state" "certificate" {
  backend = "s3"

  # dynamodb_table, bucket, key, profileは、プロジェクトによって変更する
  config = {
    region         = "ap-northeast-1"
    dynamodb_table = "common-terraform-test-terraform-remote-backend"
    bucket         = "common-terraform-test-terraform-remote-backend"
    key            = "common-terraform-test/certificate/terraform.tfstate"
    encrypt        = true
    profile        = "Administrator"
  }
}

data "terraform_remote_state" "common" {
  backend = "s3"

  # dynamodb_table, bucket, key, profileは、プロジェクトによって変更する
  config = {
    region         = "ap-northeast-1"
    dynamodb_table = "prd-terraform-test-terraform-remote-backend"
    bucket         = "prd-terraform-test-terraform-remote-backend"
    key            = "prd-terraform-test/common/terraform.tfstate"
    encrypt        = true
    profile        = "Administrator"
  }
}

data "terraform_remote_state" "rds" {
  backend = "s3"

  # dynamodb_table, bucket, key, profileは、プロジェクトによって変更する
  config = {
    region         = "ap-northeast-1"
    dynamodb_table = "prd-terraform-test-terraform-remote-backend"
    bucket         = "prd-terraform-test-terraform-remote-backend"
    key            = "prd-terraform-test/rds/terraform.tfstate"
    encrypt        = true
    profile        = "Administrator"
  }
}

data "terraform_remote_state" "cognito" {
  backend = "s3"

  # dynamodb_table, bucket, key, profileは、プロジェクトによって変更する
  config = {
    region         = "ap-northeast-1"
    dynamodb_table = "prd-terraform-test-terraform-remote-backend"
    bucket         = "prd-terraform-test-terraform-remote-backend"
    key            = "prd-terraform-test/cognito/terraform.tfstate"
    encrypt        = true
    profile        = "Administrator"
  }
}
