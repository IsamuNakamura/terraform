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
# RDS
################################################################################
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones"
  type = map(object({
    order = number
    id    = string
  }))
}

variable "private_subnet_ids" {
  description = "Pribate Subnet IDs"
  type        = list(string)
}

variable "primary" {
  description = <<EOT
  メンテナンスサーバーでデータベースを作成する際に東京リージョンのインスタンスのエンドポイントを指定するために必要な変数
  セカンダリーも同時にクラスターの作成を行うので、オハイオリージョンのインスタンスのエンドポイントをコンフィグに設定してしまいremote-execに失敗する
  EOT
  type        = bool
}

# variable "global_cluster_identifier" {
#   description = "RDS Global cluster ID"
#   type        = string
# }

variable "rds" {
  description = "RDSリソース作成に必要な設定"

  type = object({
    cluster_name = string
    instances = map(object({
      name_suffix = string
      class       = string
    }))
    master_username               = string
    master_password               = string
    family                        = string
    engine                        = string
    engine_version                = string
    replication_source_identifier = string
  })
}

variable "rds_master_password_for_ssm" {
  description = "セカンダリーインスタンスのパスワードの指定はできないので、パラメータストアに保存できるようにする変数"
  type        = string
}

variable "kms_key_arn" {
  description = "Kms Key ARN"
  type        = string
}

variable "serverless_v2_max_capacity" {
  description = "Serverless V2 Max Capacity"
  type        = number
}

variable "serverless_v2_min_capacity" {
  description = "Serverless V2 Min Capacity"
  type        = number
}

################################################################################
# Local Values
################################################################################
locals {
  primary = {
    database_endpoint = aws_rds_cluster.this.endpoint
    database_port     = aws_rds_cluster.this.port
    database_username = aws_rds_cluster.this.master_username
    database_password = var.rds_master_password_for_ssm # セカンダリーはパスワードを取得できないので変数で渡す
  }
  ssm_parameters = {
    database_endpoint = {
      name_suffix = "database/endpoint"
      description = "Database Endpoint"
      type        = "SecureString"
      value       = local.primary.database_endpoint
    }
    database_port = {
      name_suffix = "database/port"
      description = "Database Port"
      type        = "String"
      value       = local.primary.database_port
    }
    database_username = {
      name_suffix = "database/username"
      description = "Database Username"
      type        = "SecureString"
      value       = local.primary.database_username
    }
    database_password = {
      name_suffix = "database/password"
      description = "Database Password"
      type        = "SecureString"
      value       = local.primary.database_password
    }
  }
}