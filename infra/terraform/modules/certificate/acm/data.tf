data "aws_route53_zone" "terraform_test" {
  name = "${var.route53_zone_name}."
}