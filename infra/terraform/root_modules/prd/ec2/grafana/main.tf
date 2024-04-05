module "label" {
  source = "../../../../modules/cloudposse_null_label"

  # namespace, nameは、プロジェクトによって変更する
  environment = "prd"
  namespace   = "terraform-test"
  name        = ""
  delimiter   = "-"
  label_order = ["environment", "namespace", "name"]
}

module "primary" {
  source = "../../../../modules/ec2/grafana"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  vpc_id = local.primary.vpc_id
  ami_id = "ami-0d52744d6551d851e" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  ec2_params = {
    grafana = {
      type      = "t2.micro"
      subnet_id = local.primary.subnet_id
    }
  }
  security_group_rds_id = local.primary.security_group_rds_id
  kms_key_arn           = local.primary.kms_key_arn

  providers = {
    aws = aws.primary
  }
}
