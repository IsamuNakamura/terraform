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
  type        = string
  description = "Resources's Tier"
}

################################################################################
# IAM
################################################################################
variable "pgp_key" {
  description = "PGP Key for encrypting IAM credentials"
  type        = string
}

variable "regions_of_codebuild" {
  description = "Regions of CodeBuild"
  type        = list(string)
}
