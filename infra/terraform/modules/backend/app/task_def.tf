resource "aws_ecs_task_definition" "backend" {
  for_each = { for idx, taskdef in var.taskdefs : idx => taskdef }

  family                   = "${var.label}-backend-${each.value.name}"
  network_mode             = each.value.networkMode
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role[each.key].arn
  task_role_arn            = aws_iam_role.ecs_task_role[each.key].arn

  container_definitions = jsonencode([each.value])

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    sid = "AllowECSTaskAssumeRole"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  for_each = { for idx, taskdef in var.taskdefs : idx => taskdef }

  name               = "${var.label}-ecs-task-execution-role-backend-${each.value.name}"
  description        = "ECS task execution role for each task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  for_each = { for idx, iam_role in aws_iam_role.ecs_task_execution_role : idx => iam_role }

  name   = aws_iam_role.ecs_task_execution_role[each.key].name
  role   = aws_iam_role.ecs_task_execution_role[each.key].id
  policy = data.aws_iam_policy_document.ecs_task_execution_role_policy[each.key].json
}

data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  for_each = { for idx, ecs_task_execution_role in aws_iam_role.ecs_task_execution_role : idx => ecs_task_execution_role }

  statement {
    sid = "AmazonECSTaskExecutionRolePolicy"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
    ]

    resources = ["*"]
  }

  statement {
    sid = "GetSSMParameters"

    actions = [
      "kms:Decrypt",
      "ssm:GetParameters",
    ]

    resources = [
      var.kms_key_arn,
      aws_ssm_parameter.backend["stripe_secret_key"].arn,
      aws_ssm_parameter.backend["default_stripe_product_id"].arn,
      aws_ssm_parameter.backend["default_stripe_price_id"].arn,
      aws_ssm_parameter.backend["stripe_webhook_secret"].arn,
      aws_ssm_parameter.backend["sentry_dsn"].arn,
    ]
    effect = "Allow"
  }
}

resource "aws_iam_instance_profile" "ecs_task_execution_instance_profile" {
  for_each = { for idx, ecs_task_execution_role in aws_iam_role.ecs_task_execution_role : idx => ecs_task_execution_role }

  name = "${var.label}-ecs-task-execution-backend-${each.value.name}"
  role = aws_iam_role.ecs_task_execution_role[each.key].id
}


resource "aws_iam_role" "ecs_task_role" {
  for_each = { for idx, taskdef in var.taskdefs : idx => taskdef }

  name               = "${var.label}-ecs-task-role-backend-${each.value.name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_iam_role_policy" "ecs_task_role_policy" {
  for_each = { for idx, iam_role in aws_iam_role.ecs_task_role : idx => iam_role }

  name   = aws_iam_role.ecs_task_role[each.key].name
  role   = aws_iam_role.ecs_task_role[each.key].id
  policy = data.aws_iam_policy_document.ecs_task_role_policy[each.key].json
}

data "aws_iam_policy_document" "ecs_task_role_policy" {
  for_each = { for idx, ecs_task_execution_role in aws_iam_role.ecs_task_execution_role : idx => ecs_task_execution_role }

  statement {
    sid = "AccessCognito"

    actions = [
      "cognito-idp:AdminInitiateAuth",
      "cognito-idp:ListUsers",
      "cognito-idp:AdminDeleteUser"
    ]

    resources = [var.cognito_user_pool_id_arn]
  }
}

resource "aws_iam_instance_profile" "ecs_task_instance_profile" {
  for_each = { for idx, ecs_task_role in aws_iam_role.ecs_task_role : idx => ecs_task_role }

  name = "${var.label}-ecs-task-backend-${each.value.name}"
  role = aws_iam_role.ecs_task_role[each.key].id
}
