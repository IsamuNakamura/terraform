data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "maintenance" {
  name               = "${var.label}-${var.tier}-ec2-maintenance"
  description        = "EC2 Instance Profile IAM Role for maintenance"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_iam_role_policy" "maintenance" {
  name   = aws_iam_role.maintenance.name
  role   = aws_iam_role.maintenance.id
  policy = data.aws_iam_policy_document.maintenance.json
}

data "aws_iam_policy_document" "maintenance" {
  statement {
    sid = "AllowReadingMetricsFromCloudWatch"

    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "AllowReadingLogsFromCloudWatch"

    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "AllowReadingTagsInstancesRegionsFromEC2"

    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid       = "S3UploadAccessForRDSBackup"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${var.rds_backup_bucket_arn}/*",
    ]
  }

  statement {
    sid       = "KMSAccessForRDSBackup"

    actions = [
      "kms:GenerateDataKey"
    ]

    resources = [
      var.kms_key_arn,
    ]
  }

  statement {
    sid = "AllowReadingResourcesForTags"

    actions = [
      "tag:GetResources",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy" "systems_manager" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.maintenance.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}

# IAMロールをEC2インスタンスにアタッチするためのリソース
resource "aws_iam_instance_profile" "maintenance" {
  name = "${var.label}-${var.tier}-ec2-maintenance"
  role = aws_iam_role.maintenance.name
}
