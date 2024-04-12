resource "aws_cloudtrail" "this" {
  name                          = "${var.label}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}
