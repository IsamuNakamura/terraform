data "template_file" "db_dump_file" {
  template = file("${path.module}/template/dbdump.tmp")

  vars = {
    upload_backet = local.dbdump_upload_backet
  }
}
