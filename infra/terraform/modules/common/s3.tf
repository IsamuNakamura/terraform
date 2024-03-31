################################################################################
# Log Export
################################################################################
resource "aws_s3_bucket" "log_export" {
  bucket              = "${var.label}-log-export-${var.tier}"
  object_lock_enabled = false

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_s3_bucket_versioning" "log_export" {
  bucket = aws_s3_bucket.log_export.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_export" {
  bucket = aws_s3_bucket.log_export.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log_export" {
  bucket = aws_s3_bucket.log_export.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Cloudfrontのログを出力するためには、ACLを有効化する必要がある
# ただし、ACLは非推奨のため、リソース作成時にエラーになる
resource "aws_s3_bucket_acl" "log_export" {
  bucket = aws_s3_bucket.log_export.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_ownership_controls" "log_export" {
  bucket = aws_s3_bucket.log_export.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

################################################################################
# RDS Backup
################################################################################
resource "aws_s3_bucket" "rds_backup" {
  bucket              = "${var.label}-rds-backup-${var.tier}"
  object_lock_enabled = false

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_s3_bucket_versioning" "rds_backup" {
  bucket = aws_s3_bucket.rds_backup.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "rds_backup" {
  bucket = aws_s3_bucket.rds_backup.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "rds_backup" {
  bucket = aws_s3_bucket.rds_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "local_file" "db_dump_file" {
  filename = "${path.module}/../ec2/maintenance/config/.dbdump.cnf"
  content  = element(data.template_file.db_dump_file.*.rendered, 0)
}
