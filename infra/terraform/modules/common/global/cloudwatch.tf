resource "aws_cloudwatch_log_group" "waf_logs" {
  # 名前は、aws-waf-logs-*にする必要がある
  name              = "aws-waf-logs-${var.label}"
  retention_in_days = 90

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
