resource "aws_s3_bucket" "remote_backend" {
  bucket = "${var.bucket_name}-terraform-remote-backend"

  # lifecycle {
  #   prevent_destroy = true # terraform destroyによって削除されないよう設定
  # }

  tags = merge(
    var.tags, {
      Name = "${var.bucket_name}-terraform-remote-backend",
      Tier = var.tier,
    }
  )
}

resource "aws_s3_bucket_versioning" "remote_backend" {
  bucket = aws_s3_bucket.remote_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "remote_backend" {
  bucket = aws_s3_bucket.remote_backend.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "remote_backend" {
  bucket = aws_s3_bucket.remote_backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
