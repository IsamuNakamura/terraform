output "ssm_parameter_arns_database_name" {
  value = {
    for key, param in aws_ssm_parameter.maintenance : key => param.arn
  }
}

output "database_names" {
  value = [
    for database_name in var.database_names : database_name
  ]
}
