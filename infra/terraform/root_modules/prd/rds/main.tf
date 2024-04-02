module "label" {
  source = "../../../modules/cloudposse_null_label"

  # namespace, nameは、プロジェクトによって変更する
  environment = "prd"
  namespace   = "terraform-test"
  name        = ""
  delimiter   = "-"
  label_order = ["environment", "namespace", "name"]
}

# module "global" {
#   source = "../../../modules/rds/global"

#   tags  = module.label.tags
#   label = module.label.id

#   rds = {
#     engine         = "aurora-mysql"
#     engine_version = "8.0.mysql_aurora.3.04.1"
#   }

#   providers = {
#     aws = aws.global
#   }
# }

module "primary" {
  source = "../../../modules/rds"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  primary = true
  vpc_id  = local.primary.vpc_id
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
  private_subnet_ids = [for subnet_id in local.primary.private_subnet_ids : subnet_id]
  # global_cluster_identifier = module.global.rds_global_cluster.id
  rds = {
    cluster_name = module.label.id
    instances = {
      ap-northeast-1a = {
        name_suffix = "0"
        class       = "db.serverless"
      }
      ap-northeast-1c = {
        name_suffix = "1"
        class       = "db.serverless"
      }
      # ap-northeast-1d = {
      #   name_suffix = "2"
      #   class       = "db.serverless"
      # }
    }
    master_username               = "root"
    master_password               = sensitive(replace(file("${path.cwd}/.password"), "\n", ""))
    family                        = "aurora-mysql8.0"
    engine                        = "aurora-mysql"
    engine_version                = "8.0.mysql_aurora.3.04.1"
    replication_source_identifier = ""
  }
  rds_master_password_for_ssm = sensitive(replace(file("${path.cwd}/.password"), "\n", ""))
  kms_key_arn                 = local.primary.kms_key_arn


  serverless_v2_max_capacity = 8
  serverless_v2_min_capacity = 0.5

  # depends_on = [
  #   module.global
  # ]

  providers = {
    aws = aws.primary
  }
}

# module "secondary" {
#   source = "../../../modules/rds"

#   label = module.label.id
#   tags  = module.label.tags
#   tier  = "secondary"

#   primary = false
#   vpc_id  = local.secondary.vpc_id
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
#   private_subnet_ids        = [for subnet_id in local.secondary.private_subnet_ids : subnet_id]
#   global_cluster_identifier = module.global.rds_global_cluster.id
#   rds = {
#     cluster_name = module.label.id
#     instances = {
#       us-east-2b = {
#         name_suffix = "1"
#         class       = "db.serverless"
#       }
#       us-east-2a = {
#         name_suffix = "0"
#         class       = "db.serverless"
#       }
#     }
#     master_username               = "" # セカンダリでの設定は不要
#     master_password               = "" # セカンダリでの設定は不要
#     family                        = "aurora-mysql8.0"
#     engine                        = "aurora-mysql"
#     engine_version                = "8.0.mysql_aurora.3.04.1"
#     replication_source_identifier = module.primary.rds_cluster.arn
#   }
#   rds_master_password_for_ssm = sensitive(file("${path.cwd}/.password"))
#   kms_key_arn                 = local.secondary.kms_key_arn

#   serverless_v2_max_capacity = 8
#   serverless_v2_min_capacity = 0.5

#   depends_on = [
#     module.global
#   ]

#   providers = {
#     aws = aws.secondary
#   }
# }

