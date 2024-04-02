
################################################################################
# RDS
################################################################################
output "ssm_parameter_arns_database_parameter" {
  value = {
    for key, param in aws_ssm_parameter.database : key => param.arn
  }
}

output "rds_cluster_identifier" {
  value = aws_rds_cluster.this.cluster_identifier
}

################################################################################
# Security Groups
################################################################################
output "security_group_id_rds" {
  value = aws_security_group.rds.id
}
