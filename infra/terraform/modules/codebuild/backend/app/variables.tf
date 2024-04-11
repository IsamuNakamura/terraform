################################################################################
# Tags
################################################################################
variable "label" {
  description = "Resources Label"
  type        = string
}

variable "tags" {
  description = "Resources Tags"
  type        = map(string)
}

variable "tier" {
  description = "Resources's Tier"
  type        = string
}

################################################################################
# CodeBuild
################################################################################
variable "github_repository_name" {
  description = "Github repository name"
  type        = string
}

variable "github_source_version" {
  description = "Github source version"
  type        = string
}

variable "ecr_repository_arns" {
  description = "ECR Repository ARNs"
  type        = map(string)
}

variable "ecs_service_arns" {
  description = "ECS Service ARNs"
  type        = map(string)
}

variable "ecs_task_execution_role_arns" {
  description = "ECS Task Execution Role ARNs"
  type        = map(string)
}

variable "ecs_task_role_arns" {
  description = "ECS Task Role ARNs"
  type        = map(string)
}

variable "environment_variables" {
  description = "Environment variables for each service"
  type = map(object({
    docker_compose_file_name      = string
    docker_compose_service_name   = string
    docker_image_name             = string
    environment                   = string
    ecr_repository_url            = string
    ecs_cluster_arn               = string
    ecs_service_arn               = string
    ecs_task_def_name             = string
    db_host                       = string
    db_port                       = string
    db_user                       = string
    db_password                   = string
    db_name                       = string
    db_dialect                    = string
    cognito_user_pool_id          = string
    cognito_backend_client_id     = string
    cognito_backend_client_secret = string
  }))
}

variable "kms_key_arn" {
  description = "KMS ARN"
  type        = string
}

variable "ssm_parameter_arns" {
  description = "SSM Parameter ARNs for each service"
  type = map(object({
    ssm_paramter_arn_database_endpoint             = string
    ssm_paramter_arn_database_port                 = string
    ssm_paramter_arn_database_username             = string
    ssm_paramter_arn_database_password             = string
    ssm_paramter_arn_database_name                 = string
    ssm_paramter_arn_cognito_user_pool_id          = string
    ssm_paramter_arn_t_cognito_backend_clienid     = string
    ssm_paramter_arn_cognito_backend_client_secret = string
  }))
}
