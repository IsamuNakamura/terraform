module "label" {
  source = "../../../modules/cloudposse_null_label"

  # namespace, nameは、プロジェクトによって変更する
  environment = "prd"
  namespace   = "terraform-test"
  name        = ""
  delimiter   = "-"
  label_order = ["environment", "namespace", "name"]
}

module "locals" {
  source = "../../../modules/locals"
}

module "primary" {
  source = "../../../modules/vercel"

  label = module.label.id
  tier  = "primary"

  vercel_api_token = sensitive(replace(file("${path.cwd}/.vercel/api_token"), "\n", ""))
  vercel_team_id   = sensitive(replace(file("${path.cwd}/.vercel/team_id"), "\n", ""))

  repository_type = "github"
  repository_name = ""  # 対象のリポジトリ名を指定する

  domain_name = "${module.locals.frontend_subdomain_name}.${module.locals.domain_name}"

  deploy_ref = "main"

  ignore_command = "bash scripts/vercel/deploy.sh" # module/vercelにdeploy.shがあるので、対象のリポジトリに配置すること

  is_production = true

  environment_variables = {
    next_public_api_app_base_url           = "https://${module.locals.backend_subdomain_name}.${module.locals.domain_name}/api/app/${module.locals.api_version}"
    next_public_backend_base_url           = "https://${module.locals.backend_subdomain_name}.${module.locals.domain_name}"
    next_public_stripe_public_key          = sensitive(replace(file("${path.cwd}/.env/stripe/public_key"), "\n", ""))
    next_public_ga_measurement_id          = sensitive(replace(file("${path.cwd}/.env/google_analytics_measurement_id"), "\n", ""))
    next_public_sentry_dsn                 = sensitive(replace(file("${path.cwd}/.env/sentry/dsn"), "\n", ""))
    next_public_cognito_region             = "${local.primary.cognito_region}"
    next_public_cognito_user_pool_id       = "${local.primary.cognito_user_pool_id}"
    next_public_cognito_frontend_client_id = "${local.primary.cognito_frontend_client_id}"
    next_public_maintenance_mode           = false
    next_public_maintenance_time           = "2024/01/01   12:00 ~ 2024/01/01   14:00 JST"
    next_public_emergency_contact_number   = sensitive(replace(file("${path.cwd}/.env/emergency_contact_number"), "\n", ""))
    sentry_auth_token                      = sensitive(replace(file("${path.cwd}/.env/sentry/auth_token"), "\n", ""))
  }

  providers = {
    aws = aws.primary
    vercel = vercel
  }
}
