################################################################################
# Tags
################################################################################
variable "label" {
  type        = string
  description = "Resources Label"
}

variable "tags" {
  type        = map(string)
  description = "Resources Tags"
}

variable "tier" {
  type        = string
  description = "Resources Tier"
}

################################################################################
# S3
################################################################################
variable "bucket_name" {
  type        = string
  description = "S3 bucket name for terraform remote backend"
}

################################################################################
# DynamoDB
################################################################################
variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table for terraform remote backend"
}