data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "template_file" "dashboard" {
  template = file("${path.module}/dashboard.json")
  vars = {
    region                     = "${data.aws_region.this.name}"
    ecs_cluster_name           = var.ecs_cluster_name
    ecs_service_name_app       = var.ecs_service_name_app
    rds_cluster_identifier     = var.rds_cluster_identifier
    log_group_arn_waf_acl      = var.log_group_arn_waf_acl
    alb_arn_backend            = var.alb_arn_backend
  }
}
