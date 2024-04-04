################################################################################
# RDS
################################################################################
resource "aws_security_group_rule" "allow_3306_from_maintenance_server" {
  security_group_id        = var.security_group_rds_id
  source_security_group_id = aws_security_group.maintenance_server.id
  description              = "access from maintenance server to rds"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
}

################################################################################
# EC2
################################################################################
resource "aws_security_group" "maintenance_server" {
  vpc_id      = var.vpc_id
  description = "allow access to maintenance server"
  name        = "${var.label}-maintenance-server"

  tags = merge(
    var.tags,
    {
      Name = "${var.label}-maintenance-server",
      Tier = var.tier,
    }
  )
}

# 基本的にSSMでメンテナンスサーバーにログインするが、remote_execでデーターベースを作成時にsshする必要があるため、作成
resource "aws_security_group_rule" "allow_ssh_from_remote_exec" {
  security_group_id = aws_security_group.maintenance_server.id
  description       = "access from remote-exec to maintenance to execute sql"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks = [
    "${data.http.my_ip.response_body}/32"
  ]
}

resource "aws_security_group_rule" "access_to_rds" {
  security_group_id        = aws_security_group.maintenance_server.id
  source_security_group_id = var.security_group_rds_id
  description              = "access to rds"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
}

resource "aws_security_group_rule" "access_to_internet_secure" {
  security_group_id = aws_security_group.maintenance_server.id
  description       = "access to internet for downloading packages or something"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

resource "aws_security_group_rule" "access_to_internet" {
  security_group_id = aws_security_group.maintenance_server.id
  description       = "access to internet for downloading packages or something"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}
