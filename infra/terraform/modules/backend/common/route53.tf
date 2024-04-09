resource "aws_route53_record" "A-backend" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.backend_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.backend.domain_name
    zone_id                = aws_cloudfront_distribution.backend.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "AAAA-backend" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.backend_domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.backend.domain_name
    zone_id                = aws_cloudfront_distribution.backend.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_service_discovery_private_dns_namespace" "backend" {
  name        = "${var.label}.${var.discovery_service_domain_name}"
  description = "ECS Service Discovery namespace for ${var.label}"
  vpc         = "${var.vpc_id}"

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
