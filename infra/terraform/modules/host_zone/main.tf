resource "aws_route53_zone" "terraform_test" {
  name = var.domain_name

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

# Vercelでサブドメインを使用する場合、CNAMEレコードを追加する
resource "aws_route53_record" "vercel_production_cname_record" {
  zone_id = aws_route53_zone.terraform_test.zone_id
  name    = var.vercel_production_record_name
  type    = "CNAME"
  ttl     = "300"
  records = [var.vercel_cname_record]
}

resource "aws_route53_record" "vercel_staging_cname_record" {
  zone_id = aws_route53_zone.terraform_test.zone_id
  name    = var.vercel_staging_record_name
  type    = "CNAME"
  ttl     = "300"
  records = [var.vercel_cname_record]
}

resource "aws_route53_record" "vercel_testing_cname_record" {
  zone_id = aws_route53_zone.terraform_test.zone_id
  name    = var.vercel_testing_record_name
  type    = "CNAME"
  ttl     = "300"
  records = [var.vercel_cname_record]
}
