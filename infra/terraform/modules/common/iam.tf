data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  statement {
    sid = "AssumeRoleForVPCFlowLogs"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "vpc-flow-logs.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name               = "${var.label}-${var.tier}-vpc-flow-logs"
  description        = "VPC Flow Logs Role"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role.json

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_iam_role_policy" "vpc_flow_logs_role_policy" {
  name   = aws_iam_role.vpc_flow_logs.name
  role   = aws_iam_role.vpc_flow_logs.id
  policy = data.aws_iam_policy_document.vpc_flow_logs.json
}

data "aws_iam_policy_document" "vpc_flow_logs" {
  statement {
    sid = "CloudWatchLogsForVPCFlowLogs"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.vpc_flow_logs.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_instance_profile" "vpc_flow_logs" {
  name = "${var.label}-${var.tier}-vpc-flow-logs"
  role = aws_iam_role.vpc_flow_logs.name
}
