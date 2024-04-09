resource "aws_cloudfront_distribution" "backend" {
  aliases             = [var.backend_domain_name]
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = true

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn_global
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  origin {
    domain_name = aws_lb.backend.dns_name
    origin_id   = "ALB-backend"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "ALB-backend"

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    cache_policy_id          = data.aws_cloudfront_cache_policy.backend.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.backend.id
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 403
    response_code         = 200
    response_page_path    = "/"
  }

  logging_config {
    include_cookies = false
    bucket          = var.logs_export_bucket_domain_name
    prefix          = "cloudfront/accesslog/backend"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = var.waf_acl_arn

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_cloudfront_origin_request_policy" "backend" {
  name = "${var.label}-backend"

  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = var.custom_headers
    }
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}
