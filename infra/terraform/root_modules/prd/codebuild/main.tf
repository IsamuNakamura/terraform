module "label" {
  source = "../../../modules/cloudposse_null_label"

  # namespace, nameは、プロジェクトによって変更する
  environment = "prd"
  namespace   = "terraform-test"
  name        = ""
  delimiter   = "-"
  label_order = ["environment", "namespace", "name"]
}

module "locals" {
  source = "../../../modules/locals"
}

module "primary_backend_app" {
  source = "../../../modules/codebuild/backend/app"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  kms_key_arn            = local.primary.backend.apps.kms_key_arn
  github_repository_name = "" # 対象のリポジトリ名を指定する
  github_source_version  = "main"

  # 下記以降はサービスの数に応じて変更する
  ecr_repository_arns = {
    "${local.primary.backend.apps.ecs_service_names[0]}" = local.primary.backend.apps.ecr_repository_arns[local.primary.backend.apps.ecs_service_names[0]],
  }

  ecs_service_arns = {
    "${local.primary.backend.apps.ecs_service_names[0]}" = local.primary.backend.apps.ecs_service_arns[local.primary.backend.apps.ecs_service_names[0]],
  }

  ecs_task_execution_role_arns = {
    "${local.primary.backend.apps.ecs_service_names[0]}" = local.primary.backend.apps.ecs_task_execution_role_arns[local.primary.backend.apps.ecs_service_names[0]],
  }

  ecs_task_role_arns = {
    "${local.primary.backend.apps.ecs_service_names[0]}" = local.primary.backend.apps.ecs_task_role_arns[local.primary.backend.apps.ecs_service_names[0]],
  }

  environment_variables = {
    "${local.primary.backend.apps.ecs_service_names[0]}" = {
      docker_compose_file_name      = "docker-compose-prd.yml"
      docker_compose_service_name   = "${local.primary.backend.apps.ecs_service_names[0]}"
      docker_image_name             = "${local.primary.backend.apps.ecs_service_names[0]}"
      environment                   = "production"
      ecr_repository_url            = "${local.primary.backend.apps.ecr_repository_urls[local.primary.backend.apps.ecs_service_names[0]]}"
      ecs_cluster_arn               = "${local.primary.backend.apps.ecs_cluster_arn}"
      ecs_service_arn               = "${local.primary.backend.apps.ecs_service_arns[local.primary.backend.apps.ecs_service_names[0]]}"
      ecs_task_def_name             = "${element(split("/", local.primary.backend.apps.ecs_task_def_arns[local.primary.backend.apps.ecs_service_names[0]]), length(split("/", local.primary.backend.apps.ecs_task_def_arns[local.primary.backend.apps.ecs_service_names[0]])) - 1)}"
      db_host                       = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.backend.apps.ssm_paramter_arn_database_endpoint)[0]
      db_port                       = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.backend.apps.ssm_paramter_arn_database_port)[0]
      db_user                       = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.backend.apps.ssm_paramter_arn_database_username)[0]
      db_password                   = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.backend.apps.ssm_paramter_arn_database_password)[0]
      db_name                       = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.backend.apps.ssm_paramter_arns_database_name[local.primary.backend.apps.ecs_service_names[0]])[0]
      db_dialect                    = "mysql"
      cognito_user_pool_id          = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.backend.apps.ssm_paramter_arn_cognito_user_pool_id)[0]
      cognito_backend_client_id     = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.backend.apps.ssm_paramter_arn_cognito_backend_client_id)[0]
      cognito_backend_client_secret = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.backend.apps.ssm_paramter_arn_cognito_backend_client_secret)[0]
    }
  }

  ssm_parameter_arns = {
    "${local.primary.backend.apps.ecs_service_names[0]}" = {
      ssm_paramter_arn_database_endpoint             = "${local.primary.backend.apps.ssm_paramter_arn_database_endpoint}"
      ssm_paramter_arn_database_port                 = "${local.primary.backend.apps.ssm_paramter_arn_database_port}"
      ssm_paramter_arn_database_username             = "${local.primary.backend.apps.ssm_paramter_arn_database_username}"
      ssm_paramter_arn_database_password             = "${local.primary.backend.apps.ssm_paramter_arn_database_password}"
      ssm_paramter_arn_database_name                 = "${local.primary.backend.apps.ssm_paramter_arns_database_name[local.primary.backend.apps.ecs_service_names[0]]}"
      ssm_paramter_arn_cognito_user_pool_id          = "${local.primary.backend.apps.ssm_paramter_arn_cognito_user_pool_id}"
      ssm_paramter_arn_cognito_backend_client_id     = "${local.primary.backend.apps.ssm_paramter_arn_cognito_backend_client_id}"
      ssm_paramter_arn_cognito_backend_client_secret = "${local.primary.backend.apps.ssm_paramter_arn_cognito_backend_client_secret}"
    },
  }

  providers = {
    aws = aws.primary
  }
}

module "primary_migration_up" {
  source = "../../../modules/codebuild/migration/up"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  github_repository_name = "" # 対象のリポジトリ名を指定する
  github_source_version  = "main"
  vpc_id                 = local.primary.migration.vpc_id
  private_subnet_arns    = local.primary.migration.private_subnet_arns
  private_subnet_ids     = local.primary.migration.private_subnet_ids
  rds_cluster_identifier = local.primary.migration.rds_cluster_identifier
  security_group_rds_id  = local.primary.migration.security_group_rds_id
  kms_key_arn            = local.primary.migration.kms_key_arn

  # 下記以降はサービスの数に応じて変更する
  environment_variables = {
    "${local.primary.backend.apps.ecs_service_names[0]}" = {
      migration_directory            = "./src/db"
      rds_cluster_identifier         = "${local.primary.migration.rds_cluster_identifier}"
      ssm_paramter_database_endpoint = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.migration.ssm_paramter_arn_database_endpoint)[0]
      ssm_paramter_database_port     = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.migration.ssm_paramter_arn_database_port)[0]
      ssm_paramter_database_username = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.migration.ssm_paramter_arn_database_username)[0]
      ssm_paramter_database_password = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.migration.ssm_paramter_arn_database_password)[0]
      ssm_paramter_database_name     = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.migration.ssm_paramter_arns_database_name[local.primary.backend.apps.ecs_service_names[0]])[0]
    },
  }
  ssm_parameter_arns = {
    "${local.primary.backend.apps.ecs_service_names[0]}" = {
      ssm_paramter_arn_database_endpoint = "${local.primary.migration.ssm_paramter_arn_database_endpoint}"
      ssm_paramter_arn_database_port     = "${local.primary.migration.ssm_paramter_arn_database_port}"
      ssm_paramter_arn_database_username = "${local.primary.migration.ssm_paramter_arn_database_username}"
      ssm_paramter_arn_database_password = "${local.primary.migration.ssm_paramter_arn_database_password}"
      ssm_paramter_arn_database_name     = "${local.primary.migration.ssm_paramter_arns_database_name[local.primary.backend.apps.ecs_service_names[0]]}"
    },
  }

  providers = {
    aws = aws.primary
  }
}

module "primary_migration_undo" {
  source = "../../../modules/codebuild/migration/undo"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  github_repository_name = "" # 対象のリポジトリ名を指定する
  github_source_version  = "main"
  vpc_id                 = local.primary.migration.vpc_id
  private_subnet_arns    = local.primary.migration.private_subnet_arns
  private_subnet_ids     = local.primary.migration.private_subnet_ids
  rds_cluster_identifier = local.primary.migration.rds_cluster_identifier
  security_group_rds_id  = local.primary.migration.security_group_rds_id
  kms_key_arn            = local.primary.migration.kms_key_arn

  # 下記以降はサービスの数に応じて変更する
  environment_variables = {
    "${local.primary.backend.apps.ecs_service_names[0]}" = {
      migration_directory            = "./src/db"
      rds_cluster_identifier         = "${local.primary.migration.rds_cluster_identifier}"
      ssm_paramter_database_endpoint = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.migration.ssm_paramter_arn_database_endpoint)[0]
      ssm_paramter_database_port     = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.migration.ssm_paramter_arn_database_port)[0]
      ssm_paramter_database_username = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.migration.ssm_paramter_arn_database_username)[0]
      ssm_paramter_database_password = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.migration.ssm_paramter_arn_database_password)[0]
      ssm_paramter_database_name     = regex("arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.primary.account_id}:parameter(/.*)", local.primary.migration.ssm_paramter_arns_database_name[local.primary.backend.apps.ecs_service_names[0]])[0]
    },
  }
  ssm_parameter_arns = {
    "${local.primary.backend.apps.ecs_service_names[0]}" = {
      ssm_paramter_arn_database_endpoint = "${local.primary.migration.ssm_paramter_arn_database_endpoint}"
      ssm_paramter_arn_database_port     = "${local.primary.migration.ssm_paramter_arn_database_port}"
      ssm_paramter_arn_database_username = "${local.primary.migration.ssm_paramter_arn_database_username}"
      ssm_paramter_arn_database_password = "${local.primary.migration.ssm_paramter_arn_database_password}"
      ssm_paramter_arn_database_name     = "${local.primary.migration.ssm_paramter_arns_database_name[local.primary.backend.apps.ecs_service_names[0]]}"
    },
  }

  providers = {
    aws = aws.primary
  }
}
