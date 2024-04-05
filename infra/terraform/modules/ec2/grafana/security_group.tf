################################################################################
# RDS
################################################################################
resource "aws_security_group_rule" "allow_3306_from_grafana_server" {
  security_group_id        = var.security_group_rds_id
  source_security_group_id = aws_security_group.grafana_server.id
  description              = "access from grafana server to rds"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
}

################################################################################
# EC2
################################################################################
resource "aws_security_group" "grafana_server" {
  vpc_id      = var.vpc_id
  description = "allow access to grafana server"
  name        = "${var.label}-grafana-server"

  tags = merge(
    var.tags,
    {
      Name = "${var.label}-grafana-server",
      Tier = var.tier,
    }
  )
}

resource "aws_security_group_rule" "access_to_rds" {
  security_group_id        = aws_security_group.grafana_server.id
  source_security_group_id = var.security_group_rds_id
  description              = "access to rds"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
}

resource "aws_security_group_rule" "access_from_internet" {
  security_group_id = aws_security_group.grafana_server.id
  description       = "access from internet to grafana"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_blocks       = [for cidr in split("\n", trimspace(data.local_file.whitelist_ipv4_ips.content)) : cidr if cidr != ""]
}

resource "aws_security_group_rule" "access_to_internet_secure" {
  security_group_id = aws_security_group.grafana_server.id
  description       = "access to internet for downloading packages or to access by session manager"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

resource "aws_security_group_rule" "access_to_internet" {
  security_group_id = aws_security_group.grafana_server.id
  description       = "access to internet for downloading packages or to access by session manager"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}
