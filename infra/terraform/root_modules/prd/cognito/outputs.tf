# モジュール自体を出力したいが、シークレットデータがあるためできないので、個別に出力
output "primary" {
  description = "primary resources"
  value = {
    ssm_parameter_arns = {
      cognito_region                = module.primary.ssm_parameter_arns_cognito_parameter.cognito_region,
      cognito_user_pool_id          = module.primary.ssm_parameter_arns_cognito_parameter.cognito_user_pool_id,
      cognito_frontend_client_id    = module.primary.ssm_parameter_arns_cognito_parameter.cognito_frontend_client_id,
      cognito_backend_client_id     = module.primary.ssm_parameter_arns_cognito_parameter.cognito_backend_client_id,
      cognito_backend_client_secret = module.primary.ssm_parameter_arns_cognito_parameter.cognito_backend_client_secret,
    }
    cognito_user_pool_id_arn   = module.primary.cognito_user_pool_id_arn,
    cognito_region             = module.primary.cognito_region,
    cognito_user_pool_id       = module.primary.cognito_user_pool_id,
    cognito_frontend_client_id = module.primary.cognito_frontend_client_id,
  }
}
