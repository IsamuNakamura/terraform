resource "aws_codebuild_project" "backend" {
  for_each = { for service_name, environment_variable in var.environment_variables : service_name => environment_variable }

  name                   = "${var.label}-backend-${each.key}"
  service_role           = aws_iam_role.backend[each.key].arn
  build_timeout          = 60
  concurrent_build_limit = 1

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:6.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "REGION"
      value = data.aws_region.this.name
    }
    environment_variable {
      name  = "ENVIRONMENT"
      value = each.value.environment
    }
    environment_variable {
      name  = "DOCKER_COMPOSE_FILE_NAME"
      value = each.value.docker_compose_file_name
    }
    environment_variable {
      name  = "DOCKER_COMPOSE_SERVICE_NAME"
      value = each.value.docker_compose_service_name
    }
    environment_variable {
      name  = "DOCKER_IMAGE_NAME"
      value = each.value.docker_image_name
    }
    environment_variable {
      name  = "ECR_REPOSITORY_URL"
      value = each.value.ecr_repository_url
    }
    environment_variable {
      name  = "ECS_CLUSTER_ARN"
      value = each.value.ecs_cluster_arn
    }
    environment_variable {
      name  = "ECS_SERVICE_ARN"
      value = each.value.ecs_service_arn
    }
    environment_variable {
      name  = "ECS_TASK_DEF_NAME"
      value = each.value.ecs_task_def_name
    }
    environment_variable {
      name  = "DB_HOST"
      type  = "PARAMETER_STORE"
      value = each.value.db_host
    }
    environment_variable {
      name  = "DB_PORT"
      type  = "PARAMETER_STORE"
      value = each.value.db_port
    }
    environment_variable {
      name  = "DB_USER"
      type  = "PARAMETER_STORE"
      value = each.value.db_user
    }
    environment_variable {
      name  = "DB_PASSWORD"
      type  = "PARAMETER_STORE"
      value = each.value.db_password
    }
    environment_variable {
      name  = "DB_NAME"
      type  = "PARAMETER_STORE"
      value = each.value.db_name
    }
    environment_variable {
      name  = "DB_DIALECT"
      value = each.value.db_dialect
    }
    environment_variable {
      name  = "COGNITO_USER_POOL_ID"
      type  = "PARAMETER_STORE"
      value = each.value.cognito_user_pool_id
    }
    environment_variable {
      name  = "COGNITO_BACKEND_CLIENT_ID"
      type  = "PARAMETER_STORE"
      value = each.value.cognito_backend_client_id
    }
    environment_variable {
      name  = "COGNITO_BACKEND_CLIENT_SECRET"
      type  = "PARAMETER_STORE"
      value = each.value.cognito_backend_client_secret
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repository_name
    git_clone_depth = 1
    buildspec       = file("${path.cwd}/buildspec/backend/app.yml")
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
}

resource "aws_codebuild_source_credential" "this" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = sensitive(file("${path.cwd}/.github_token"))
}

