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

variable "environment" {
  description = "Resources's Environment"
  type        = string
}

################################################################################
# S3 + Cognito
################################################################################
variable "kms_key_arn" {
  description = "Kms Key ARN"
  type        = string
}

################################################################################
# Lambda + Cognito
################################################################################
variable "frontend_domain_name" {
  description = "Frontend Domain Name"
  type        = string
}

################################################################################
# Cognito
################################################################################
variable "google_client_id" {
  description = "Google Client ID"
  type        = string
}

variable "google_client_secret" {
  description = "Google Client Secret"
  type        = string
}

################################################################################
# Local Values
################################################################################
locals {
  ssm_parameters = {
    cognito_region = {
      name_suffix = "cognito/region"
      description = "Cognito Region"
      type        = "String"
      value       = data.aws_region.this.name
    }
    cognito_user_pool_id = {
      name_suffix = "cognito/userpool/id"
      description = "Cognito User Pool ID"
      type        = "SecureString"
      value       = aws_cognito_user_pool.this.id
    }
    cognito_frontend_client_id = {
      name_suffix = "cognito/frontend/client/id"
      description = "Cognito Client ID for Frontend"
      type        = "SecureString"
      value       = aws_cognito_user_pool_client.frontend.id
    }
    cognito_backend_client_id = {
      name_suffix = "cognito/backend/client/id"
      description = "Cognito Client ID for Backend"
      type        = "SecureString"
      value       = aws_cognito_user_pool_client.backend.id
    }
    cognito_backend_client_secret = {
      name_suffix = "cognito/backend/client/secret"
      description = "Cognito Client Secret for Backend"
      type        = "SecureString"
      value       = aws_cognito_user_pool_client.backend.client_secret
    }
  }
}
