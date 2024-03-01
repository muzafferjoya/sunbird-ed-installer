# locals {
#   # This section will be enabled after final code is pushed and tagged
#   # source_base_url = "github.com/<org>/modules.git//app"
#   environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
#   environment = local.environment_vars.locals.environment
#   building_block = local.environment_vars.locals.building_block
#   random_string  = local.environment_vars.locals.random_string
# }

# # For local development
# terraform {
#   source = "../../modules//keys/"
# }

# dependency "storage" {
#     config_path = "../storage"
#     mock_outputs = {
#       azurerm_storage_account_name = "dummy-account"
#       azurerm_storage_container_public = "dummy-container-public"
#       azurerm_storage_container_private = "dummy-container-private"
#       azurerm_storage_account_key = "dummy-key"
#     }
# }

# inputs = {
#   environment                                = local.environment
#   building_block                     = local.building_block
#   storage_account_name               = dependency.storage.outputs.azurerm_storage_account_name
#   storage_container_public           = dependency.storage.outputs.azurerm_storage_container_public
#   storage_container_private          = dependency.storage.outputs.azurerm_storage_container_private
#   storage_account_primary_access_key = dependency.storage.outputs.azurerm_storage_account_key
#   random_string                      = local.random_string
# }

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  environment = local.environment_vars.locals.environment
  building_block = local.environment_vars.locals.building_block
  random_string  = local.environment_vars.locals.random_string
}

terraform {
  source = "../../modules//keys/"  # Adjust the source to your AWS keys module path
}

dependency "storage" {
  config_path = "../s3"  # Adjust the config path to your AWS S3 module path
  mock_outputs = {
    aws_s3_bucket_name = "dummy-bucket"
    aws_s3_bucket_arn = "arn:aws:s3:::dummy-bucket"
    aws_s3_bucket_policy = "dummy-policy"
    aws_s3_bucket_encryption = "dummy-encryption"
    aws_s3_bucket_versioning = "dummy-versioning"
  }
}

inputs = {
  environment                      = local.environment
  building_block                   = local.building_block
  s3_bucket_name                   = dependency.storage.outputs.aws_s3_bucket_name
  s3_bucket_arn                    = dependency.storage.outputs.aws_s3_bucket_arn
  s3_bucket_policy                 = dependency.storage.outputs.aws_s3_bucket_policy
  s3_bucket_encryption             = dependency.storage.outputs.aws_s3_bucket_encryption
  s3_bucket_versioning             = dependency.storage.outputs.aws_s3_bucket_versioning
  random_string                    = local.random_string
}
