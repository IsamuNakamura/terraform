# モジュール自体を出力したいが、シークレットデータがあるためできないので、個別に出力
output "primary" {
  description = "rds primary resources"
  value = {
    rds_cluster_identifier = module.primary.rds_cluster_identifier
    security_group_id_rds  = module.primary.security_group_id_rds
    ssm_parameter_arns = {
      database_endpoint = module.primary.ssm_parameter_arns_database_parameter.database_endpoint,
      database_port     = module.primary.ssm_parameter_arns_database_parameter.database_port,
      database_username = module.primary.ssm_parameter_arns_database_parameter.database_username,
      database_password = module.primary.ssm_parameter_arns_database_parameter.database_password,
    }
  }
}

# output "secondary" {
#   description = "rds secondary resources"
#   value = {
#     security_group_id_rds = module.secondary.security_group_id_rds
#     ssm_parameter_arns = {
#       database_endpoint = module.secondary.ssm_parameter_arns_database_parameter.database_endpoint,
#       database_port     = module.secondary.ssm_parameter_arns_database_parameter.database_port,
#       database_username = module.secondary.ssm_parameter_arns_database_parameter.database_username,
#       database_password = module.secondary.ssm_parameter_arns_database_parameter.database_password,
#     }
#   }
# }
