################################################################################
# RDS
################################################################################
resource "aws_security_group_rule" "allow_3306_from_migration_undo" {
  security_group_id        = var.security_group_rds_id
  source_security_group_id = aws_security_group.migration_undo.id
  description              = "access from migration server to rds"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
}

################################################################################
# CodeBuild
################################################################################
resource "aws_security_group" "migration_undo" {
  vpc_id      = var.vpc_id
  description = "allow access to migration"
  name        = "${var.label}-migration-undo"

  tags = merge(
    var.tags,
    {
      Name = "${var.label}-migration-undo",
      Tier = var.tier,
    }
  )
}

resource "aws_security_group_rule" "access_to_rds" {
  security_group_id        = aws_security_group.migration_undo.id
  source_security_group_id = var.security_group_rds_id
  description              = "access to rds"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
}

resource "aws_security_group_rule" "access_to_internet_secure" {
  security_group_id = aws_security_group.migration_undo.id
  description       = "access to internet"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

resource "aws_security_group_rule" "access_to_internet" {
  security_group_id = aws_security_group.migration_undo.id
  description       = "access to internet"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}
