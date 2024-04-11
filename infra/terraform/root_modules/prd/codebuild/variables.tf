################################################################################
# Local Values
################################################################################
locals {
  primary = {
    backend = {
      apps = {
        kms_key_arn                                    = data.terraform_remote_state.common.outputs.primary.kms_key_primary_arn
        ecs_cluster_arn                                = data.terraform_remote_state.backend.outputs.primary_common.ecs_cluster_arn
        ecr_repository_urls                            = data.terraform_remote_state.backend.outputs.primary_app.ecr_repository_urls
        ecr_repository_arns                            = data.terraform_remote_state.backend.outputs.primary_app.ecr_repository_arns
        ecs_service_arns                               = data.terraform_remote_state.backend.outputs.primary_app.ecs_service_arns
        ecs_service_names                              = data.terraform_remote_state.backend.outputs.primary_app.ecs_service_names
        ecs_task_def_arns                              = data.terraform_remote_state.backend.outputs.primary_app.ecs_task_def_arns
        ecs_task_execution_role_arns                   = data.terraform_remote_state.backend.outputs.primary_app.ecs_task_execution_role_arns
        ecs_task_role_arns                             = data.terraform_remote_state.backend.outputs.primary_app.ecs_task_role_arns
        ssm_paramter_arn_database_endpoint             = data.terraform_remote_state.rds.outputs.primary.ssm_parameter_arns.database_endpoint
        ssm_paramter_arn_database_port                 = data.terraform_remote_state.rds.outputs.primary.ssm_parameter_arns.database_port
        ssm_paramter_arn_database_username             = data.terraform_remote_state.rds.outputs.primary.ssm_parameter_arns.database_username
        ssm_paramter_arn_database_password             = data.terraform_remote_state.rds.outputs.primary.ssm_parameter_arns.database_password
        ssm_paramter_arns_database_name                = data.terraform_remote_state.ec2_maintenance.outputs.primary.ssm_parameter_arns_database_name
        ssm_paramter_arn_cognito_user_pool_id          = data.terraform_remote_state.cognito.outputs.primary.ssm_parameter_arns.cognito_user_pool_id
        ssm_paramter_arn_cognito_backend_client_id     = data.terraform_remote_state.cognito.outputs.primary.ssm_parameter_arns.cognito_backend_client_id
        ssm_paramter_arn_cognito_backend_client_secret = data.terraform_remote_state.cognito.outputs.primary.ssm_parameter_arns.cognito_backend_client_secret
      }
    }
    migration = {
      vpc_id = data.terraform_remote_state.common.outputs.primary.vpc_id
      private_subnet_arns = [
        data.terraform_remote_state.common.outputs.primary.subnet_private_arns.ap-northeast-1a,
        data.terraform_remote_state.common.outputs.primary.subnet_private_arns.ap-northeast-1c,
        data.terraform_remote_state.common.outputs.primary.subnet_private_arns.ap-northeast-1d
      ]
      private_subnet_ids = [
        data.terraform_remote_state.common.outputs.primary.subnet_private_ids.ap-northeast-1a,
        data.terraform_remote_state.common.outputs.primary.subnet_private_ids.ap-northeast-1c,
        data.terraform_remote_state.common.outputs.primary.subnet_private_ids.ap-northeast-1d
      ]
      kms_key_arn                        = data.terraform_remote_state.common.outputs.primary.kms_key_primary_arn
      rds_cluster_identifier             = data.terraform_remote_state.rds.outputs.primary.rds_cluster_identifier
      security_group_rds_id              = data.terraform_remote_state.rds.outputs.primary.security_group_id_rds
      database_names                     = data.terraform_remote_state.ec2_maintenance.outputs.primary.database_names
      ecs_service_names                  = data.terraform_remote_state.backend.outputs.primary_app.ecs_service_names
      ssm_paramter_arn_database_endpoint = data.terraform_remote_state.rds.outputs.primary.ssm_parameter_arns.database_endpoint
      ssm_paramter_arn_database_port     = data.terraform_remote_state.rds.outputs.primary.ssm_parameter_arns.database_port
      ssm_paramter_arn_database_username = data.terraform_remote_state.rds.outputs.primary.ssm_parameter_arns.database_username
      ssm_paramter_arn_database_password = data.terraform_remote_state.rds.outputs.primary.ssm_parameter_arns.database_password
      ssm_paramter_arns_database_name    = data.terraform_remote_state.ec2_maintenance.outputs.primary.ssm_parameter_arns_database_name
    }
  }
}
