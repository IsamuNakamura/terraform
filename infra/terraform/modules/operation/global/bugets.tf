resource "aws_budgets_budget" "daily_cost_budget" {
  name              = "${var.label}-daily-cost-budget"
  budget_type       = "COST"
  limit_amount      = var.daily_cost_budget
  limit_unit        = "USD"
  time_unit         = "DAILY"
  time_period_start = "2023-08-01_00:00"
  time_period_end   = "2087-06-15_00:00" # AWSの最大値

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = var.budget_threshold
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.daily_cost_anomaly_detection.arn]
  }
}

resource "aws_budgets_budget" "monthly_cost_budget" {
  name              = "${var.label}-monthly-cost-budget"
  budget_type       = "COST"
  limit_amount      = var.monthly_cost_budget
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2023-08-01_00:00"
  time_period_end   = "2087-06-15_00:00" # AWSの最大値

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = var.budget_threshold
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.monthly_cost_anomaly_detection.arn]
  }
}
