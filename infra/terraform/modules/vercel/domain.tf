# projectで設定したProductionブランチとdomainのブランチが同じものはTerraformではエラーになるので、Terraformでは実行しない
# Terraformでdomainを設定しようとするとPreviewでデプロイしようとするので、エラーになる
# エラー: unexpected error: cannot_set_production_branch_as_preview - Cannot set Production Branch "deploy-on-vercel" for a Preview Domain.
# resource "vercel_project_domain" "nextjs" {
#   project_id = vercel_project.nextjs.id
#   domain     = var.domain_name
#   git_branch = var.deploy_ref
# }