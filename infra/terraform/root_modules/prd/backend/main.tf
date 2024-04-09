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

module "primary_common" {
  source = "../../../modules/backend/common"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  acm_certificate_arn_global     = local.global.acm_certificate_arn
  acm_certificate_arn_primary    = local.primary.acm_certificate_arn
  backend_domain_name            = "${module.locals.backend_subdomain_name}.${module.locals.domain_name}"
  waf_acl_arn                    = local.global.waf_acl_arn
  route53_zone_name              = module.locals.domain_name
  discovery_service_domain_name  = module.locals.discovery_service_domain_name
  vpc_id                         = local.primary.vpc_id
  public_subnet_ids              = local.primary.public_subnet_ids
  logs_export_bucket_domain_name = local.primary.logs_export_bucket_domain_name
  logs_export_bucket_arn         = local.primary.logs_export_bucket_arn
  logs_export_bucket_id          = local.primary.logs_export_bucket_id
  custom_headers                 = [
                                    "Access-Control-Request-Method",
                                    "Access-Control-Request-Headers",
                                    "Origin",
                                    "Host",
                                    "accesstoken",
                                    "stripe-signature"
                                   ]

  providers = {
    aws = aws.primary
  }
}

module "primary_app" {
  source = "../../../modules/backend/app"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  vpc_id                                         = local.primary.vpc_id
  private_subnet_ids                             = local.primary.private_subnet_ids
  ecs_cluster_id                                 = module.primary_common.ecs_cluster_id
  aws_lb_listener_backend_arn                    = module.primary_common.alb_listener_arn
  backend_port                                   = module.locals.backend_port
  security_group_alb_backend_id                  = module.primary_common.security_group_alb_id
  security_group_rds_id                          = local.primary.security_group_rds_id
  frontend_domain_name                           = "${module.locals.frontend_subdomain_name}.${module.locals.domain_name}"
  backend_domain_name                            = "${module.locals.backend_subdomain_name}.${module.locals.domain_name}"
  health_check_path                              = "/api/app/${module.locals.api_version}/${module.locals.health_check_path}"
  kms_key_arn                                    = local.primary.kms_key_arn
  cognito_user_pool_id_arn                       = local.primary.cognito_user_pool_id_arn
  aws_service_discovery_private_dns_namespace_id = module.primary_common.aws_service_discovery_private_dns_namespace_id
  stripe_webhook_path                            = "/webhooks/stripe"

  service_names = [
    "app",
  ]

  taskdefs = [
    {
      name              = "app"
      image             = "app:latest"
      essential         = true
      cpu               = 256
      memory            = 512
      memoryReservation = 512
      networkMode       = "awsvpc"
      skipDestroy       = false
      linuxParameters   = null
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = module.locals.backend_port
          hostPort      = module.locals.backend_port
        },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = data.aws_region.this.name
          awslogs-group         = "/${join("/", split("-", "${module.label.id}-app"))}"
          awslogs-stream-prefix = "app"
        }
      }
      environment = [
        {
          "name"  = "ALLOWED_ORIGINS",
          "value" = "https://${module.locals.frontend_subdomain_name}.${module.locals.domain_name}"
        },
        {
          "name"  = "PORT",
          "value" = tostring(module.locals.backend_port)
        },
        {
          "name"  = "NODE_ENV",
          "value" = "production"
        },
        {
          "name"  = "APP_BASE_URL"
          "value" = "https://${module.locals.frontend_subdomain_name}.${module.locals.domain_name}"
        }
      ],
      secrets = [
        {
          "name"      = "STRIPE_SECRET_KEY",
          "valueFrom" = "/${join("/", split("-", module.label.id))}/backend/stripe_secret_key"
        },
        {
          "name"      = "DEFAULT_STRIPE_PRODUCT_ID",
          "valueFrom" = "/${join("/", split("-", module.label.id))}/backend/default_stripe_product_id"
        },
        {
          "name"      = "DEFAULT_STRIPE_PRICE_ID",
          "valueFrom" = "/${join("/", split("-", module.label.id))}/backend/default_stripe_price_id"
        },
        {
          "name"      = "STRIPE_WEBHOOK_SECRET",
          "valueFrom" = "/${join("/", split("-", module.label.id))}/backend/stripe_webhook_secret"
        },
        {
          "name"      = "SENTRY_DSN",
          "valueFrom" = "/${join("/", split("-", module.label.id))}/backend/sentry_dsn"
        }
      ]
    },
  ]

  providers = {
    aws = aws.primary
  }
}
