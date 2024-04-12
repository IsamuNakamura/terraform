module "label" {
  source = "../../../modules/cloudposse_null_label"

  # namespace, nameは、プロジェクトによって変更する
  environment = "prd"
  namespace   = "terraform-test"
  name        = ""
  delimiter   = "-"
  label_order = ["environment", "namespace", "name"]
}

module "global" {
  source = "../../../modules/operation/global"

  label = module.label.id
  tags  = module.label.tags
  tier  = "global"

  daily_cost_budget   = 100
  monthly_cost_budget = 3000
  budget_threshold    = 90

  providers = {
    aws = aws.global
  }
}
