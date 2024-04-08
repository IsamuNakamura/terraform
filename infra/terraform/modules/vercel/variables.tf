################################################################################
# Tags
################################################################################
variable "label" {
  type        = string
  description = "Resources Label"
}

variable "tier" {
  type        = string
  description = "Resources Tier"
}

################################################################################
# Vercel
################################################################################
variable "vercel_api_token" {
  type        = string
  description = "Vercel API Token"
}

variable "vercel_team_id" {
  type        = string
  description = "Vercel Team ID"
}

variable "repository_type" {
  type        = string
  description = "Repository Type"
}

variable "repository_name" {
  type        = string
  description = "Repository Name"
}

variable "ignore_command" {
  type        = string
  description = "Ignore Command"
}

variable "domain_name" {
  type        = string
  description = "Domain Name"
}

variable "deploy_ref" {
  type        = string
  description = "Deploy Ref(Commit hash or branch name)"
}

variable "is_production" {
  type        = bool
  description = "Is Production"
}

variable "environment_variables" {
  description = "Environment variables"
  type = object({
    next_public_api_app_base_url           = string
    next_public_backend_base_url           = string
    next_public_stripe_public_key          = string
    next_public_ga_measurement_id          = string
    next_public_sentry_dsn                 = string
    next_public_cognito_region             = string
    next_public_cognito_user_pool_id       = string
    next_public_cognito_frontend_client_id = string
    next_public_maintenance_mode           = string
    next_public_maintenance_time           = string
    next_public_emergency_contact_number   = string
    sentry_auth_token                      = string
  })
}
