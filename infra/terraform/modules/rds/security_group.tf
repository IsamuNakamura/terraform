resource "aws_security_group" "rds" {
  vpc_id      = var.vpc_id
  description = "allow 3306 to rds"
  name        = "${var.label}-rds"

  tags = merge(
    var.tags,
    {
      Name = "${var.label}-rds",
      Tier = var.tier,
    }
  )
}
