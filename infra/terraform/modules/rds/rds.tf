resource "aws_rds_cluster_parameter_group" "this" {
  name        = var.label
  description = var.label
  family      = var.rds.family

  parameter {
    apply_method = "immediate"
    name         = "character_set_server"
    value        = "utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "slow_query_log"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "server_audit_events"
    value        = "CONNECT,QUERY,QUERY_DCL,QUERY_DDL,QUERY_DML,TABLE"
  }
  parameter {
    apply_method = "immediate"
    name         = "server_audit_logging"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "server_audit_logs_upload"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "log_bin_trust_function_creators"
    value        = "1"
  }

  # 一般ログを無効にする
  parameter {
    name  = "general_log"
    value = "0"
  }

  # ブルーグリーンデプロイを行うため
  parameter {
    name         = "binlog_format"
    value        = "MIXED"
    apply_method = "pending-reboot"
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_db_subnet_group" "this" {
  name        = var.label
  description = var.label
  subnet_ids  = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = var.rds.cluster_name
  engine             = var.rds.engine
  engine_version     = var.rds.engine_version
  engine_mode        = "provisioned"
  master_username    = var.rds.master_username # セカンダリでの設定は不要なので、変数化
  master_password    = var.rds.master_password # セカンダリでの設定は不要なので、変数化
  port               = 3306
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]
  availability_zones              = [for k, _ in var.availability_zones : k]
  db_subnet_group_name            = aws_db_subnet_group.this.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.id
  skip_final_snapshot             = true
  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery",
  ]
  backup_retention_period = 7
  copy_tags_to_snapshot   = true
  deletion_protection     = true
  # global_cluster_identifier = var.global_cluster_identifier

  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  serverlessv2_scaling_configuration {
    min_capacity = var.serverless_v2_min_capacity
    max_capacity = var.serverless_v2_max_capacity
  }

  lifecycle {
    ignore_changes = [
      master_password,
    ]
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

# aws_rds_cluster_instanceは冗長化のため、for_eachでリソースを複製する
# countでの複製だと順序に依存されるため管理が複雑になる。
resource "aws_rds_cluster_instance" "this" {
  # idはすでに作成されているリソースがidentifierを変更することで削除されることを避けるために設定
  for_each                   = var.rds.instances
  identifier                 = "${var.tier}-${var.label}-${each.value.name_suffix}"
  cluster_identifier         = aws_rds_cluster.this.id
  engine                     = var.rds.engine
  engine_version             = var.rds.engine_version
  ca_cert_identifier         = "rds-ca-rsa2048-g1"
  auto_minor_version_upgrade = true
  promotion_tier             = 1
  instance_class             = each.value.class
  db_subnet_group_name       = aws_db_subnet_group.this.name
  availability_zone          = each.key

  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.kms_key_arn
  performance_insights_retention_period = 7

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

# メンテナンスサーバー作成後にデーターベースを作成するために、mysqlコマンドで必要な設定をEC2モジュールに作成する
# メンテナンスサーバー作成時に動的に作成するとファイルを参照できないので、RDS作成時に作成する
resource "local_file" "mysql_config_file" {
  count = var.primary ? 1 : 0

  filename = "${path.cwd}/../ec2/maintenance/config/.db.cnf"
  content  = element(data.template_file.mysql_config_file.*.rendered, 0)
}
