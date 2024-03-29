module "label" {
  source = "../../../../modules/cloudposse_null_label"

  # namespace, nameは、プロジェクトによって変更する
  environment = "common"
  namespace   = "terraform-test"
  name        = ""
  delimiter   = "-"
  label_order = ["environment", "namespace", "name"]
}

module "locals" {
  source = "../../../../modules/locals"
}

module "global_acm" {
  source = "../../../../modules/certificate/acm"

  label = module.label.id
  tags  = module.label.tags
  tier  = "global"

  domain_name            = "*.${module.locals.domain_name}"
  route53_zone_name      = module.locals.domain_name
  route53_dns_validation = true

  providers = {
    aws = aws.global
  }
}

module "primary_acm" {
  source = "../../../../modules/certificate/acm"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  domain_name            = "*.${module.locals.domain_name}"
  route53_zone_name      = module.locals.domain_name
  route53_dns_validation = false

  providers = {
    aws = aws.primary
  }
}

# module "secondary_acm" {
#   source = "../../../../modules/certificate"

#   label = module.label.id
#   tags  = module.label.tags
#   tier  = "secondary"

#   domain_name            = "*.${module.locals.domain_name}"
#   route53_zone_name      = module.locals.domain_name
#   route53_dns_validation = false

#   providers = {
#     aws = aws.secondary
#   }
# }
