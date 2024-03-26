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
# Route53
################################################################################
variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "vercel_production_record_name" {
  description = "Vercel Record Name in Production"
  type        = string
}

variable "vercel_staging_record_name" {
  description = "Staging Record Name"
  type        = string
}

variable "vercel_testing_record_name" {
  description = "Vercel Record Name in Testing"
  type        = string
}

variable "vercel_cname_record" {
  description = "Vercel CNAME Record"
  type        = string
}
