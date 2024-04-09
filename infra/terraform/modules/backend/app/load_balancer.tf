resource "aws_lb_target_group" "backend" {
  for_each = { for idx, taskdef in var.taskdefs : idx => taskdef }

  name        = "${var.label}-backend-${each.value.name}"
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled  = true
    interval = 30
    path     = var.health_check_path
    # path                = "/api/${each.value.name}/health_check"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_lb_listener_rule" "backend" {
  for_each     = { for idx, taskdef in var.taskdefs : idx => taskdef }
  listener_arn = var.aws_lb_listener_backend_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[each.key].arn
  }

  condition {
    path_pattern {
      values = ["/api/${each.value.name}/*"]
    }
  }

  condition {
    host_header {
      values = [var.backend_domain_name]
    }
  }

  condition {
    http_header {
      http_header_name = "Origin"
      values           = ["https://${var.frontend_domain_name}"]
    }
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

# 5つの条件しか設定できないので、分割する
resource "aws_lb_listener_rule" "stripe_webhook_1" {
  for_each     = { for idx, taskdef in var.taskdefs : idx => taskdef }
  listener_arn = var.aws_lb_listener_backend_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[each.key].arn
  }

  condition {
    path_pattern {
      values = [var.stripe_webhook_path]
    }
  }

  condition {
    host_header {
      values = [var.backend_domain_name]
    }
  }

  condition {
    http_header {
      http_header_name = "X-Forwarded-For"
      values           = split("\n", data.local_file.stripe_webhook_ipv4_ips_1.content)
    }
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_lb_listener_rule" "stripe_webhook_2" {
  for_each     = { for idx, taskdef in var.taskdefs : idx => taskdef }
  listener_arn = var.aws_lb_listener_backend_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[each.key].arn
  }

  condition {
    path_pattern {
      values = [var.stripe_webhook_path]
    }
  }

  condition {
    host_header {
      values = [var.backend_domain_name]
    }
  }

  condition {
    http_header {
      http_header_name = "X-Forwarded-For"
      values           = split("\n", data.local_file.stripe_webhook_ipv4_ips_2.content)
    }
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_lb_listener_rule" "stripe_webhook_3" {
  for_each     = { for idx, taskdef in var.taskdefs : idx => taskdef }
  listener_arn = var.aws_lb_listener_backend_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[each.key].arn
  }

  condition {
    path_pattern {
      values = [var.stripe_webhook_path]
    }
  }

  condition {
    host_header {
      values = [var.backend_domain_name]
    }
  }

  condition {
    http_header {
      http_header_name = "X-Forwarded-For"
      values           = split("\n", data.local_file.stripe_webhook_ipv4_ips_3.content)
    }
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_lb_listener_rule" "stripe_webhook_4" {
  for_each     = { for idx, taskdef in var.taskdefs : idx => taskdef }
  listener_arn = var.aws_lb_listener_backend_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[each.key].arn
  }

  condition {
    path_pattern {
      values = [var.stripe_webhook_path]
    }
  }

  condition {
    host_header {
      values = [var.backend_domain_name]
    }
  }

  condition {
    http_header {
      http_header_name = "X-Forwarded-For"
      values           = split("\n", data.local_file.stripe_webhook_ipv4_ips_4.content)
    }
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
