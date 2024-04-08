resource "vercel_project_environment_variable" "next_public_api_app_base_url" {
  project_id = vercel_project.nextjs.id
  key        = "NEXT_PUBLIC_API_APP_BASE_URL"
  value      = var.environment_variables.next_public_api_app_base_url
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "next_public_backend_base_url" {
  project_id = vercel_project.nextjs.id
  key        = "NEXT_PUBLIC_BACKEND_BASE_URL"
  value      = var.environment_variables.next_public_backend_base_url
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "next_public_stripe_public_key" {
  project_id = vercel_project.nextjs.id
  key        = "NEXT_PUBLIC_STRIPE_PUBLIC_KEY"
  value      = var.environment_variables.next_public_stripe_public_key
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "next_public_ga_measurement_id" {
  project_id = vercel_project.nextjs.id
  key        = "NEXT_PUBLIC_GA_MEASUREMENT_ID"
  value      = var.environment_variables.next_public_ga_measurement_id
  # 本番環境のみに設定
  target     = ["production"]
}

resource "vercel_project_environment_variable" "next_public_sentry_dsn" {
  project_id = vercel_project.nextjs.id
  key        = "NEXT_PUBLIC_SENTRY_DSN"
  value      = var.environment_variables.next_public_sentry_dsn
  # 本番環境のみに設定
  target     = ["production"]
}

resource "vercel_project_environment_variable" "next_public_cognito_region" {
  project_id = vercel_project.nextjs.id
  key        = "NEXT_PUBLIC_COGNITO_REGION"
  value      = var.environment_variables.next_public_cognito_region
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "next_public_cognito_user_pool_id" {
  project_id = vercel_project.nextjs.id
  key        = "NEXT_PUBLIC_COGNITO_USER_POOL_ID"
  value      = var.environment_variables.next_public_cognito_user_pool_id
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "next_public_cognito_frontend_client_id" {
  project_id = vercel_project.nextjs.id
  key        = "NEXT_PUBLIC_COGNITO_FRONTEND_CLIENT_ID"
  value      = var.environment_variables.next_public_cognito_frontend_client_id
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "next_public_maintenance_mode" {
  project_id = vercel_project.nextjs.id
  key        = "NEXT_PUBLIC_MAINTENANCE_MODE"
  value      = var.environment_variables.next_public_maintenance_mode
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "next_public_maintenance_time" {
  project_id = vercel_project.nextjs.id
  key        = "NEXT_PUBLIC_MAINTENANCE_TIME"
  value      = var.environment_variables.next_public_maintenance_time
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "next_public_emergency_contact_number" {
  project_id = vercel_project.nextjs.id
  key        = "NEXT_PUBLIC_EMERGENCY_CONTACT_NUMBER"
  value      = var.environment_variables.next_public_emergency_contact_number
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "sentry_auth_token" {
  project_id = vercel_project.nextjs.id
  key        = "SENTRY_AUTH_TOKEN"
  value      = var.environment_variables.sentry_auth_token
  target     = ["production", "preview", "development"]
}
