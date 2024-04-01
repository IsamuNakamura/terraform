module "label" {
  source = "../../../modules/cloudposse_null_label"

  # namespace, nameは、プロジェクトによって変更する
  environment = "prd"
  namespace   = "terraform-test"
  name        = ""
  delimiter   = "-"
  label_order = ["environment", "namespace", "name"]
}

module "global" {
  source = "../../../modules/common/global"

  label = module.label.id
  tags  = module.label.tags
  tier  = "global"

  waf_allow_maintenance_user_agent_access_name = "${module.label.id}-maintenance"
  logs_export_bucket_arn                       = module.primary.log_export_bucket.arn

  providers = {
    aws = aws.global
  }
}

module "primary" {
  source = "../../../modules/common"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  vpc_cidr_block = "10.0.0.0/16"
  availability_zones = {
    ap-northeast-1a = {
      order = 0
      id    = "az4"
    }
    ap-northeast-1c = {
      order = 1
      id    = "az1"
    }
    ap-northeast-1d = {
      order = 2
      id    = "az2"
    }
  }
  nat_gateway_subnet = "ap-northeast-1a"
  kms_key_arn        = module.kms_primary.key_arn

  providers = {
    aws = aws.primary
  }
}

# module "secondary" {
#   source = "../../../modules/common"

#   label = module.label.id
#   tags  = module.label.tags
#   tier  = "secondary"

#   vpc_cidr_block = module.locals.vpc_cidr_block
#   availability_zones = {
#     us-east-2a = {
#       order = 0
#       id    = "az1"
#     }
#     us-east-2b = {
#       order = 1
#       id    = "az2"
#     }
#     us-east-2c = {
#       order = 2
#       id    = "az3"
#     }
#   }
#   kms_key_arn = module.kms_secondary.key_arn

#   providers = {
#     aws = aws.secondary
#   }
# }
