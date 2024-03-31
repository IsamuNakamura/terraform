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
# WAF
################################################################################
variable "waf_allow_maintenance_user_agent_access_name" {
  description = "Resources Label"
  type        = string
}

variable "logs_export_bucket_arn" {
  description = "Logs Export Bucket ARN"
  type        = string
}
