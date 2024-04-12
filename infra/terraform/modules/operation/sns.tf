################################################################################
# AWS Config
################################################################################
resource "aws_sns_topic" "config" {
  name = "${var.label}-config"

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_sns_topic_subscription" "lambda_config" {
  topic_arn = aws_sns_topic.config.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.config.arn
}

resource "aws_sns_topic_policy" "config" {
  arn    = aws_sns_topic.config.arn
  policy = data.aws_iam_policy_document.config_sns_topic.json
}

data "aws_iam_policy_document" "config_sns_topic" {
  statement {
    sid       = "AWSConfigNotification"
    effect    = "Allow"
    resources = [aws_sns_topic.config.arn]
    actions   = ["sns:Publish"]

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com"
      ]
    }
  }

  statement {
    sid       = "AWSLambdaNotification"
    effect    = "Allow"
    resources = [aws_sns_topic.config.arn]
    actions   = ["sns:Publish"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }

  statement {
    sid    = "AWSNSNotification"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    resources = [aws_sns_topic.config.arn]
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOwner"
      values   = [data.aws_caller_identity.this.account_id]
    }
  }
}
