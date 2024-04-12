resource "aws_config_configuration_recorder" "this" {
  name     = "${var.label}-config-recorder"
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    all_supported = true
    # メインのリージョンでのみグローバルリソースの監視を行う
    include_global_resource_types = true
  }
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_delivery_channel" "this" {
  name           = "${var.label}-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config.bucket
  # s3_kms_key_arn = var.kms_key_arn # AWSServiceRoleForConfigを使用しているので、KMSのポリシーは設定できないため設定しない
  sns_topic_arn = aws_sns_topic.config.arn
  depends_on    = [aws_config_configuration_recorder.this]
}

resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_config_rule" "mfa_enabled" {
  name = "${var.label}-mfa-enabled"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_config_rule" "guardduty_enabled_centralized" {
  name = "${var.label}-guardduty-enabled-centralized"

  source {
    owner             = "AWS"
    source_identifier = "GUARDDUTY_ENABLED_CENTRALIZED"
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_config_rule" "incoming_ssh_disabled" {
  name = "${var.label}-incoming-ssh-disabled"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  scope {
    compliance_resource_types = [
      "AWS::EC2::SecurityGroup"
    ]
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_config_rule" "restricted_incoming_traffic" {
  name = "${var.label}-restricted-incoming-traffic"

  source {
    owner             = "AWS"
    source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
  }

  scope {
    compliance_resource_types = [
      "AWS::EC2::SecurityGroup"
    ]
  }

  depends_on = [aws_config_configuration_recorder.this]
}
