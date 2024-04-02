resource "aws_ssm_parameter" "database" {
  for_each    = local.ssm_parameters
  name        = "/${join("/", split("-", var.label))}/${each.value["name_suffix"]}"
  description = each.value["description"]
  type        = each.value["type"]
  value       = each.value["value"]
  key_id      = each.value["type"] == "SecureString" ? var.kms_key_arn : null

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
