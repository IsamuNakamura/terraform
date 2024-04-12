################################################################################
# Cost Anomaly Detection
################################################################################
resource "awscc_chatbot_slack_channel_configuration" "daily_cost_anomaly_detection" {
  configuration_name = "${var.label}-daily-cost-anomaly-detection"
  iam_role_arn       = aws_iam_role.chatbot_cost_anomaly_detection.arn
  slack_workspace_id = sensitive(replace(file("${path.cwd}/.slack/slack_workspace_id"), "\n", ""))
  slack_channel_id   = sensitive(replace(file("${path.cwd}/.slack/channel_ids/daily_cost_anomaly"), "\n", ""))
  guardrail_policies = [
    "arn:aws:iam::aws:policy/AWSBudgetsReadOnlyAccess"
  ]
  sns_topic_arns = [aws_sns_topic.daily_cost_anomaly_detection.arn]
  logging_level  = "INFO"
}


resource "awscc_chatbot_slack_channel_configuration" "monthly_cost_anomaly_detection" {
  configuration_name = "${var.label}-monthly-cost-anomaly-detection"
  iam_role_arn       = aws_iam_role.chatbot_cost_anomaly_detection.arn
  slack_workspace_id = sensitive(replace(file("${path.cwd}/.slack/slack_workspace_id"), "\n", ""))
  slack_channel_id   = sensitive(replace(file("${path.cwd}/.slack/channel_ids/monthly_cost_anomaly"), "\n", ""))
  guardrail_policies = [
    "arn:aws:iam::aws:policy/AWSBudgetsReadOnlyAccess"
  ]
  sns_topic_arns = [aws_sns_topic.monthly_cost_anomaly_detection.arn]
  logging_level  = "INFO"
}
