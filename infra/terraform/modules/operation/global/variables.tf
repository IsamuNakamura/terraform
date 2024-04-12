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
# Budgets
################################################################################
variable "daily_cost_budget" {
  description = "Daily Cost Budget"
  type        = number
}

variable "monthly_cost_budget" {
  description = "Monthly Cost Budget"
  type        = number
}

variable "budget_threshold" {
  description = "Budget Threshold"
  type        = number
}
