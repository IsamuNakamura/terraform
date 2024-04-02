################################################################################
# Local Values
################################################################################
locals {
  primary = {
    vpc_id      = data.terraform_remote_state.common.outputs.primary.vpc_id
    kms_key_arn = data.terraform_remote_state.common.outputs.primary.kms_key_primary_arn
    private_subnet_ids = [
      data.terraform_remote_state.common.outputs.primary.subnet_private_ids.ap-northeast-1a,
      data.terraform_remote_state.common.outputs.primary.subnet_private_ids.ap-northeast-1c,
      data.terraform_remote_state.common.outputs.primary.subnet_private_ids.ap-northeast-1d
    ]
  }
  # secondary = {
  #   vpc_id      = data.terraform_remote_state.common.outputs.secondary.vpc_id
  #   kms_key_arn = data.terraform_remote_state.common.outputs.secondary.kms_key_secondary_arn
  #   private_subnet_ids = [
  #     data.terraform_remote_state.common.outputs.secondary.subnet_private_ids.us-east-2a,
  #     data.terraform_remote_state.common.outputs.secondary.subnet_private_ids.us-east-2b,
  #     data.terraform_remote_state.common.outputs.secondary.subnet_private_ids.us-east-2c
  #   ]
  # }
}
