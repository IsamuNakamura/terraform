data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "confirm_email_lambda_execution_role" {
  name               = "${var.label}-confirm-email-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

data "aws_iam_policy_document" "confirm_email_lambda_execution_policy" {
  statement {
    sid       = "AccessAPIGateway"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.confirm_email.arn]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["${aws_api_gateway_rest_api.confirm_email.execution_arn}/${aws_api_gateway_deployment.confirm_email.stage_name}/${aws_api_gateway_method.confirm_email.http_method}/${aws_api_gateway_resource.confirm_email.path_part}"]
    }
  }
}

resource "aws_iam_role_policy" "confirm_email_lambda_execution_role_policy" {
  name   = aws_iam_role.confirm_email_lambda_execution_role.name
  role   = aws_iam_role.confirm_email_lambda_execution_role.id
  policy = data.aws_iam_policy_document.confirm_email_lambda_execution_policy.json
}

resource "aws_iam_role" "custom_message_lambda_execution_role" {
  name               = "${var.label}-custom-message-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

data "aws_iam_policy_document" "custom_message_lambda_execution_policy" {
  statement {
    sid       = "AccessCognito"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.custom_message.arn]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_cognito_user_pool.this.arn]
    }
  }
}

resource "aws_iam_role_policy" "custom_message_lambda_execution_role_policy" {
  name   = aws_iam_role.custom_message_lambda_execution_role.name
  role   = aws_iam_role.custom_message_lambda_execution_role.id
  policy = data.aws_iam_policy_document.custom_message_lambda_execution_policy.json
}
