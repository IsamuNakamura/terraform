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

module "global" {
  source = "../../../modules/host_zone"

  label = module.label.id
  tags  = module.label.tags
  tier  = "global"

  domain_name = "${module.locals.domain_name}."

  vercel_production_record_name = "${module.locals.frontend_subdomain_name}.${module.locals.domain_name}"
  vercel_staging_record_name    = "stg-${module.locals.frontend_subdomain_name}.${module.locals.domain_name}"
  vercel_testing_record_name    = "tst-${module.locals.frontend_subdomain_name}.${module.locals.domain_name}"
  vercel_cname_record           = "cname.vercel-dns.com"

  providers = {
    aws = aws.global
  }
}
