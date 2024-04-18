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
