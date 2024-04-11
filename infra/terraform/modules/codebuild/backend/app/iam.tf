data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    sid = "AssumeRoleForCodeBuild"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "codebuild_backend" {
  for_each = { for service_name, environment_variable in var.environment_variables : service_name => environment_variable }

  name               = "${var.label}-${var.tier}-codebuild-backend-${each.key}"
  description        = "codebuild service role for backend"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_iam_role_policy" "codebuild_backend_role_policy" {
  for_each = { for service_name, iam_role in aws_iam_role.codebuild_backend : service_name => iam_role }

  name   = aws_iam_role.codebuild_backend[each.key].name
  role   = aws_iam_role.codebuild_backend[each.key].id
  policy = data.aws_iam_policy_document.codebuild_backend_policy[each.key].json
}

data "aws_iam_policy_document" "codebuild_backend_policy" {
  for_each = { for service_name, environment_variable in var.environment_variables : service_name => environment_variable }

  statement {
    sid = "CodeBuild"

    actions = [
      "codebuild:BatchGet*",
      "codebuild:RetryBuild*",
      "codebuild:StartBuild*",
      "codebuild:StopBuild*",
    ]

    resources = [
      aws_codebuild_project.backend[each.key].arn,
    ]
  }

  statement {
    sid = "CloudWatchLogsForCodeBuild"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.backend[each.key].name}",
      "arn:aws:logs:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.backend[each.key].name}:*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "ECRAccess"

    actions = [
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:PutImage",
    ]

    resources = [
      var.ecr_repository_arns[each.key]
    ]
  }

  statement {
    sid = "ECSAccess"

    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices",
    ]

    resources = [
      var.ecs_service_arns[each.key]
    ]
  }

  statement {
    sid = "PassRoleForECSTaskRole"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      var.ecs_task_execution_role_arns[each.key],
      var.ecs_task_role_arns[each.key]
    ]
  }

  statement {
    sid = "GetSSMParameters"

    actions = [
      "kms:Decrypt",
      "ssm:GetParameters",
    ]

    resources = [
      var.kms_key_arn,
      var.ssm_parameter_arns[each.key].ssm_paramter_arn_database_endpoint,
      var.ssm_parameter_arns[each.key].ssm_paramter_arn_database_port,
      var.ssm_parameter_arns[each.key].ssm_paramter_arn_database_username,
      var.ssm_parameter_arns[each.key].ssm_paramter_arn_database_password,
      var.ssm_parameter_arns[each.key].ssm_paramter_arn_database_name,
      var.ssm_parameter_arns[each.key].ssm_paramter_arn_cognito_user_pool_id,
      var.ssm_parameter_arns[each.key].ssm_paramter_arn_cognito_backend_client_id,
      var.ssm_parameter_arns[each.key].ssm_paramter_arn_cognito_backend_client_secret,
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllResourcesAccess"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:ListTaskDefinitions",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_instance_profile" "codebuild_backend" {
  for_each = { for service_name, iam_role in aws_iam_role.codebuild_backend : service_name => iam_role }

  name = "${var.label}-${var.tier}-codebuild-backend-${each.key}"
  role = aws_iam_role.codebuild_backend[each.key].name
}
