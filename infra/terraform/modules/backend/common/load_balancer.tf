resource "aws_lb" "backend" {
  name               = "${var.label}-backend"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.alb_backend.id
  ]
  subnets = [for subnet_id in var.public_subnet_ids : subnet_id]

  tags = merge(var.tags)
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn_primary

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
