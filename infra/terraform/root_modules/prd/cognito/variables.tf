################################################################################
# Local Values
################################################################################
locals {
  primary = {
    kms_key_arn = data.terraform_remote_state.common.outputs.primary.kms_key_primary_arn
  }
}
