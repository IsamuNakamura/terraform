data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "grafana" {
  name               = "${var.label}-${var.tier}-ec2-grafana"
  description        = "EC2 Instance Profile IAM Role for grafana"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

data "aws_iam_policy" "systems_manager" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.grafana.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}

# IAMロールをEC2インスタンスにアタッチするためのリソース
resource "aws_iam_instance_profile" "grafana" {
  name = "${var.label}-${var.tier}-ec2-grafana"
  role = aws_iam_role.grafana.name
}
