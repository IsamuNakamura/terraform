################################################################################
# ALB
################################################################################
resource "aws_security_group" "alb_backend" {
  vpc_id      = var.vpc_id
  description = "allow access to backend alb"
  name        = "${var.label}-alb-backend"

  tags = merge(
    var.tags,
    {
      Name = "${var.label}-alb-backend",
      Tier = var.tier,
    }
  )
}

resource "aws_security_group_rule" "allow_cloudfront_to_backend_alb" {
  security_group_id = aws_security_group.alb_backend.id
  description       = "access from cloudfront to backend alb"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
}
