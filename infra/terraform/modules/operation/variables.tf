################################################################################
# Tags
################################################################################
variable "label" {
  description = "Resources Label"
  type        = string
}

variable "tags" {
  description = "Resources Tags"
  type        = map(string)
}

variable "tier" {
  description = "Resources's Tier"
  type        = string
}

################################################################################
# CloudWatch
################################################################################
variable "ecs_cluster_name" {
  description = "ECS Cluster Name"
  type        = string
}

variable "ecs_service_name_app" {
  description = "ECS Service Name for App API"
  type        = string
}

variable "rds_cluster_identifier" {
  description = "RDS Cluster Identifier"
  type        = string
}

variable "log_group_arn_waf_acl" {
  description = "CloudWatch Logs Group ARN for WAF ACL"
  type        = string
}

variable "alb_arn_backend" {
  description = "ALB ARN for Backend"
  type        = string
}

################################################################################
# S3
################################################################################
variable "kms_key_arn" {
  description = "Kms Key ARN"
  type        = string
}
