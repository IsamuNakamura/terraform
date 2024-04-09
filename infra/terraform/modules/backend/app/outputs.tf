################################################################################
# ECS
################################################################################
output "ecs_service_names" {
  value = [
    for service in aws_ecs_service.backend : service.name
  ]
}

output "ecs_service_arns" {
  value = {
    for service in aws_ecs_service.backend : service.name => service.id
  }
}

output "ecs_task_def_arns" {
  value = {
    for taskDef in aws_ecs_task_definition.backend : element(split("-", taskDef.family), length(split("-", taskDef.family)) - 1) => taskDef.arn_without_revision
  }
}

output "ecs_task_execution_role_arns" {
  value = {
    for idx, role in aws_iam_role.ecs_task_execution_role : aws_ecs_service.backend[idx].name => role.arn
  }
}

output "ecs_task_role_arns" {
  value = {
    for idx, role in aws_iam_role.ecs_task_role : aws_ecs_service.backend[idx].name => role.arn
  }
}

################################################################################
# ECR
################################################################################
output "ecr_repository_urls" {
  value = {
    for app_name, repo in aws_ecr_repository.backend : app_name => repo.repository_url
  }
}

output "ecr_repository_arns" {
  value = { for app_name, repo in aws_ecr_repository.backend : app_name => repo.arn }
}

################################################################################
# Target Group
################################################################################
output "frontend_domain_name" {
  value = [
    for condition in aws_lb_listener_rule.backend[0].condition :
    replace(one(try(one(condition.http_header).values, [])), "https://", "") if condition.http_header != null && length(try(one(condition.http_header).values, [])) > 0
  ]
}

output "backend_domain_name" {
  value = [
    for condition in aws_lb_listener_rule.backend[0].condition :
    one(try(condition.host_header[0].values, [])) if condition.host_header != null && length(condition.host_header) > 0
  ]
}


################################################################################
# Security Groups
################################################################################
output "security_group_id_ecs_service_backend_app" {
  value = aws_security_group.ecs_service_backend[0].id
}
