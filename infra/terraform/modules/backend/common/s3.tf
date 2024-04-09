resource "aws_s3_bucket_policy" "cloudfront_logs_export" {
  bucket = var.logs_export_bucket_id
  policy = data.aws_iam_policy_document.cloudfront_logs_export.json
}

data "aws_iam_policy_document" "cloudfront_logs_export" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:DeleteObject"
    ]

    effect = "Allow"

    resources = [
      var.logs_export_bucket_arn,
      "${var.logs_export_bucket_arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.this.account_id]
    }
  }
}
