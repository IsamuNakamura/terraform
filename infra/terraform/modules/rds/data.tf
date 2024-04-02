data "template_file" "mysql_config_file" {
  count = var.primary ? 1 : 0

  template = file("${path.module}/template/mysql.tmp")

  vars = {
    user     = local.primary.database_username
    password = local.primary.database_password
    host     = local.primary.database_endpoint
    port     = local.primary.database_port
  }
}
