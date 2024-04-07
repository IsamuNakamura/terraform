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
  source = "../../../modules/cognito"

  label       = module.label.id
  tags        = module.label.tags
  tier        = "primary"
  environment = module.label.environment

  frontend_domain_name = "${module.locals.frontend_subdomain_name}.${module.locals.domain_name}"
  google_client_id     = sensitive(file("${path.cwd}/.providers/google/client_id"))
  google_client_secret = sensitive(file("${path.cwd}/.providers/google/client_secret"))
  kms_key_arn          = local.primary.kms_key_arn

  providers = {
    aws = aws.primary
  }
}