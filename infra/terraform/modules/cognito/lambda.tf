resource "aws_lambda_function" "confirm_email" {
  function_name    = "${var.label}-confirm-email"
  role             = aws_iam_role.confirm_email_lambda_execution_role.arn
  handler          = "src/functions/confirmEmail/handler.main"
  runtime          = "nodejs14.x"
  filename         = "${path.cwd}/lambda_functions/confirm-email.zip"
  source_code_hash = base64sha256("${path.cwd}/lambda_functions/confirm-email.zip")

  # 環境変数の値が、API Gateway、Cognitoと循環参照になっているので、リソース作成後に手動追加が必要
  environment {
    variables = {
      # CONFIRM_EMAIL_URL                   = "${aws_api_gateway_deployment.confirm_email.invoke_url}/${aws_api_gateway_resource.confirm_email.path}"
      COGNITO_BASE_URL                    = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.this.name}.amazoncognito.com"
      COGNITO_USER_POOL_ID                = "${aws_cognito_user_pool.this.id}"
      COGNITO_CLIENT_ID                   = "${aws_cognito_user_pool_client.this.id}"
      CONFIRM_EMAIL_URL                   = ""
      FRONTEND_BASE_URL                   = "https://${var.frontend_domain_name}"
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = 1
      NODE_OPTIONS                        = "--enable-source-maps --stack-trace-limit=1000"
    }
  }

  lifecycle {
    ignore_changes = [
      environment
    ]
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_lambda_function" "custom_message" {
  function_name    = "${var.label}-custom-message"
  role             = aws_iam_role.custom_message_lambda_execution_role.arn
  handler          = "src/functions/customMessage/handler.main"
  runtime          = "nodejs14.x"
  filename         = "${path.cwd}/lambda_functions/custom-message.zip"
  source_code_hash = base64sha256("${path.cwd}/lambda_functions/custom-message.zip")

  # 環境変数の値が、API Gateway、Cognitoと循環参照になっているので、リソース作成後に手動追加が必要
  environment {
    variables = {
      # COGNITO_BASE_URL                    = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.this.name}.amazoncognito.com"
      # COGNITO_USER_POOL_ID                = aws_cognito_user_pool.this.id
      # COGNITO_CLIENT_ID                   = aws_cognito_user_pool_client.this.id
      # CONFIRM_EMAIL_URL                   = "${aws_api_gateway_deployment.confirm_email.invoke_url}/${aws_api_gateway_resource.confirm_email.path}"
      COGNITO_BASE_URL                    = ""
      COGNITO_USER_POOL_ID                = ""
      COGNITO_CLIENT_ID                   = ""
      CONFIRM_EMAIL_URL                   = ""
      FRONTEND_BASE_URL                   = "https://${var.frontend_domain_name}"
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = 1
      NODE_OPTIONS                        = "--enable-source-maps --stack-trace-limit=1000"
    }
  }

  lifecycle {
    ignore_changes = [
      environment
    ]
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_lambda_permission" "confirm_email" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.confirm_email.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.confirm_email.execution_arn}/${aws_api_gateway_deployment.confirm_email.stage_name}/${aws_api_gateway_method.confirm_email.http_method}/${aws_api_gateway_resource.confirm_email.path_part}"
}

resource "aws_lambda_permission" "custom_message" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.custom_message.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn
}
