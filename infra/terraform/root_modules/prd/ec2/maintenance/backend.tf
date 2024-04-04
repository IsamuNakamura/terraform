################################################################################
# Terraform Remote Backend
################################################################################
terraform {
  backend "s3" {
    region         = "ap-northeast-1"
    dynamodb_table = "prd-terraform-test-terraform-remote-backend"
    bucket         = "prd-terraform-test-terraform-remote-backend"
    key            = "prd-terraform-test/ec2/maintenance/terraform.tfstate"
    encrypt        = true
    profile        = "Administrator"
  }
}
