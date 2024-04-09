resource "aws_cloudwatch_log_group" "this" {
  for_each          = { for idx, taskdef in var.taskdefs : idx => taskdef }
  name              = each.value.logConfiguration.options.awslogs-group
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
