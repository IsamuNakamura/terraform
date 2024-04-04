################################################################################
# Local Values
################################################################################
locals {
  primary = {
    vpc_id                = data.terraform_remote_state.common.outputs.primary.vpc_id
    subnet_id             = data.terraform_remote_state.common.outputs.primary.subnet_public_ids.ap-northeast-1a
    kms_key_arn           = data.terraform_remote_state.common.outputs.primary.kms_key_primary_arn
    rds_backup_bucket_arn = data.terraform_remote_state.common.outputs.primary.rds_backup_bucket.arn
    security_group_rds_id = data.terraform_remote_state.rds.outputs.primary.security_group_id_rds
  }
}
