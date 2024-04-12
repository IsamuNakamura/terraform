# ################################################################################
# # Local Values
# ################################################################################
locals {
  global = {
    log_group_arn_waf_acl = data.terraform_remote_state.common.outputs.global.log_group_waf_acl_arn
  }
  primary = {
    kms_key_arn                = data.terraform_remote_state.common.outputs.primary.kms_key_primary_arn
    ecs_cluster_arn            = data.terraform_remote_state.backend.outputs.primary_common.ecs_cluster_arn
    ecs_service_name_app       = data.terraform_remote_state.backend.outputs.primary_app.ecs_service_names[0]
    rds_cluster_identifier     = data.terraform_remote_state.rds.outputs.primary.rds_cluster_identifier
    alb_arn_backend            = data.terraform_remote_state.backend.outputs.primary_common.alb_arn
  }
}
