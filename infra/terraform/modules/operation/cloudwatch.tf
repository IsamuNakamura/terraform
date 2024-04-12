resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = var.label
  dashboard_body = data.template_file.dashboard.rendered
}

resource "aws_cloudwatch_log_group" "lambda_config" {
  name              = "/aws/lambda/${var.label}-config"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
