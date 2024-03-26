module "label" {
  source = "../../../modules/cloudposse_null_label"

  # namespace, nameは、プロジェクトによって変更する
  environment = "prd"
  namespace   = "terraform"
  name        = ""
  delimiter   = "-"
  label_order = ["environment", "namespace", "name"]
}

module "primary" {
  source = "../../../modules/remote_backend"

  label = module.label.id
  tags  = module.label.tags
  tier  = "primary"

  bucket_name         = module.label.id
  dynamodb_table_name = module.label.id

  providers = {
    aws = aws.primary
  }
}