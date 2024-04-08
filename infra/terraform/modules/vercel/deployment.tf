# productionをfalseにすると、Preview環境としてデプロイされる
resource "vercel_deployment" "nextjs" {
  project_id = vercel_project.nextjs.id
  ref        = var.deploy_ref

  production  = var.is_production
}