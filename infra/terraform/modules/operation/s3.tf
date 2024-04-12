################################################################################
# AWS Config
################################################################################
resource "aws_s3_bucket" "config" {
  bucket              = "${var.label}-${var.tier}-config"
  object_lock_enabled = false

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_s3_bucket_versioning" "config" {
  bucket = aws_s3_bucket.config.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  bucket = aws_s3_bucket.config.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config" {
  bucket = aws_s3_bucket.config.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "config" {
  bucket = aws_s3_bucket.config.id
  policy = data.aws_iam_policy_document.s3_config.json
}

data "aws_iam_policy_document" "s3_config" {
  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [
      aws_s3_bucket.config.arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = ["${data.aws_caller_identity.this.account_id}"]
    }
  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.config.arn}/AWSLogs/${data.aws_caller_identity.this.account_id}/Config/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = ["${data.aws_caller_identity.this.account_id}"]
    }
  }
}

################################################################################
# CloudTrail
################################################################################
resource "aws_s3_bucket" "cloudtrail" {
  bucket              = "${var.label}-${var.tier}-cloudtrail"
  object_lock_enabled = false

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.s3_cloudtrail.json
}

data "aws_iam_policy_document" "s3_cloudtrail" {
  statement {
    sid    = "AWSCloudtrailBucketPermissionsCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [
      aws_s3_bucket.cloudtrail.arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = ["${data.aws_caller_identity.this.account_id}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailBucketDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      // prefixはCloudTrailの設定で指定したものになる(今回は設定していないので付与されない  )
      "${aws_s3_bucket.cloudtrail.arn}/prefix/AWSLogs/${data.aws_caller_identity.this.account_id}/Cloudtrail/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = ["${data.aws_caller_identity.this.account_id}"]
    }
  }
}
