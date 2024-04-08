resource "vercel_project" "nextjs" {
  name      = var.label
  framework = "nextjs"

  git_repository = {
    type = var.repository_type
    repo = var.repository_name
    # ブランチを指定しないとmainブランチがproductionブランチとして設定され、
    # vercel_deploymentで設定するブランチがPreview環境としてデプロイされる
    production_branch = var.deploy_ref
  }

  ignore_command = var.ignore_command
}