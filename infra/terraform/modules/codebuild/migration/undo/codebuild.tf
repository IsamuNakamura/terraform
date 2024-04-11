resource "aws_codebuild_project" "migration_undo" {
  for_each = { for service_name, environment_variable in var.environment_variables : service_name => environment_variable }

  name                   = "${var.label}-migration-undo-${each.key}"
  service_role           = aws_iam_role.migration[each.key].arn
  build_timeout          = 60
  concurrent_build_limit = 1

  artifacts {
    type = "NO_ARTIFACTS"
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.private_subnet_ids
    security_group_ids = [aws_security_group.migration_undo.id]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "MIGRATION_DIRECTORY"
      value = each.value.migration_directory
    }
    environment_variable {
      name  = "DB_CLUSTER_IDENTIFIER"
      value = each.value.rds_cluster_identifier
    }
    environment_variable {
      name  = "DB_ENDPOINT"
      type  = "PARAMETER_STORE"
      value = each.value.ssm_paramter_database_endpoint
    }
    environment_variable {
      name  = "DB_PORT"
      type  = "PARAMETER_STORE"
      value = each.value.ssm_paramter_database_port
    }
    environment_variable {
      name  = "DB_USERNAME"
      type  = "PARAMETER_STORE"
      value = each.value.ssm_paramter_database_username
    }
    environment_variable {
      name  = "DB_PASSWORD"
      type  = "PARAMETER_STORE"
      value = each.value.ssm_paramter_database_password
    }
    environment_variable {
      name  = "DB_NAME"
      type  = "PARAMETER_STORE"
      value = each.value.ssm_paramter_database_name
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repository_name
    git_clone_depth = 1
    buildspec       = file("${path.cwd}/buildspec/migration/undo.yml")
  }

  source_version = var.github_source_version

  cache {
    type = "NO_CACHE"
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )

  depends_on = [
    aws_iam_role_policy.assume_role_policy,
  ]
}

resource "aws_codebuild_source_credential" "this" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = sensitive(file("${path.cwd}/.github_token"))
}

