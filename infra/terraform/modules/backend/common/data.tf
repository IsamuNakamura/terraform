data "aws_caller_identity" "this" {}

data "aws_route53_zone" "this" {
  name = "${var.route53_zone_name}."
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

data "aws_cloudfront_cache_policy" "backend" {
  name = "Managed-CachingDisabled"
}
