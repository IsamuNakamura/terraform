resource "aws_ecs_cluster" "backend" {
  name = "${var.label}-backend"

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
