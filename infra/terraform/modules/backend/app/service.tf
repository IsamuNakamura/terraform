resource "aws_ecs_service" "backend" {
  for_each = { for idx, taskdef in var.taskdefs : idx => taskdef }

  name            = each.value.name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.backend[each.key].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_service_backend[each.key].id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend[each.key].arn
    container_name   = each.value.name
    container_port   = var.backend_port
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.backend[each.key].arn}"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  // タスク数は運用時に手動で変更するので、desired_countは無視
  // Codebuildでの実行でタスク定義は更新されるので、task_definitionは無視
  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_service_discovery_service" "backend" {
  for_each = { for idx, taskdef in var.taskdefs : idx => taskdef }

  name = "${each.value.name}"

  dns_config {
    namespace_id = var.aws_service_discovery_private_dns_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
