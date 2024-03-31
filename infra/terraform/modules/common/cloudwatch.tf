resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "${var.label}-${var.tier}-vpc-flow-logs"
  retention_in_days = 90

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
