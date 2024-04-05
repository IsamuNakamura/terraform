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

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "ec2_params" {
  description = "EC2 Parameters"
  type = object({
    grafana = map(string)
  })
}

variable "security_group_rds_id" {
  description = "RDS Security Group ID"
  type        = string
}


variable "kms_key_arn" {
  description = "Kms Key ARN"
  type        = string
}

