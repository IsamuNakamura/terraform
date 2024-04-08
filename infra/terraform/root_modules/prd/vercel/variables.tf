################################################################################
# Local Values
################################################################################
locals {
  primary = {
    cognito_region             = data.terraform_remote_state.cognito.outputs.primary.cognito_region
    cognito_user_pool_id       = data.terraform_remote_state.cognito.outputs.primary.cognito_user_pool_id
    cognito_frontend_client_id = data.terraform_remote_state.cognito.outputs.primary.cognito_frontend_client_id
  }
}
