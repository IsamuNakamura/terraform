################################################################################
# Local Values
################################################################################
locals {
  global = {
    acm_certificate_arn = data.terraform_remote_state.certificate.outputs.global.acm_certificate_arn
    waf_acl_arn         = data.terraform_remote_state.common.outputs.global.waf_acl_cloudfront_arn
  }
  primary = {
    vpc_id              = data.terraform_remote_state.common.outputs.primary.vpc_id
    acm_certificate_arn = data.terraform_remote_state.certificate.outputs.primary.acm_certificate_arn
    private_subnet_ids = [
      data.terraform_remote_state.common.outputs.primary.subnet_private_ids.ap-northeast-1a,
      data.terraform_remote_state.common.outputs.primary.subnet_private_ids.ap-northeast-1c,
      data.terraform_remote_state.common.outputs.primary.subnet_private_ids.ap-northeast-1d
    ]
    public_subnet_ids = [
      data.terraform_remote_state.common.outputs.primary.subnet_public_ids.ap-northeast-1a,
      data.terraform_remote_state.common.outputs.primary.subnet_public_ids.ap-northeast-1c,
      data.terraform_remote_state.common.outputs.primary.subnet_public_ids.ap-northeast-1d
    ]
    security_group_rds_id          = data.terraform_remote_state.rds.outputs.primary.security_group_id_rds
    kms_key_arn                    = data.terraform_remote_state.common.outputs.primary.kms_key_primary_arn
    logs_export_bucket_domain_name = data.terraform_remote_state.common.outputs.primary.log_export_bucket.bucket_domain_name
    logs_export_bucket_arn         = data.terraform_remote_state.common.outputs.primary.log_export_bucket.arn
    logs_export_bucket_id          = data.terraform_remote_state.common.outputs.primary.log_export_bucket.id
    cognito_user_pool_id_arn       = data.terraform_remote_state.cognito.outputs.primary.cognito_user_pool_id_arn
  }
}
