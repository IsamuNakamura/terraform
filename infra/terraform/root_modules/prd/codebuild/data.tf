data "aws_region" "this" {}

data "aws_caller_identity" "primary" {
  provider = aws.primary
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

data "terraform_remote_state" "backend" {
  backend = "s3"

  # dynamodb_table, bucket, key, profileは、プロジェクトによって変更する
  config = {
    region         = "ap-northeast-1"
    dynamodb_table = "prd-terraform-test-terraform-remote-backend"
    bucket         = "prd-terraform-test-terraform-remote-backend"
    key            = "prd-terraform-test/backend/terraform.tfstate"
    encrypt        = true
    profile        = "Administrator"
  }
}

data "terraform_remote_state" "ec2_maintenance" {
  backend = "s3"

  # dynamodb_table, bucket, key, profileは、プロジェクトによって変更する
  config = {
    region         = "ap-northeast-1"
    dynamodb_table = "prd-terraform-test-terraform-remote-backend"
    bucket         = "prd-terraform-test-terraform-remote-backend"
    key            = "prd-terraform-test/ec2/maintenance/terraform.tfstate"
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
