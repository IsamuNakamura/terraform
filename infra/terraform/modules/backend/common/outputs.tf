################################################################################
# Route53
################################################################################
output "aws_service_discovery_private_dns_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.backend.id
}

################################################################################
# ECS
################################################################################
output "ecs_cluster_id" {
  value = aws_ecs_cluster.backend.id
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.backend.arn
}

################################################################################
# ALB
################################################################################
output "alb_arn" {
  value = aws_lb.backend.arn
}
output "alb_listener_arn" {
  value = aws_lb_listener.backend.arn
}

output "security_group_alb_id" {
  value = aws_security_group.alb_backend.id
}
