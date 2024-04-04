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
  source = "../../../../modules/ec2/maintenance"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  vpc_id                = local.primary.vpc_id
  rds_backup_bucket_arn = local.primary.rds_backup_bucket_arn
  ec2_params = {
    maintenance = {
      type      = "t2.micro"
      subnet_id = local.primary.subnet_id
    }
  }
  security_group_rds_id = local.primary.security_group_rds_id
  database_names = {
    app = "database_production"
    # app2 = "app2"
  }
  kms_key_arn = local.primary.kms_key_arn

  providers = {
    aws = aws.primary
  }
}
