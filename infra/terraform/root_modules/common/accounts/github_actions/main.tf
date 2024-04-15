module "label" {
  source = "../../../../modules/cloudposse_null_label"

  # namespace, nameは、プロジェクトによって変更する
  environment = "common"
  namespace   = "terraform-test"
  name        = ""
  delimiter   = "-"
  label_order = ["environment", "namespace", "name"]
}

module "global" {
  source = "../../../../modules/accounts/github_actions"

  label = module.label.id
  tags  = module.label.tags
  tier  = "global"

  pgp_key = sensitive(replace(file("${path.cwd}/.public.gpg.base64"), "\n", ""))
  regions_of_codebuild = ["ap-northeast-1"]

  providers = {
    aws = aws.global
  }
}
