################################################################################
# ECS
################################################################################
resource "aws_security_group" "ecs_service_backend" {
  for_each = { for idx, taskdef in var.taskdefs : idx => taskdef }

  vpc_id      = var.vpc_id
  description = "allow access to backend ecs service"
  name        = "${var.label}-ecs-service-backend-${each.value.name}"

  tags = merge(
    var.tags,
    {
      Name = "${var.label}-ecs-service-backend-${each.value.name}"
      Tier = var.tier,
    }
  )
}

resource "aws_security_group_rule" "allow_alb_backend_to_ecs_service_backend" {
  for_each = { for idx, security_groups in aws_security_group.ecs_service_backend : idx => security_groups }

  security_group_id        = aws_security_group.ecs_service_backend[each.key].id
  source_security_group_id = var.security_group_alb_backend_id
  description              = "access from backend alb to backend ecs service"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = var.backend_port
  to_port                  = var.backend_port
}

resource "aws_security_group_rule" "access_to_external_service" {
  for_each = { for idx, security_groups in aws_security_group.ecs_service_backend : idx => security_groups }

  security_group_id = aws_security_group.ecs_service_backend[each.key].id
  description       = "access to external service"
  type              = "egress"
  protocol          = "-1" # すべてのプロトコルを許可
  from_port         = 0    # すべてのポートを許可
  to_port           = 0    # すべてのポートを許可
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

resource "aws_security_group_rule" "access_to_rds" {
  for_each = { for idx, security_groups in aws_security_group.ecs_service_backend : idx => security_groups }

  security_group_id        = aws_security_group.ecs_service_backend[each.key].id
  source_security_group_id = var.security_group_rds_id
  description              = "access to rds"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
}

################################################################################
# RDS
################################################################################
resource "aws_security_group_rule" "allow_3306_from_ecs_service_backend" {
  for_each = { for idx, security_groups in aws_security_group.ecs_service_backend : idx => security_groups }

  security_group_id        = var.security_group_rds_id
  source_security_group_id = aws_security_group.ecs_service_backend[each.key].id
  description              = "access from ecs service server to rds"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
}

################################################################################
# ALB
################################################################################
resource "aws_security_group_rule" "access_to_backend_ecs_service" {
  for_each = { for idx, security_groups in aws_security_group.ecs_service_backend : idx => security_groups }

  security_group_id        = var.security_group_alb_backend_id
  source_security_group_id = aws_security_group.ecs_service_backend[each.key].id
  description              = "access to backend ecs service"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = var.backend_port
  to_port                  = var.backend_port
}
