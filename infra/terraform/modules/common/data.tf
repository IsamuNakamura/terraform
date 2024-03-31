data "template_file" "db_dump_file" {
  template = file("${path.module}/config/dbdump.cnf")

  vars = {
    upload_backet = local.dbdump_upload_backet
  }
}
