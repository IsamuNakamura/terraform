################################################################################
# Tags
################################################################################
variable "label" {
  type        = string
  description = "Resources Label"
}

variable "tags" {
  type        = map(string)
  description = "Resources Tags"
}

variable "tier" {
  type        = string
  description = "Resources's Tier"
}

################################################################################
# Route53
################################################################################
variable "aws_service_discovery_private_dns_namespace_id" {
  description = "AWS Service Discovery Private DNS Namespace ID"
  type        = string
}

################################################################################
# ECR
################################################################################
variable "service_names" {
  description = "Repository Name For Applications"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS ARN"
  type        = string
}

################################################################################
# ECS + ALB
################################################################################
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

################################################################################
# ECS
################################################################################
variable "ecs_cluster_id" {
  description = "ECS Cluster ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private Subnet IDs"
  type        = list(string)
}

variable "backend_port" {
  description = "Backend Port"
  type        = string
}

variable "security_group_alb_backend_id" {
  description = "Security Group ALB Backend ID"
  type        = string
}

variable "security_group_rds_id" {
  description = "Security Group RDS ID"
  type        = string
}

variable "taskdefs" {
  description = "Task Definition Parameters"
  type = list(object({
    name              = string
    image             = string
    essential         = bool
    cpu               = number
    memory            = number
    memoryReservation = number
    networkMode       = string
    skipDestroy       = bool
    linuxParameters = object({
      capabilities = object({
        add = list(string)
      })
    })
    portMappings = list(object({
      protocol      = string
      containerPort = number
      hostPort      = number
    }))
    logConfiguration = object({
      logDriver = string
      options   = map(string)
    })
    environment = list(object({
      name  = string
      value = string
    }))
    secrets = list(object({
      name      = string
      valueFrom = string
    }))
  }))
}

variable "cognito_user_pool_id_arn" {
  description = "Cognito User Pool ID"
  type        = string
}

################################################################################
# ALB
################################################################################
variable "backend_domain_name" {
  description = "Backend Domain Name"
  type        = string
}

variable "frontend_domain_name" {
  description = "Frontend Domain Name"
  type        = string
}

variable "health_check_path" {
  description = "Health Check Path"
  type        = string
}

variable "aws_lb_listener_backend_arn" {
  description = "ALB Listener Backend ARN"
  type        = string
}

variable "stripe_webhook_path" {
  description = "Stripe Webhook Path"
  type        = string
}

################################################################################
# Local Values
################################################################################
locals {
  ssm_parameters = {
    stripe_secret_key = {
      name_suffix = "backend/stripe_secret_key"
      description = "Stripe Sercret Key"
      type        = "SecureString"
      value       = sensitive(replace(file("${path.cwd}/.stripe/secret_secret_key"), "\n", ""))
    },
    default_stripe_product_id = {
      name_suffix = "backend/default_stripe_product_id"
      description = "Default Stripe Product ID"
      type        = "SecureString"
      value       = sensitive(replace(file("${path.cwd}/.stripe/default_stripe_product_id"), "\n", ""))
    },
    default_stripe_price_id = {
      name_suffix = "backend/default_stripe_price_id"
      description = "Default Stripe Price ID"
      type        = "SecureString"
      value       = sensitive(replace(file("${path.cwd}/.stripe/default_stripe_price_id"), "\n", ""))
    },
    stripe_webhook_secret = {
      name_suffix = "backend/stripe_webhook_secret"
      description = "Stripe Webhook Secret"
      type        = "SecureString"
      value       = sensitive(replace(file("${path.cwd}/.stripe/stripe_webhook_secret"), "\n", ""))
    },
    sentry_dsn = {
      name_suffix = "backend/sentry_dsn"
      description = "Sentry DSN"
      type        = "SecureString"
      value       = sensitive(replace(file("${path.cwd}/.sentry_dsn"), "\n", ""))
    }
  }
}
