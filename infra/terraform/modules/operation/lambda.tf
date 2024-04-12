resource "aws_lambda_function" "config" {
  function_name    = "${var.label}-config"
  filename         = "${path.cwd}/lambda_functions/config/main.zip"
  role             = aws_iam_role.config_lambda_execution_role.arn
  handler          = "main.handler"
  runtime          = "python3.8"
  source_code_hash = base64sha256("${path.cwd}/lambda_functions/config/main.zip")
  environment {
    variables = {
      SLACK_WEBHOOK_URL = sensitive(replace(file("${path.cwd}/.slack/webhook_url/config"), "\n", ""))
    }
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda_config,
  ]
}

resource "aws_lambda_permission" "sns_invoke_permission" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.config.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.config.arn
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config_lambda_execution_role" {
  name = "${var.label}-config_lambda_execution_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

data "aws_iam_policy_document" "config_email_lambda_execution_policy" {
  statement {
    sid       = "AccessSNS"
    effect    = "Allow"
    resources = [aws_sns_topic.config.arn]
    actions = [
      # "SNS:Subscribe",
      "SNS:Publish"
    ]
  }

  statement {
    sid    = "CloudWatchLogsForVPCFlowLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.lambda_config.arn
    ]
  }
}

resource "aws_iam_role_policy" "confirm_email_lambda_execution_role_policy" {
  name   = aws_iam_role.config_lambda_execution_role.name
  role   = aws_iam_role.config_lambda_execution_role.id
  policy = data.aws_iam_policy_document.config_email_lambda_execution_policy.json
}
