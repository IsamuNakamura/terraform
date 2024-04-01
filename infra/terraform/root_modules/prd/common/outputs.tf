output "global" {
  description = "global resources"
  value = merge(
    module.global
  )
}

output "primary" {
  description = "primary resources"
  value = merge(
    module.primary,
    {
      kms_key_primary_arn = module.kms_primary.key_arn
    },
  )
}

# output "secondary" {
#   description = "secondary resources"
#   value = merge(
#     module.secondary,
#     {
#       kms_key_secondary_arn = module.kms_secondary.key_arn
#     },
#   )
# }