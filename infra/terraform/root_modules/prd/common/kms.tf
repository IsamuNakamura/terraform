module "kms_primary" {
  source = "terraform-aws-modules/kms/aws"

  description = module.label.id
  key_usage   = "ENCRYPT_DECRYPT"

  # Policy
  key_administrators = []
  key_users          = []
  key_service_users  = []

  # Aliases
  aliases = ["${module.label.id}"]

  tags = module.label.tags

  providers = {
    aws = aws.primary
  }
}

# module "kms_secondary" {
#   source = "terraform-aws-modules/kms/aws"

#   description = module.label.id
#   key_usage   = "ENCRYPT_DECRYPT"
#   # multi_region = true

#   # Policy
#   key_administrators = []
#   key_users          = []
#   key_service_users  = []

#   # Aliases
#   aliases = ["${module.label.id}"]

#   tags = module.label.tags

#   providers = {
#     aws = aws.secondary
#   }
# }

# #
# # マルチリージョンキー
# # プライマリーキーが東京にあるためここに作成する
# #
# module "kms_mr_primary" {
#   source = "terraform-aws-modules/kms/aws"

#   description  = "${module.label.id}-multi-region"
#   key_usage    = "ENCRYPT_DECRYPT"
#   multi_region = true

#   # Policy
#   key_administrators = []
#   key_users          = []
#   key_service_users  = []

#   # Aliases
#   aliases = ["${module.label.id}-multi-region"]

#   tags = module.label.tags

#   providers = {
#     aws = aws.primary
#   }
# }

# #
# # マルチリージョンキー、レプリカ
# #
# module "kms_mr_secondary" {
#   source = "terraform-aws-modules/kms/aws"

#   description = "${module.label.id}-multi-region"

#   create_replica = true

#   # Policy
#   key_administrators = []
#   key_users          = []
#   key_service_users  = []

#   # Aliases
#   aliases         = ["${module.label.id}-multi-region"]
#   primary_key_arn = module.kms_mr_primary.key_arn

#   tags = module.label.tags

#   providers = {
#     aws = aws.secondary
#   }
# }

# #
# # マルチリージョンキー、レプリカ
# #
# module "kms_mr_global" {
#   source = "terraform-aws-modules/kms/aws"

#   description = "${module.label.id}-multi-region"

#   create_replica = true

#   # Policy
#   key_administrators = []
#   key_users          = []
#   key_service_users  = []

#   # Aliases
#   aliases         = ["${module.label.id}-multi-region"]
#   primary_key_arn = module.kms_mr_primary.key_arn

#   tags = module.label.tags

#   providers = {
#     aws = aws.global
#   }
# }