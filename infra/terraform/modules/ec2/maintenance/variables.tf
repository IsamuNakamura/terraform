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
# EC2
################################################################################
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ec2_params" {
  description = "EC2 Parameters"
  type = object({
    maintenance = map(string)
  })
}

variable "security_group_rds_id" {
  description = "RDS Security Group ID"
  type        = string
}

variable "database_names" {
  description = "Database Names(key: app name, value: database name)"
  type        = map(string)
}

variable "kms_key_arn" {
  description = "Kms Key ARN"
  type        = string
}

variable "rds_backup_bucket_arn" {
  description = "RDS Backup Bucket ARN"
  type        = string
}

################################################################################
# Local Values
################################################################################
locals {
  ssm_parameters = {
    for key, db_name in var.database_names : "${key}" => {
      name_suffix = "database/name/${key}"
      description = "Database Name for ${db_name}"
      type        = "SecureString"
      value       = db_name
    }
  }
}
