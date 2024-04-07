################################################################################
# Cognito
################################################################################
output "ssm_parameter_arns_cognito_parameter" {
  value = {
    for key, param in aws_ssm_parameter.cognito : key => param.arn
  }
}

output "cognito_user_pool_id_arn" {
  value = aws_cognito_user_pool.this.arn
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "cognito_frontend_client_id" {
  value = aws_cognito_user_pool_client.frontend.id
}

output "cognito_region" {
  value = data.aws_region.this.name
}