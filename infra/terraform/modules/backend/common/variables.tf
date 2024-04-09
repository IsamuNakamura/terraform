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
  description = "Resources's Tier"
}

################################################################################
# CloudFront
################################################################################
variable "backend_domain_name" {
  description = "Backend Domain Name"
  type        = string
}

variable "custom_headers" {
  description = "Custom Headers, in case of more than one, separate them with a comma"
  type        = list(string)
}

################################################################################
# CloudFront
################################################################################
variable "acm_certificate_arn_global" {
  description = "ACM Certificate ARN"
  type        = string
}

variable "waf_acl_arn" {
  description = "WAF ACL ARN"
  type        = string
}

variable "logs_export_bucket_domain_name" {
  description = "Logs Export Bucket Domain Name"
  type        = string
}

variable "logs_export_bucket_arn" {
  description = "Logs Export Bucket ARN"
  type        = string
}

variable "logs_export_bucket_id" {
  description = "Logs Export Bucket ID"
  type        = string
}

################################################################################
# Route53
################################################################################
variable "route53_zone_name" {
  description = "Route53 Zone Name"
  type        = string
}

variable "discovery_service_domain_name" {
  description = "Discovery Service Domain Name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

################################################################################
# ALB
################################################################################
variable "acm_certificate_arn_primary" {
  description = "ACM Certificate ARN"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public Subnet IDs"
  type        = list(string)
}
