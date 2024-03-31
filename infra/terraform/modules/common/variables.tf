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
# VPC
################################################################################
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones"
  type = map(object({
    order = number
    id    = string
  }))
}

variable "nat_gateway_subnet" {
  description = "コスト削減のため、NAT Gatewayを配置するサブネットを1つにする"
  type        = string
}

################################################################################
# S3
################################################################################
variable "kms_key_arn" {
  description = "Kms Key ARN"
  type        = string
}

################################################################################
# Local Values
################################################################################
locals {
  dbdump_upload_backet = "\"s3://${aws_s3_bucket.rds_backup.id}\""
}
