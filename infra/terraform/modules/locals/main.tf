# 共通のローカル変数は、プロジェクトによって変更する
locals {
  domain_name             = "terraform-test.jp"
  frontend_subdomain_name = "app"
  backend_subdomain_name  = "api"

  health_check_path             = "health_check"
  frontend_port                 = 3000
  backend_port                  = 80
  discovery_service_domain_name = "local"
}
