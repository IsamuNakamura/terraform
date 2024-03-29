resource "aws_acm_certificate" "terraform_test" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_route53_record" "terraform_test" {
  for_each = var.route53_dns_validation == false ? {} : {
    for dvo in aws_acm_certificate.terraform_test.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id = data.aws_route53_zone.terraform_test.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "terraform_test" {
  certificate_arn = aws_acm_certificate.terraform_test.arn
  validation_record_fqdns = var.route53_dns_validation ? [
    for record in aws_route53_record.terraform_test : record.fqdn
    ] : [
    for record in aws_acm_certificate.terraform_test.domain_validation_options : record.resource_record_name
  ]
}
