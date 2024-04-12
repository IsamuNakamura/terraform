module "label" {
  source = "../../../modules/cloudposse_null_label"

  # namespace, nameは、プロジェクトによって変更する
  environment = "prd"
  namespace   = "terraform-test"
  name        = ""
  delimiter   = "-"
  label_order = ["environment", "namespace", "name"]
}

module "primary" {
  source = "../../../modules/operation"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  kms_key_arn                = local.primary.kms_key_arn
  ecs_cluster_name           = regex("cluster/(.*)", local.primary.ecs_cluster_arn)[0]
  ecs_service_name_app       = local.primary.ecs_service_name_app
  rds_cluster_identifier     = local.primary.rds_cluster_identifier
  log_group_arn_waf_acl      = regex("log-group:(.*)", local.global.log_group_arn_waf_acl)[0]
  alb_arn_backend            = regex("loadbalancer/(.*)", local.primary.alb_arn_backend)[0]

  providers = {
    aws = aws.primary
  }
}
