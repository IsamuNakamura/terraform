################################################################################
# Cost Anomaly Detection
################################################################################
data "aws_iam_policy_document" "chatbot_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "chatbot_cost_anomaly_detection" {
  name               = "${var.label}-chatbot-cost-anomaly-detection"
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume_role.json

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
