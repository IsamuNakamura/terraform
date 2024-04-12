################################################################################
# Cost Anomaly Detection
################################################################################
resource "aws_sns_topic" "daily_cost_anomaly_detection" {
  name = "${var.label}-daily-cost-anomaly-detection"

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_sns_topic_policy" "daily_cost_anomaly_detection" {
  arn    = aws_sns_topic.daily_cost_anomaly_detection.arn
  policy = data.aws_iam_policy_document.daily_cost_anomaly_detection.json
}

data "aws_iam_policy_document" "daily_cost_anomaly_detection" {
  statement {
    effect    = "Allow"
    resources = [aws_sns_topic.daily_cost_anomaly_detection.arn]
    actions   = ["sns:Publish"]

    principals {
      type = "Service"
      identifiers = [
        "budgets.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "AWSChatbotNotification"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    resources = [aws_sns_topic.daily_cost_anomaly_detection.arn]
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

resource "aws_sns_topic" "monthly_cost_anomaly_detection" {
  name = "${var.label}-monthly-cost-anomaly-detection"

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_sns_topic_policy" "monthly_cost_anomaly_detection" {
  arn    = aws_sns_topic.monthly_cost_anomaly_detection.arn
  policy = data.aws_iam_policy_document.monthly_cost_anomaly_detection.json
}

data "aws_iam_policy_document" "monthly_cost_anomaly_detection" {
  statement {
    sid       = "AWSBudgetsNotification"
    effect    = "Allow"
    resources = [aws_sns_topic.monthly_cost_anomaly_detection.arn]
    actions   = ["sns:Publish"]

    principals {
      type = "Service"
      identifiers = [
        "budgets.amazonaws.com"
      ]
    }
  }
  statement {
    sid    = "AWSChatbotNotification"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    resources = [aws_sns_topic.monthly_cost_anomaly_detection.arn]
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
