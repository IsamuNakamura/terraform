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
# CodeBuild
################################################################################
variable "github_repository_name" {
  description = "Github repository name"
  type        = string
}

variable "github_source_version" {
  description = "Github source version"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_arns" {
  description = "Private Subnet ARNs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private Subnet IDs"
  type        = list(string)
}

variable "rds_cluster_identifier" {
  description = "RDS Cluster Identifier"
  type        = string
}

variable "security_group_rds_id" {
  description = "RDS Security Group ID"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS ARN"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for each service"
  type = map(object({
    migration_directory            = string
    rds_cluster_identifier         = string
    ssm_paramter_database_endpoint = string
    ssm_paramter_database_port     = string
    ssm_paramter_database_username = string
    ssm_paramter_database_password = string
    ssm_paramter_database_name     = string
  }))
}

variable "ssm_parameter_arns" {
  description = "SSM Parameter ARNs for each service"
  type = map(object({
    ssm_paramter_arn_database_endpoint = string
    ssm_paramter_arn_database_port     = string
    ssm_paramter_arn_database_username = string
    ssm_paramter_arn_database_password = string
    ssm_paramter_arn_database_name     = string
  }))
}
