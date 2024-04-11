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

resource "aws_iam_role" "codebuild_migration_up" {
  for_each = { for service_name, environment_variable in var.environment_variables : service_name => environment_variable }

  name               = "${var.label}-${var.tier}-codebuild-migration-up-${each.key}"
  description        = "codebuild service role for migration up"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_iam_role_policy" "codebuild_migration_up_role_policy" {
  for_each = { for service_name, iam_role in aws_iam_role.codebuild_migration_up : service_name => iam_role }

  name   = aws_iam_role.codebuild_migration_up[each.key].name
  role   = aws_iam_role.codebuild_migration_up[each.key].id
  policy = data.aws_iam_policy_document.codebuild_migration_up_policy[each.key].json
}

data "aws_iam_policy_document" "codebuild_migration_up_policy" {
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
      # vpc_configの設定があるとec2:DescribeSecurityGroupsの権限が必要でポリシーが先に作成されていないとエラーになるが、arnを指定すると循環参照でエラーになるので、*で対応
      # このポリシーで全リソース対象にしてもさほど問題ではないが、最小権限のルールに遵守したければ手動で変更すること
      "*"
      # aws_codebuild_project.migration_up[each.key].arn,
    ]
  }

  statement {
    sid = "RDS"

    actions = [
      "rds:StartDBCluster",
      "rds:StopDBCluster",
      "rds:DescribeDBClusters"
    ]

    resources = [
      "arn:aws:rds:${data.aws_region.this.name}:${data.aws_caller_identity.current.account_id}:cluster:${var.rds_cluster_identifier}"
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
      # vpc_configの設定があるとセキュリティグループを読み込む際にポリシーが先に作成されていないとエラーになるが、arnを指定すると循環参照でエラーになるので、*で対応
      # このポリシーで全リソース対象にしてもさほど問題ではないが、最小権限のルールに遵守したければ手動で変更すること
      "*"
      # "arn:aws:logs:${data.aws_region.this.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.migration_up[each.key].name}",
      # "arn:aws:logs:${data.aws_region.this.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.migration_up[each.key].name}:*",
    ]
    effect = "Allow"
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
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllowCreateNetworkInterfacePermission"

    actions = [
      "ec2:CreateNetworkInterfacePermission"
    ]

    resources = [
      "arn:aws:ec2:${data.aws_region.this.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"
    ]

    condition {
      test     = "ForAnyValue:ArnEquals"
      variable = "ec2:Subnet"
      values   = var.private_subnet_arns
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }

    effect = "Allow"
  }

  statement {
    sid = "AllResourcesAccess"

    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeDhcpOptions",
      "ec2:CreateNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_instance_profile" "codebuild_migration_up" {
  for_each = { for service_name, iam_role in aws_iam_role.codebuild_migration_up : service_name => iam_role }

  name = "${var.label}-${var.tier}-codebuild-migration-up-${each.key}"
  role = aws_iam_role.codebuild_migration_up[each.key].name
}
