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
# ACM
################################################################################
variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "route53_zone_name" {
  description = "Route53 Zone Name."
  type        = string
}

variable "route53_dns_validation" {
  description = "Route53 DNS Validation."
  type        = bool
}
