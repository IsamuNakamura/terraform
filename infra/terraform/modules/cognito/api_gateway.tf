resource "aws_api_gateway_rest_api" "confirm_email" {
  name        = "${var.label}-confirm-email"
  description = "For Lambda function of confirm email"

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_api_gateway_resource" "confirm_email" {
  rest_api_id = aws_api_gateway_rest_api.confirm_email.id
  parent_id   = aws_api_gateway_rest_api.confirm_email.root_resource_id
  path_part   = "confirm-email"
}

resource "aws_api_gateway_method" "confirm_email" {
  rest_api_id   = aws_api_gateway_rest_api.confirm_email.id
  resource_id   = aws_api_gateway_resource.confirm_email.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "confirm_email" {
  rest_api_id = aws_api_gateway_rest_api.confirm_email.id
  resource_id = aws_api_gateway_resource.confirm_email.id
  http_method = aws_api_gateway_method.confirm_email.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.confirm_email.invoke_arn
}

resource "aws_api_gateway_deployment" "confirm_email" {
  depends_on  = [aws_api_gateway_integration.confirm_email]
  rest_api_id = aws_api_gateway_rest_api.confirm_email.id
  stage_name  = var.environment
}
